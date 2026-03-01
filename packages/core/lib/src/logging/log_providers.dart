import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

export 'package:talker_flutter/talker_flutter.dart';
export 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

// ignore: strict_top_level_inference
final talkerProvider = Provider<Talker>((ref) {
  final talker = TalkerFlutter.init(
    settings: TalkerSettings(
      useConsoleLogs: kDebugMode,
      useHistory: true,
    ),
  );
  return talker;
});
