import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../home/data/models/compound_model.dart';
import '../../../home/data/models/developer_model.dart';
import '../../../home/data/models/filter_options_model.dart';
import '../../../home/data/models/offer_model.dart';
import '../../../home/domain/entities/compound.dart';
import '../../../home/domain/entities/developer.dart';
import '../../../home/domain/entities/filter_options.dart';
import '../../../home/domain/entities/offer.dart';
import '../../domain/entities/admin_commission.dart';
import '../../domain/entities/admin_registration.dart';
import '../../domain/entities/admin_viewing_request.dart';
import '../../domain/entities/admin_withdrawal.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminRegistration>> getRegistrations();
  Future<void> updateRegistrationStatus(String id, String status);
  Future<void> deleteRegistration(String id);

  Future<List<Compound>> getCompounds();
  Future<void> saveCompound(Compound compound, {bool isNew = false});
  Future<void> deleteCompound(String id);

  Future<List<Developer>> getDevelopers();
  Future<void> saveDeveloper({
    String? id,
    required String name,
    String? logoUrl,
    String? description,
    String? phone,
    String? whatsapp,
    int order = 0,
  });
  Future<void> deleteDeveloper(String id);

  Future<List<AdminViewingRequest>> getViewingRequests();
  Future<void> updateViewingRequestStatus(String id, String status);

  Future<List<AdminCommission>> getCommissions();
  Future<void> updateCommissionStatus(String id, String status);

  Future<List<Offer>> getOffers();
  Future<void> saveOffer({
    String? id,
    required String title,
    String? imageUrl,
    int order = 0,
  });
  Future<void> deleteOffer(String id);

  Future<List<AdminWithdrawal>> getWithdrawals();
  Future<void> updateWithdrawalStatus(String id, String status);

  Future<void> grantCommission({
    required String brokerId,
    required double amount,
    required String title,
    required String status,
  });

  Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    String? brokerId,
  });

  Future<FilterOptions> getFilterOptions();
  Future<void> saveFilterOptions(FilterOptions options);

  Future<String> uploadImage(String filePath, {String? folder});
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  AdminRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required CloudinaryService cloudinaryService,
  })  : _firestore = firestore,
        _cloudinaryService = cloudinaryService;

  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;

  @override
  Future<List<AdminRegistration>> getRegistrations() async {
    try {
      final snapshot = await _firestore.collection('registrations').get();
      final list = <AdminRegistration>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawBirth = data['birthDate'];
        final birthDate = rawBirth is Timestamp
            ? rawBirth.toDate()
            : DateTime.tryParse(rawBirth?.toString() ?? '') ?? DateTime(1990);
        final rawCreated = data['createdAt'];
        final createdAt = rawCreated is Timestamp
            ? rawCreated.toDate()
            : DateTime.now();

        list.add(
          AdminRegistration(
            id: doc.id,
            fullName: data['fullName']?.toString() ?? '',
            birthDate: birthDate,
            governorate: data['governorate']?.toString() ?? '',
            phone: data['phone']?.toString() ?? '',
            whatsapp: data['whatsapp']?.toString() ?? '',
            status: data['status']?.toString() ?? 'pending',
            createdAt: createdAt,
            instaPayNumber: data['instaPayNumber']?.toString(),
            walletNumber: data['walletNumber']?.toString(),
            photoUrl: data['photoUrl']?.toString(),
          ),
        );
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحميل طلبات التسجيل');
    }
  }

  @override
  Future<void> updateRegistrationStatus(String id, String status) async {
    try {
      await _firestore.collection('registrations').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // إرسال إشعار فوري للوسيط
      if (status == 'approved') {
        await _firestore.collection('notifications').add({
          'userId': id,
          'title': 'تمت الموافقة على انضمامك! 🎉',
          'body': 'تهانينا! تم اعتماد وتفعيل حسابك كوسيط رسمي في منصة بروكر. يمكنك الآن بدء تصفح المشروعات والعمولات.',
          'type': 'registration_approved',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else if (status == 'rejected') {
        await _firestore.collection('notifications').add({
          'userId': id,
          'title': 'تحديث بخصوص طلب الانضمام',
          'body': 'تمت مراجعة طلب انضمامك ولم يتم قبوله حالياً أو يحتاج لمراجعة إضافية من الإدارة.',
          'type': 'registration_rejected',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحديث حالة الحساب');
    }
  }

  @override
  Future<void> deleteRegistration(String id) async {
    try {
      await _firestore.collection('registrations').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل حذف الحساب');
    }
  }

  @override
  Future<List<Compound>> getCompounds() async {
    try {
      final snapshot = await _firestore.collection('compounds').get();
      return snapshot.docs.map(CompoundModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحميل الكمبوندات');
    }
  }

  @override
  Future<void> saveCompound(Compound compound, {bool isNew = false}) async {
    try {
      final data = <String, dynamic>{
        'name': compound.name,
        'location': compound.location,
        'developerName': compound.developerName,
        'developerStartPrice': compound.developerStartPrice,
        'resaleStartPrice': compound.resaleStartPrice,
        'commission': compound.commission,
        'propertyTypes': compound.propertyTypes,
        'phone': compound.phone,
        'whatsapp': compound.whatsapp ?? compound.phone,
        'imageUrl': compound.allImages.firstOrNull ?? compound.imageUrl,
        'imageUrls': compound.allImages,
        'developerLogoUrl': compound.developerLogoUrl,
        'isProject': compound.isProject,
        'projectImageUrl': compound.projectImageUrl,
        'region': compound.region,
        'district': compound.district,
        'readiness': compound.readiness,
        'finishing': compound.finishing,
        'area': compound.area,
        'deliveryDate': compound.deliveryDate,
        'mapUrl': compound.mapUrl,
        'latitude': compound.latitude,
        'longitude': compound.longitude,
        'amenities': compound.amenities,
        'faqs': compound.faqs,
        'attachments': compound.attachments,
      };

      if (isNew || compound.id.isEmpty) {
        final docRef = compound.id.isNotEmpty
            ? _firestore.collection('compounds').doc(compound.id)
            : _firestore.collection('compounds').doc();
        await docRef.set(data);
      } else {
        await _firestore.collection('compounds').doc(compound.id).set(
              data,
              SetOptions(merge: true),
            );
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل حفظ الكمبوند');
    }
  }

  @override
  Future<void> deleteCompound(String id) async {
    try {
      await _firestore.collection('compounds').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل حذف الكمبوند');
    }
  }

  @override
  Future<List<Developer>> getDevelopers() async {
    try {
      final snapshot = await _firestore.collection('developers').get();
      final list = snapshot.docs.map(DeveloperModel.fromFirestore).toList();
      return list;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحميل المطورين');
    }
  }

  @override
  Future<void> saveDeveloper({
    String? id,
    required String name,
    String? logoUrl,
    String? description,
    String? phone,
    String? whatsapp,
    int order = 0,
  }) async {
    try {
      final docRef = (id != null && id.isNotEmpty)
          ? _firestore.collection('developers').doc(id)
          : _firestore.collection('developers').doc();
      await docRef.set({
        'name': name,
        'logoUrl': logoUrl,
        'description': description,
        'phone': phone,
        'whatsapp': whatsapp,
        'order': order,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل حفظ المطور');
    }
  }

  @override
  Future<void> deleteDeveloper(String id) async {
    try {
      await _firestore.collection('developers').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل حذف المطور');
    }
  }

  @override
  Future<List<AdminViewingRequest>> getViewingRequests() async {
    try {
      final snapshot = await _firestore.collection('viewing_requests').get();
      final list = <AdminViewingRequest>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawViewing = data['viewingDate'];
        final viewingDate = rawViewing is Timestamp
            ? rawViewing.toDate()
            : DateTime.tryParse(rawViewing?.toString() ?? '') ?? DateTime.now();
        final rawCreated = data['createdAt'];
        final createdAt = rawCreated is Timestamp
            ? rawCreated.toDate()
            : DateTime.now();

        list.add(
          AdminViewingRequest(
            id: doc.id,
            brokerId: data['brokerId']?.toString(),
            brokerName: data['brokerName']?.toString() ?? 'وسيط',
            brokerPhone: data['brokerPhone']?.toString(),
            brokerEmail: data['brokerEmail']?.toString(),
            compoundId: data['compoundId']?.toString(),
            compoundName: data['compoundName']?.toString() ?? '',
            developerName: data['developerName']?.toString(),
            location: data['location']?.toString(),
            clientName: data['clientName']?.toString() ?? '',
            clientPhone: data['clientPhone']?.toString() ?? '',
            viewingDate: viewingDate,
            notes: data['notes']?.toString(),
            status: data['status']?.toString() ?? 'pending',
            createdAt: createdAt,
          ),
        );
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحميل طلبات المعاينة');
    }
  }

  @override
  Future<void> updateViewingRequestStatus(String id, String status) async {
    try {
      final doc = await _firestore.collection('viewing_requests').doc(id).get();
      final data = doc.data();
      final brokerId = data?['brokerId']?.toString();
      final compoundName = data?['compoundName']?.toString() ?? '';

      await _firestore.collection('viewing_requests').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (brokerId != null && brokerId.isNotEmpty) {
        final (title, body) = switch (status) {
          'approved' => (
              'تمت الموافقة على موعد المعاينة 🗓️',
              'تمت الموافقة وتأكيد موعد المعاينة لمشروع $compoundName من الإدارة.',
            ),
          'completed' => (
              'اكتملت المعاينة بنجاح ✅',
              'تم تأكيد إتمام المعاينة لمشروع $compoundName.',
            ),
          'cancelled' => (
              'تم إلغاء طلب المعاينة ❌',
              'تم إلغاء موعد المعاينة لمشروع $compoundName من قبل الإدارة.',
            ),
          _ => (
              'تحديث في طلب المعاينة 🗓️',
              'تم تحديث حالة طلب معاينة $compoundName إلى "$status".',
            ),
        };

        await _firestore.collection('notifications').add({
          'userId': brokerId,
          'title': title,
          'body': body,
          'type': 'general',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحديث طلب المعاينة');
    }
  }

  @override
  Future<List<AdminCommission>> getCommissions() async {
    try {
      final snapshot = await _firestore.collection('commissions').get();
      final regDocs = await _firestore.collection('registrations').get();
      final brokerNames = <String, String>{};
      final brokerPhones = <String, String>{};
      for (final r in regDocs.docs) {
        final d = r.data();
        brokerNames[r.id] = d['fullName']?.toString() ?? '';
        brokerPhones[r.id] = d['phone']?.toString() ?? '';
      }

      final list = <AdminCommission>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawCreated = data['createdAt'];
        final createdAt = rawCreated is Timestamp
            ? rawCreated.toDate()
            : DateTime.now();
        final brokerId = data['brokerId']?.toString() ?? '';

        list.add(
          AdminCommission(
            id: doc.id,
            brokerId: brokerId,
            brokerName: brokerNames[brokerId],
            brokerPhone: brokerPhones[brokerId],
            amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
            title: data['title']?.toString() ?? data['compoundName']?.toString() ?? 'عمولة بيع',
            compoundName: data['compoundName']?.toString(),
            status: data['status']?.toString() ?? 'approved',
            createdAt: createdAt,
          ),
        );
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحميل العمولات');
    }
  }

  @override
  Future<void> updateCommissionStatus(String id, String status) async {
    try {
      final doc = await _firestore.collection('commissions').doc(id).get();
      final data = doc.data();
      final brokerId = data?['brokerId']?.toString();
      final amount = (data?['amount'] as num?)?.toDouble() ?? 0.0;
      final title = data?['title']?.toString() ?? '';

      await _firestore.collection('commissions').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (brokerId != null && brokerId.isNotEmpty && status == 'approved') {
        final amountFormatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

        await _firestore.collection('notifications').add({
          'userId': brokerId,
          'title': 'تم اعتماد عمولتك بنجاح! 💰',
          'body': 'تمت الموافقة على عمولتك بقيمة $amountFormatted جم ${title.isNotEmpty ? "عن $title" : ""} وأصبحت متاحة في رصيدك للسحب.',
          'type': 'commission',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحديث حالة العمولة');
    }
  }

  @override
  Future<List<Offer>> getOffers() async {
    try {
      final snapshot = await _firestore.collection('offers').get();
      return snapshot.docs.map(OfferModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحميل العروض');
    }
  }

  @override
  Future<void> saveOffer({
    String? id,
    required String title,
    String? imageUrl,
    int order = 0,
  }) async {
    try {
      final docRef = id != null && id.isNotEmpty
          ? _firestore.collection('offers').doc(id)
          : _firestore.collection('offers').doc();
      await docRef.set({
        'title': title,
        'imageUrl': imageUrl,
        'order': order,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل حفظ العرض');
    }
  }

  @override
  Future<void> deleteOffer(String id) async {
    try {
      await _firestore.collection('offers').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل حذف العرض');
    }
  }

  @override
  Future<List<AdminWithdrawal>> getWithdrawals() async {
    try {
      final snapshot = await _firestore.collection('withdrawal_requests').get();
      final list = <AdminWithdrawal>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawCreated = data['createdAt'];
        final createdAt = rawCreated is Timestamp
            ? rawCreated.toDate()
            : DateTime.now();

        final method = data['method'];
        String methodType = 'wallet';
        String methodNumber = data['methodNumber']?.toString() ?? data['number']?.toString() ?? '';
        if (method is Map) {
          methodType = method['type']?.toString() ?? 'wallet';
          if (methodNumber.isEmpty) {
            methodNumber = method['number']?.toString() ?? '';
          }
        } else if (method is String) {
          methodType = method;
        }

        list.add(
          AdminWithdrawal(
            id: doc.id,
            brokerId: data['brokerId']?.toString() ?? '',
            amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
            methodType: methodType,
            methodNumber: methodNumber,
            status: data['status']?.toString() ?? 'pending',
            createdAt: createdAt,
          ),
        );
      }

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحميل طلبات السحب');
    }
  }

  @override
  Future<void> updateWithdrawalStatus(String id, String status) async {
    try {
      final doc = await _firestore.collection('withdrawal_requests').doc(id).get();
      final data = doc.data();
      final brokerId = data?['brokerId']?.toString();
      final amount = (data?['amount'] as num?)?.toDouble() ?? 0.0;
      final amountFormatted = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );

      await _firestore.collection('withdrawal_requests').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (brokerId != null && brokerId.isNotEmpty) {
        final (title, body) = switch (status) {
          'completed' => (
              'تم تحويل مبلغ السحب بنجاح 💳',
              'تم تأكيد تحويل مبلغ $amountFormatted جم لحسابك بنجاح.',
            ),
          'approved' => (
              'تمت الموافقة على طلب السحب ⏳',
              'تمت الموافقة على طلب سحب $amountFormatted جم وجارٍ تنفيذ التحويل.',
            ),
          'rejected' => (
              'تم رفض طلب السحب ⚠️',
              'تم رفض طلب سحب $amountFormatted جم وأُعيد المبلغ لرصيدك المتاح.',
            ),
          _ => (
              'تحديث في طلب السحب 💳',
              'تم تحديث حالة طلب السحب إلى "$status".',
            ),
        };

        await _firestore.collection('notifications').add({
          'userId': brokerId,
          'title': title,
          'body': body,
          'type': 'withdrawal',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحديث طلب السحب');
    }
  }

  @override
  Future<void> grantCommission({
    required String brokerId,
    required double amount,
    required String title,
    required String status,
  }) async {
    try {
      await _firestore.collection('commissions').add({
        'brokerId': brokerId,
        'amount': amount,
        'title': title,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final amountFormatted = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );

      // إرسال إشعار فوري للوسيط
      await _firestore.collection('notifications').add({
        'userId': brokerId,
        'title': 'تم إسناد عمولة جديدة لك 💰',
        'body': 'تمت إضافة عمولة جديدة بقيمة $amountFormatted جم إلى محفظتك ${title.isNotEmpty ? "عن $title" : ""}.',
        'type': 'commission',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل إسناد العمولة');
    }
  }

  @override
  Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    String? brokerId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': brokerId ?? 'all',
        'title': title,
        'body': body,
        'type': 'general',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل إرسال الإشعار');
    }
  }

  @override
  Future<FilterOptions> getFilterOptions() async {
    try {
      final doc = await _firestore.collection('config').doc('filter_options').get();
      if (!doc.exists) return const FilterOptions();
      return FilterOptionsModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل تحميل خيارات التصفية');
    }
  }

  @override
  Future<void> saveFilterOptions(FilterOptions options) async {
    try {
      final regionsData = options.regions
          .map((r) => {
                'name': r.name,
                'districts': r.districts,
              })
          .toList();

      await _firestore.collection('config').doc('filter_options').set({
        'propertyTypes': options.propertyTypes,
        'regions': regionsData,
        'readinessStatuses': options.readinessStatuses,
        'finishings': options.finishings,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'فشل حفظ خيارات التصفية');
    }
  }

  @override
  Future<String> uploadImage(String filePath, {String? folder}) async {
    try {
      final url = await _cloudinaryService.uploadImage(
        filePath,
        folder: folder ?? 'admin_uploads',
      );
      if (url == null) throw const ServerException('فشل رفع الصورة');
      return url;
    } catch (e) {
      throw ServerException('فشل رفع الصورة إلى السحابة: $e');
    }
  }
}
