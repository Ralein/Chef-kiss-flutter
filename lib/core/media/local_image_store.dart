/// Persists photos (scan thumbnails, recipe covers) on the device.
///
/// Native platforms write into the app documents directory. On the web there
/// is no app-private filesystem, so photos are not persisted and callers fall
/// back to illustrations/placeholders.
library;

export 'local_image_store_stub.dart'
    if (dart.library.io) 'local_image_store_io.dart'
    if (dart.library.js_interop) 'local_image_store_web.dart';
