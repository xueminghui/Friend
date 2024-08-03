import 'dart:math';

import 'package:friend_private/backend/database/geolocation.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/server/message.dart';

class CreateMemoryResponse {
  final List<ServerMessage> messages;
  final ServerMemory? memory;

  CreateMemoryResponse({required this.messages, required this.memory});

  factory CreateMemoryResponse.fromJson(Map<String, dynamic> json) {
    return CreateMemoryResponse(
      messages: ((json['messages'] ?? []) as List<dynamic>).map((message) => ServerMessage.fromJson(message)).toList(),
      memory: json['memory'] != null ? ServerMemory.fromJson(json['memory']) : null,
    );
  }
}

class ServerMemory {
  final String id;
  final DateTime createdAt;
  final String transcript;
  final Structured structured;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final List<TranscriptSegment> transcriptSegments;
  final List<PluginResponse> pluginsResults;
  final Geolocation? geolocation;
  final List<MemoryPhoto> photos;
  bool discarded;
  final bool deleted;

  ServerMemory({
    required this.id,
    required this.createdAt,
    required this.transcript,
    required this.structured,
    this.startedAt,
    this.finishedAt,
    this.transcriptSegments = const [],
    this.pluginsResults = const [],
    this.geolocation,
    this.photos = const [],
    this.discarded = false,
    this.deleted = false,
  });

  MemoryType get type => transcript.isNotEmpty ? MemoryType.audio : MemoryType.image;

  factory ServerMemory.fromJson(Map<String, dynamic> json) {
    return ServerMemory(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      transcript: json['transcript'],
      structured: Structured.fromJson(json['structured']),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at']) : null,
      transcriptSegments: ((json['transcript_segments'] ?? []) as List<dynamic>)
          .map((segment) => TranscriptSegment.fromJson(segment))
          .toList(),
      pluginsResults:
          ((json['plugins_results'] ?? []) as List<dynamic>).map((result) => PluginResponse.fromJson(result)).toList(),
      geolocation: json['geolocation'] != null ? Geolocation.fromJson(json['geolocation']) : null,
      photos: (json['photos'] as List<dynamic>).map((photo) => MemoryPhoto.fromJson(photo)).toList(),
      discarded: json['discarded'] ?? false,
      deleted: json['deleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'transcript': transcript,
      'structured': structured.toJson(),
      'started_at': startedAt?.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
      'transcript_segments': transcriptSegments.map((segment) => segment.toJson()).toList(),
      'plugins_results': pluginsResults.map((result) => result.toJson()).toList(),
      'geolocation': geolocation?.toJson(),
      'photos': photos.map((photo) => photo.toJson()).toList(),
      'discarded': discarded,
      'deleted': deleted,
    };
  }

  String getTranscript({int? maxCount, bool generate = false}) {
    try {
      var transcript = generate && transcriptSegments.isNotEmpty
          ? TranscriptSegment.segmentsAsString(transcriptSegments, includeTimestamps: true)
          : this.transcript;
      if (maxCount != null) return transcript.substring(0, min(maxCount, transcript.length));
      return transcript;
    } catch (e) {
      return transcript;
    }
  }
}