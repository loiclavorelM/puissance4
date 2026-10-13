// TFLite tourne par FFI : rien à importer sur le web, où le serveur joue le
// bot (`ServerBotBrain`).
export 'network_runner_stub.dart'
    if (dart.library.ffi) 'network_runner_ffi.dart';
