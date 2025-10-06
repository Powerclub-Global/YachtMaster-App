import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/analytics_service.dart';

/// Optimized image handling service
class ImageService {
  static const int _maxImageSize = 1920; // Max width/height
  static const int _compressionQuality = 85; // 85% quality
  static const int _thumbnailSize = 300; // Thumbnail size

  /// Compress and upload image with progress tracking
  static Future<ImageUploadResult> compressAndUploadImage({
    required File imageFile,
    required String path,
    Function(double)? onProgress,
  }) async {
    final trace = AnalyticsService.startTrace('image_upload');
    await trace.start();

    try {
      // 1. Compress the image
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        throw Exception('Image compression failed');
      }

      // 2. Generate thumbnail
      final thumbnail = await _generateThumbnail(compressedImage);

      // 3. Upload both images
      final uploadTasks = await Future.wait([
        _uploadToFirebaseStorage(compressedImage, path),
        _uploadToFirebaseStorage(thumbnail, '${path}_thumb'),
      ]);

      await trace.stop();

      return ImageUploadResult.success(
        imageUrl: uploadTasks[0],
        thumbnailUrl: uploadTasks[1],
        originalSize: imageFile.lengthSync(),
        compressedSize: compressedImage.lengthSync(),
      );

    } catch (error, stackTrace) {
      await trace.stop();

      await AnalyticsService.logError(
        'Image upload failed',
        error: error,
        stackTrace: stackTrace,
      );

      return ImageUploadResult.failure(
        error: error.toString(),
      );
    }
  }

  /// Compress image for optimal performance
  static Future<File?> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = file.path.split('/').last;
      final targetPath = '${tempDir.path}/compressed_$fileName';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: _compressionQuality,
        minWidth: _maxImageSize,
        minHeight: _maxImageSize,
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      return null;
    }
  }

  /// Generate thumbnail for fast loading
  static Future<File> _generateThumbnail(File originalFile) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = originalFile.path.split('/').last;
    final thumbnailPath = '${tempDir.path}/thumb_$fileName';

    final result = await FlutterImageCompress.compressAndGetFile(
      originalFile.absolute.path,
      thumbnailPath,
      quality: 70,
      minWidth: _thumbnailSize,
      minHeight: _thumbnailSize,
      format: CompressFormat.jpeg,
    );

    return File(result!.path);
  }

  /// Upload to Firebase Storage with progress tracking
  static Future<String> _uploadToFirebaseStorage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'compressed': 'true',
        },
      ),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Batch upload multiple images
  static Future<List<ImageUploadResult>> batchUploadImages({
    required List<File> imageFiles,
    required String basePath,
    Function(int, double)? onProgress,
  }) async {
    final results = <ImageUploadResult>[];

    for (int i = 0; i < imageFiles.length; i++) {
      final result = await compressAndUploadImage(
        imageFile: imageFiles[i],
        path: '$basePath/image_$i',
        onProgress: (progress) {
          onProgress?.call(i, progress);
        },
      );
      results.add(result);
    }

    return results;
  }

  /// Clean up temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file.path.contains('compressed_') || file.path.contains('thumb_')) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}

/// Image upload result class
class ImageUploadResult {
  final bool success;
  final String? error;
  final String imageUrl;
  final String thumbnailUrl;
  final int originalSize;
  final int compressedSize;

  ImageUploadResult._({
    required this.success,
    this.error,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.originalSize,
    required this.compressedSize,
  });

  factory ImageUploadResult.success({
    required String imageUrl,
    required String thumbnailUrl,
    required int originalSize,
    required int compressedSize,
  }) {
    return ImageUploadResult._(
      success: true,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      originalSize: originalSize,
      compressedSize: compressedSize,
    );
  }

  factory ImageUploadResult.failure({
    required String error,
  }) {
    return ImageUploadResult._(
      success: false,
      error: error,
      imageUrl: '',
      thumbnailUrl: '',
      originalSize: 0,
      compressedSize: 0,
    );
  }

  /// Calculate compression ratio
  double get compressionRatio {
    if (originalSize == 0) return 0;
    return (originalSize - compressedSize) / originalSize;
  }
}
