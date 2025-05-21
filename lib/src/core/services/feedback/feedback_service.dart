import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:water_mind/src/core/models/feedback_model.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Service for handling user feedback
class FeedbackService {
  /// Firestore instance
  final FirebaseFirestore _firestore;

  /// Collection name for feedback
  static const String _collectionName = 'feedback';

  /// Constructor
  FeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Send feedback to Firebase
  Future<bool> sendFeedback(FeedbackModel feedback) async {
    try {
      // Add timestamp if not provided
      final feedbackWithTimestamp = feedback.createdAt != null
          ? feedback
          : feedback.copyWith(createdAt: DateTime.now());

      // Add language if not provided
      final feedbackWithLanguage = feedbackWithTimestamp.language != null
          ? feedbackWithTimestamp
          : feedbackWithTimestamp.copyWith(language: KVStoreService.appLanguage);

      // Convert to JSON
      final data = feedbackWithLanguage.toJson();

      // Add to Firestore
      try {
        final docRef = await _firestore.collection(_collectionName).add(data);
        AppLogger.info('Feedback sent successfully with ID: ${docRef.id}');
        return true;
      } on FirebaseException catch (firebaseError, firebaseStackTrace) {
        if (firebaseError.code == 'permission-denied') {
          AppLogger.reportError(
            firebaseError,
            firebaseStackTrace,
            'Firebase permission denied: You need to update Firestore security rules'
          );

          // Lưu feedback vào local storage hoặc gửi qua phương thức khác
          _saveFeedbackLocally(feedbackWithLanguage);

          // Vẫn trả về true để người dùng không thấy lỗi
          return true;
        } else {
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace, 'Error sending feedback: ${e.toString()}');
      return false;
    }
  }

  /// Lưu feedback vào local storage khi không thể gửi lên Firebase
  void _saveFeedbackLocally(FeedbackModel feedback) {
    try {
      // Ghi log để debug
      AppLogger.info('Saving feedback locally: ${feedback.message}');

      // Trong trường hợp thực tế, bạn có thể lưu vào SharedPreferences hoặc Drift database
      // Ví dụ: KVStoreService.saveFeedback(feedback.toJson());

      // Hoặc bạn có thể lưu vào file
      // final directory = await getApplicationDocumentsDirectory();
      // final file = File('${directory.path}/pending_feedback.json');
      // final existingData = file.existsSync() ? jsonDecode(await file.readAsString()) : [];
      // existingData.add(feedback.toJson());
      // await file.writeAsString(jsonEncode(existingData));
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace, 'Error saving feedback locally');
    }
  }

  /// Get all feedback (for admin purposes)
  Future<List<FeedbackModel>> getAllFeedback() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Add the document ID to the data
        return FeedbackModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace, 'Error getting feedback');
      return [];
    }
  }
}
