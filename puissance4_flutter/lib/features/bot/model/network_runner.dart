// TFLite tourne par FFI : rien à importer sur le web, où le réseau est
// recalculé en Dart (`ConnectFourNet`).
export 'network_runner_stub.dart'
    if (dart.library.ffi) 'network_runner_ffi.dart';
