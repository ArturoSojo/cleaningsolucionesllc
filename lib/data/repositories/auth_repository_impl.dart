import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/remote/firebase_auth_datasource.dart';
import '../datasources/local/sqlite_datasource.dart';
import '../../core/constants/app_constants.dart';

class AuthRepositoryImpl {
  final FirebaseAuthDataSource _authDataSource;
  final SQLiteDataSource _localDataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required SQLiteDataSource localDataSource,
  })  : _authDataSource = authDataSource,
        _localDataSource = localDataSource;

  Stream<User?> get authStateChanges => _authDataSource.authStateChanges;

  Future<UserEntity> signInWithGoogle() async {
    final user = await _authDataSource.signInWithGoogle();
    await _localDataSource.setPreference(AppConstants.keyUserId, user.id);
    await _localDataSource.setPreference(AppConstants.keyUserRole, user.role);
    return user;
  }

  Future<UserEntity?> getCurrentUser() async {
    return _authDataSource.getCurrentUserData();
  }

  Future<void> signOut() async {
    await _authDataSource.signOut();
    await _localDataSource.deletePreference(AppConstants.keyUserId);
    await _localDataSource.deletePreference(AppConstants.keyUserRole);
  }

  Future<String?> getCachedUserId() async {
    return _localDataSource.getPreference(AppConstants.keyUserId);
  }

  Future<String?> getCachedUserRole() async {
    return _localDataSource.getPreference(AppConstants.keyUserRole);
  }
}
