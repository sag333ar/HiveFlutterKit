import 'dart:convert';

import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/safe_convert.dart';


class DoesPostExistsResponse {
  final DoesPostExistsResponseError? error;

  DoesPostExistsResponse({
    required this.error,
  });

  factory DoesPostExistsResponse.fromJson(Map<String, dynamic>? json) =>
      DoesPostExistsResponse(
        error: DoesPostExistsResponseError.fromJson(asMap(json, 'error')),
      );

  factory DoesPostExistsResponse.fromJsonString(String jsonString) =>
      DoesPostExistsResponse.fromJson(json.decode(jsonString));
}

class DoesPostExistsResponseError {
  final String data;

  DoesPostExistsResponseError({
    this.data = "",
  });

  factory DoesPostExistsResponseError.fromJson(Map<String, dynamic>? json) =>
      DoesPostExistsResponseError(
        data: asString(json, 'data'),
      );
}
