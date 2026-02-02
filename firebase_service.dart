import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';

import 'local_storage_service.dart';
import 'notification_service.dart';

class FirebaseService {
  static final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> init() async {
    // Set up auth state listener
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        // User signed in
        final token = await user.getIdToken();
        await LocalStorageService.setToken(token);
        
        // Subscribe to company notifications
        final companyId = LocalStorageService.getUser()?.companyId;
        if (companyId != null) {
          await NotificationService.subscribeToTopic('company_$companyId');
        }
        
        // Update FCM token
        final fcmToken = await NotificationService.getToken();
        if (fcmToken != null) {
          await _updateFcmToken(user.uid, fcmToken);
        }
      } else {
        // User signed out
        await LocalStorageService.clearAll();
      }
    });
  }

  static Future<void> _updateFcmToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<firebase_auth.User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  static Stream<QuerySnapshot> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  static Future<void> markNotificationRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }
}
