import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

class ResumableUploadService {
  ResumableUploadService({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

  /// Upload large file in chunks (>100MB)
  /// Returns true if successful
  Future<bool> uploadFile({
    required File file,
    required String filename,
    required String contentType,
    required String parentId,
    required String token,
    int concurrentUploads = 3, // number of parallel uploads
  }) async {
    final int fileSize = await file.length();
    const int partSize = 5 * 1024 * 1024; // 5MB
    final int totalParts = (fileSize / partSize).ceil();

    // 1️⃣ INITIATE UPLOAD
    final Response<dynamic> initiateResp = await _dio.post(
      'https://your-api.com/v1/vault/resumable/initiate',
      options: Options(
        headers: <String, dynamic>{'Authorization': 'Bearer $token'},
      ),
      data: <String, Object>{
        'filename': filename,
        'contentType': contentType,
        'size': fileSize,
        'parentId': parentId,
      },
    );

    if (initiateResp.data['success'] != true) {
      print('Failed to initiate upload');
      return false;
    }

    final String uploadId = initiateResp.data['data']['uploadId'];
    final String key = initiateResp.data['data']['key'];

    // 2️⃣ GET UPLOAD PART URLS
    final List<int> partNumbers = List<int>.generate(
      totalParts,
      (int i) => i + 1,
    );

    final Response<dynamic> partUrlsResp = await _dio.post(
      'https://your-api.com/v1/vault/resumable/part-urls',
      options: Options(
        headers: <String, dynamic>{'Authorization': 'Bearer $token'},
      ),
      data: <String, Object>{
        'uploadId': uploadId,
        'key': key,
        'partNumbers': partNumbers,
      },
    );

    if (partUrlsResp.data['success'] != true) {
      print('Failed to get part URLs');
      return false;
    }

    final List parts = partUrlsResp.data['data']['parts'];

    // 3️⃣ UPLOAD PARTS
    Future<void> uploadPart(Map part) async {
      final int partNumber = part['partNumber'];
      final String url = part['uploadUrl'];

      final int start = (partNumber - 1) * partSize;
      final int end = min(start + partSize, fileSize);

      final Stream<List<int>> chunkStream = file.openRead(start, end);

      await _dio.put(
        url,
        data: chunkStream,
        options: Options(
          headers: <String, dynamic>{
            'Content-Type': 'application/octet-stream',
          },
          maxRedirects: 5,
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 5),
        ),
        onSendProgress: (int sent, int total) {
          print(
            'Part $partNumber: ${((sent / total) * 100).toStringAsFixed(1)}%',
          );
        },
      );
    }

    // Parallel uploads (concurrentUploads at a time)
    for (int i = 0; i < parts.length; i += concurrentUploads) {
      final Iterable<dynamic> batch = parts.skip(i).take(concurrentUploads);

      // Cast each part to Map<String, dynamic>
      await Future.wait(
        batch.map((part) => uploadPart(part as Map<String, dynamic>)),
      );
    }

    // 4️⃣ CHECK PROGRESS (get real ETags)
    final Response<dynamic> progressResp = await _dio.get(
      'https://your-api.com/v1/vault/resumable/progress',
      queryParameters: <String, dynamic>{'uploadId': uploadId, 'key': key},
      options: Options(
        headers: <String, dynamic>{'Authorization': 'Bearer $token'},
      ),
    );

    if (progressResp.data['success'] != true) {
      print('Failed to check progress');
      return false;
    }

    final List<dynamic> uploadedParts =
        progressResp.data['data']['uploadedParts'] as List;

    // 5️⃣ COMPLETE UPLOAD
    final Response<dynamic> completeResp = await _dio.post(
      'https://your-api.com/v1/vault/resumable/complete',
      options: Options(
        headers: <String, dynamic>{'Authorization': 'Bearer $token'},
      ),
      data: <String, Object>{
        'uploadId': uploadId,
        'key': key,
        'parts': uploadedParts
            .map(
              (p) => <String, dynamic>{
                'partNumber': p['partNumber'],
                'etag': p['etag'],
              },
            )
            .toList(),
        'filename': filename,
        'contentType': contentType,
        'size': fileSize,
        'parentId': parentId,
      },
    );

    if (completeResp.data['success'] == true) {
      print('File uploaded successfully');
      return true;
    } else {
      print('Upload failed: ${completeResp.data['message']}');
      return false;
    }
  }
}
