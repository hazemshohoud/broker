import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/notifications_remote_data_source.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required NotificationsRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(const NotificationsState());

  final NotificationsRemoteDataSource _remoteDataSource;
  StreamSubscription? _subscription;
  String? _currentUserId;

  void startListening(String userId) {
    if (_currentUserId == userId && _subscription != null) return;
    _currentUserId = userId;
    _subscription?.cancel();

    emit(state.copyWith(status: NotificationsStatus.loading));
    _subscription = _remoteDataSource.watchNotifications(userId).listen(
      (notifications) {
        emit(state.copyWith(
          status: NotificationsStatus.success,
          notifications: notifications,
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await _remoteDataSource.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId != null) {
      await _remoteDataSource.markAllAsRead(_currentUserId!);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
