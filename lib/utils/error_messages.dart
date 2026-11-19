import 'package:supabase_flutter/supabase_flutter.dart';

const permissionDeniedMessage = "You don't have permission to do that.";

bool isPermissionDenied(Object error) {
  if (error is PostgrestException) {
    final message = error.message.toLowerCase();
    return error.code == '42501' ||
        error.code == 'PGRST301' ||
        message.contains('permission denied') ||
        message.contains('row-level security');
  }
  if (error is StorageException) {
    final message = error.message.toLowerCase();
    return error.statusCode == '401' ||
        error.statusCode == '403' ||
        message.contains('row-level security') ||
        message.contains('unauthorized');
  }
  return false;
}

String friendlyError(Object error) {
  if (isPermissionDenied(error)) return permissionDeniedMessage;

  if (error is PostgrestException) {
    switch (error.code) {
      case '23505':
        return 'That name is already used. Try a different one.';
      case '23503':
        return 'This item is still linked to other records, so it cannot be removed.';
      case 'PGRST116':
        return 'That item no longer exists, or you are not allowed to change it.';
    }
    return error.message;
  }
  if (error is StorageException) return error.message;
  if (error is AuthException) return error.message;

  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('Failed host lookup') ||
      text.contains('XMLHttpRequest')) {
    return 'Could not reach the server. Check your connection and try again.';
  }
  return text.replaceFirst('Exception: ', '');
}
