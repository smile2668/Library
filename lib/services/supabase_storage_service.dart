import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseStorageClient get _storage => Supabase.instance.client.storage;

  /// Uploads binary data to [bucket] at [path] and returns the public URL.
  Future<String> _upload({
    required String bucket,
    required String path,
    required XFile file,
    String? contentType,
  }) async {
    final bytes = await file.readAsBytes();
    await _storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType ?? file.mimeType,
          ),
        );
    return _storage.from(bucket).getPublicUrl(path);
  }

  /// Uploads an image [XFile] to [bucket] at [path] and returns the public URL.
  Future<String> uploadImage({
    required String bucket,
    required String path,
    required XFile file,
  }) =>
      _upload(bucket: bucket, path: path, file: file);

  /// Uploads any file [XFile] to [bucket] at [path] and returns the public URL.
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required XFile file,
  }) =>
      _upload(bucket: bucket, path: path, file: file);

  /// Deletes a file from [bucket] at [path].
  Future<void> deleteFile({required String bucket, required String path}) async {
    await _storage.from(bucket).remove([path]);
  }
}
