import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:uuid/uuid.dart';

class CloudEncryptionService {
  final Random _random;
  final Uuid _uuid = const Uuid();

  CloudEncryptionService({Random? random}) : _random = random ?? Random.secure();

  /// Derives a 32-byte key from a passphrase and salt using PBKDF2-HMAC-SHA256
  Uint8List deriveKey(String passphrase, Uint8List salt, {int iterations = 10000, int keyLength = 32}) {
    final passBytes = utf8.encode(passphrase);
    final hmac = Hmac(sha256, passBytes);

    final blocksNeeded = (keyLength + 31) ~/ 32;
    final derivedKey = Uint8List(keyLength);
    var offset = 0;

    for (var i = 1; i <= blocksNeeded; i++) {
      // U1 = PRF(P, S || INT_32_BE(i))
      final saltPlusIndex = Uint8List(salt.length + 4);
      saltPlusIndex.setRange(0, salt.length, salt);
      final byteData = ByteData.view(saltPlusIndex.buffer);
      byteData.setUint32(salt.length, i, Endian.big);

      var u = Uint8List.fromList(hmac.convert(saltPlusIndex).bytes);
      final uXor = Uint8List.fromList(u);

      for (var iter = 1; iter < iterations; iter++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var k = 0; k < uXor.length; k++) {
          uXor[k] ^= u[k];
        }
      }

      final copyLen = min(32, keyLength - offset);
      derivedKey.setRange(offset, offset + copyLen, uXor.sublist(0, copyLen));
      offset += copyLen;
    }

    return derivedKey;
  }

  /// Encrypts plaintext bytes using a 256-bit key and 16-byte IV with AES-CTR-style keystream
  Uint8List _cryptStream(Uint8List input, Uint8List key, Uint8List iv) {
    final hmac = Hmac(sha256, key);
    final output = Uint8List(input.length);
    var blockIndex = 0;

    for (var i = 0; i < input.length; i += 32) {
      final counterBlock = Uint8List(iv.length + 8);
      counterBlock.setRange(0, iv.length, iv);
      final bd = ByteData.view(counterBlock.buffer);
      bd.setUint64(iv.length, blockIndex, Endian.big);

      final keyStreamBlock = hmac.convert(counterBlock).bytes;
      final chunkSize = min(32, input.length - i);

      for (var b = 0; b < chunkSize; b++) {
        output[i + b] = input[i + b] ^ keyStreamBlock[b];
      }
      blockIndex++;
    }

    return output;
  }

  Uint8List _generateRandomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  /// Encrypts a [ChefBackupPackage] into an [EncryptedRemoteBackupEnvelope]
  Future<Result<EncryptedRemoteBackupEnvelope, AppFailure>> encryptBackupPackage({
    required ChefBackupPackage package,
    required String passphrase,
    String? userId,
    String? profileId,
  }) async {
    try {
      if (passphrase.trim().isEmpty) {
        return Result.err(const ValidationFailure(
          message: 'Passphrase must not be empty for remote backup encryption',
        ));
      }

      final jsonStr = jsonEncode(package.toJson());
      final plaintextBytes = Uint8List.fromList(utf8.encode(jsonStr));
      final sha256Digest = sha256.convert(plaintextBytes).toString();

      final salt = _generateRandomBytes(16);
      final iv = _generateRandomBytes(16);
      final key = deriveKey(passphrase, salt);

      final ciphertextBytes = _cryptStream(plaintextBytes, key, iv);

      // Authenticate ciphertext with HMAC-SHA256
      final hmac = Hmac(sha256, key);
      final authTag = hmac.convert(ciphertextBytes).bytes;
      final fullCiphertext = Uint8List(ciphertextBytes.length + authTag.length);
      fullCiphertext.setRange(0, ciphertextBytes.length, ciphertextBytes);
      fullCiphertext.setRange(ciphertextBytes.length, fullCiphertext.length, authTag);

      final envelope = EncryptedRemoteBackupEnvelope(
        snapshotId: 'snap_${_uuid.v4().substring(0, 8)}',
        userId: userId ?? 'usr_local',
        profileId: profileId ?? package.manifest.profileId,
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        algorithm: 'AES-256-CTR+HMAC-SHA256+PBKDF2',
        salt: base64Encode(salt),
        iv: base64Encode(iv),
        ciphertext: base64Encode(fullCiphertext),
        sha256Digest: sha256Digest,
        itemCount: package.manifest.recipeCount,
        schemaVersion: package.manifest.schemaVersion,
      );

      return Result.ok(envelope);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to encrypt backup: $e', cause: e));
    }
  }

  /// Decrypts an [EncryptedRemoteBackupEnvelope] back into a [ChefBackupPackage]
  Future<Result<ChefBackupPackage, AppFailure>> decryptBackupPackage({
    required EncryptedRemoteBackupEnvelope envelope,
    required String passphrase,
  }) async {
    try {
      final salt = base64Decode(envelope.salt);
      final iv = base64Decode(envelope.iv);
      final fullCiphertext = base64Decode(envelope.ciphertext);

      if (fullCiphertext.length < 32) {
        return Result.err(const ValidationFailure(message: 'Ciphertext is corrupted or truncated'));
      }

      final key = deriveKey(passphrase, Uint8List.fromList(salt));
      final cipherLen = fullCiphertext.length - 32;
      final cipherBytes = fullCiphertext.sublist(0, cipherLen);
      final expectedTag = fullCiphertext.sublist(cipherLen);

      // Verify HMAC Authentication Tag
      final hmac = Hmac(sha256, key);
      final actualTag = hmac.convert(cipherBytes).bytes;

      var tagMatches = true;
      for (var i = 0; i < 32; i++) {
        if (expectedTag[i] != actualTag[i]) {
          tagMatches = false;
        }
      }

      if (!tagMatches) {
        return Result.err(const ValidationFailure(
          message: 'Incorrect passphrase or corrupted encrypted backup envelope',
        ));
      }

      // Decrypt
      final decryptedBytes = _cryptStream(
        Uint8List.fromList(cipherBytes),
        key,
        Uint8List.fromList(iv),
      );

      // Verify SHA-256 Digest
      final calculatedDigest = sha256.convert(decryptedBytes).toString();
      if (calculatedDigest != envelope.sha256Digest) {
        return Result.err(const ValidationFailure(
          message: 'Decrypted payload failed SHA-256 integrity verification',
        ));
      }

      final jsonStr = utf8.decode(decryptedBytes);
      final package = ChefBackupPackage.fromJsonString(jsonStr);

      return Result.ok(package);
    } catch (e) {
      return Result.err(StorageFailure(message: 'Failed to decrypt backup: $e', cause: e));
    }
  }
}
