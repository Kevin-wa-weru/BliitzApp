import 'package:bliitz/services/sql_services.dart';
import 'package:bloc/bloc.dart';

class GetBackgroundNotificationsCubit
    extends Cubit<GetBackgroundNotificationsState> {
  GetBackgroundNotificationsCubit({
    required BackgroundPersistence backgroundPersistence,
  }) : super(GetBackgroundNotificationsStateInitial()) {
    _backgroundPersistence = backgroundPersistence;
  }

  late BackgroundPersistence _backgroundPersistence;

  Future<void> getBackgroundNotifications() async {
    emit(GetBackgroundNotificationsStateLoading());
    var notificationList =
        await _backgroundPersistence.getAllBackgroundMessages();

    emit(GetBackgroundNotificationsStateLoaded(
        backgroundNotifications: notificationList));
  }
}

abstract class GetBackgroundNotificationsState {}

class GetBackgroundNotificationsStateInitial
    extends GetBackgroundNotificationsState {}

class GetBackgroundNotificationsStateLoading
    extends GetBackgroundNotificationsState {
  GetBackgroundNotificationsStateLoading();
}

class GetBackgroundNotificationsStateLoaded
    extends GetBackgroundNotificationsState {
  GetBackgroundNotificationsStateLoaded({
    required this.backgroundNotifications,
  });
  final List<BackgroundNotification> backgroundNotifications;
}

class GetBackgroundNotificationsStateError
    extends GetBackgroundNotificationsState {
  GetBackgroundNotificationsStateError(this.error);

  final String error;
}
