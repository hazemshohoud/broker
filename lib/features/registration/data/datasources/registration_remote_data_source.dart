import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/utils/auth_credentials.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/registration_request.dart';
import '../models/registration_model.dart';

abstract class RegistrationRemoteDataSource {
  Future<void> submit(RegistrationRequest request);
}

class RegistrationRemoteDataSourceImpl implements RegistrationRemoteDataSource {
  RegistrationRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required CloudinaryService cloudinaryService,
  }) : _auth = auth,
       _firestore = firestore,
       _cloudinaryService = cloudinaryService;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;

  /// ينشئ مستخدم Firebase Auth (رقم الهاتف كإيميل والـ PIN كباسورد)
  /// ويحفظ طلب التسجيل في `registrations/{uid}`، وبعدين يسجل خروج —
  /// الحساب مش بيشتغل غير لما الإدارة تحوّل status لـ "approved".
  @override
  Future<void> submit(RegistrationRequest request) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: AuthCredentials.emailForPhone(request.phone),
        password: AuthCredentials.passwordForPin(request.pin),
      );
      final isAdmin = AuthRemoteDataSourceImpl.adminPhones.contains(request.phone.trim());
      try {
        final photoUrl = await _uploadPhoto(request.photoPath);
        await _firestore
            .collection('registrations')
            .doc(credential.user!.uid)
            .set(request.toMap(photoUrl: photoUrl, isAdmin: isAdmin));
      } finally {
        await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(
        e.code == 'email-already-in-use'
            ? 'رقم الهاتف مسجل بالفعل'
            : e.message ?? 'فشل إرسال طلب التسجيل',
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل إرسال طلب التسجيل');
    }
  }

  /// يرفع الصورة إلى Cloudinary في مجلد registration_photos
  Future<String?> _uploadPhoto(String? photoPath) async {
    if (photoPath == null) return null;
    return _cloudinaryService.uploadImage(
      photoPath,
      folder: 'registration_photos',
    );
  }
}
