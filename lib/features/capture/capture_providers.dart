import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped by the shell header to ask [CaptureScreen] to repeat the last expense/income.
final captureRepeatTriggerProvider = StateProvider<int>((ref) => 0);
