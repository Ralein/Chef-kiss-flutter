import 'package:app_contracts/app_contracts.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Camera / photo-library access with consistent sizing and error handling.
class PhotoPicker {
  PhotoPicker._();

  static final ImagePicker _picker = ImagePicker();

  static bool get cameraAvailable {
    try {
      return _picker.supportsImageSource(ImageSource.camera);
    } catch (_) {
      return false;
    }
  }

  /// Returns the photo bytes, `null` if the user cancelled, or a failure.
  /// [maxEdge] bounds the long edge so uploads stay small; JPEG quality is
  /// high enough to keep small print on recipe cards legible.
  static Future<Result<Uint8List?, AppFailure>> pick(ImageSource source, {double maxEdge = 2048, int quality = 88}) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: maxEdge,
        maxHeight: maxEdge,
        imageQuality: quality,
        requestFullMetadata: false,
      );
      if (file == null) return const Result.ok(null);
      return Result.ok(await file.readAsBytes());
    } on PlatformException catch (e) {
      final denied = e.code.toLowerCase().contains('denied') || e.code.toLowerCase().contains('permission');
      if (denied) {
        return Result.err(PermissionDeniedFailure(
          capability: source == ImageSource.camera ? 'camera' : 'photos',
          message: source == ImageSource.camera
              ? 'Chef’s Kiss doesn’t have permission to use the camera.'
              : 'Chef’s Kiss doesn’t have permission to open your photos.',
          recoveryAction: 'Allow access in your device Settings, then try again.',
        ));
      }
      return Result.err(UnexpectedFailure(
        message: source == ImageSource.camera ? 'The camera could not be opened.' : 'Your photos could not be opened.',
        error: e,
      ));
    } catch (e) {
      return Result.err(UnexpectedFailure(message: 'That photo could not be loaded.', error: e));
    }
  }
}
