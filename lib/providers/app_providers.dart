import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
final storageProvider = Provider<FirebaseStorage>((_) => FirebaseStorage.instance);
final messagingProvider = Provider<FirebaseMessaging>((_) => FirebaseMessaging.instance);

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(firebaseAuthProvider)));
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService(ref.watch(firestoreProvider)));
final storageServiceProvider = Provider<StorageService>((ref) => StorageService(ref.watch(storageProvider)));
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService(ref.watch(messagingProvider)));
