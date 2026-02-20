import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../data/datasources/remote/firestore_datasource.dart';
import '../../data/datasources/local/sqlite_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';

// ─── FIREBASE PROVIDERS ───────────────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final storageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());

// ─── DATA SOURCE PROVIDERS ────────────────────────────────────────────────────

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource(
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final firestoreDataSourceProvider = Provider<FirestoreDataSource>((ref) {
  return FirestoreDataSource(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider),
  );
});

final sqliteDataSourceProvider = Provider<SQLiteDataSource>((ref) {
  return SQLiteDataSource();
});

// ─── REPOSITORY PROVIDERS ─────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    authDataSource: ref.watch(firebaseAuthDataSourceProvider),
    localDataSource: ref.watch(sqliteDataSourceProvider),
  );
});

// ─── AUTH STATE PROVIDER ──────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.watch(authRepositoryProvider).getCurrentUser();
    },
    loading: () async => null,
    error: (_, __) async => null,
  );
});

// ─── THEME & LOCALE PROVIDERS ─────────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences before use');
});

final localePrefProvider = StateProvider<String>((ref) => 'system');
final themePrefProvider = StateProvider<String>((ref) => 'system');
