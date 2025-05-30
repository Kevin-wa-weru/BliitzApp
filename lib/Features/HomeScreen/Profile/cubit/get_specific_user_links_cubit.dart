import 'package:bliitz/services/link_services.dart';
import 'package:bloc/bloc.dart';

class GetSpecificUserLinksCubit extends Cubit<GetSpecificUserLinksState> {
  GetSpecificUserLinksCubit({
    required LinkServices linkServices,
  }) : super(GetSpecificUserLinksStateInitial()) {
    _linkServices = linkServices;
  }

  late LinkServices _linkServices;

  Future<void> getLinks(String userId) async {
    emit(GetSpecificUserLinksStateLoading());
    var response = await _linkServices.fetchSpecificUserLinks(userId);

    emit(GetSpecificUserLinksStateLoaded(
      response,
    ));
  }

  Future<void> filtertLinksBySocial(String socialType, String userId) async {
    emit(GetSpecificUserLinksStateLoading());

    var response =
        await _linkServices.fetchSpeicifcUserinksBySocial(socialType, userId);
    emit(GetSpecificUserLinksStateLoaded(
      response,
    ));
  }
}

abstract class GetSpecificUserLinksState {}

class GetSpecificUserLinksStateInitial extends GetSpecificUserLinksState {}

class GetSpecificUserLinksStateLoading extends GetSpecificUserLinksState {}

class GetSpecificUserLinksStateLoaded extends GetSpecificUserLinksState {
  GetSpecificUserLinksStateLoaded(
    this.links,
  );
  final List<Map<String, dynamic>> links;
}

class GetSpecificUserLinksStateError extends GetSpecificUserLinksState {
  GetSpecificUserLinksStateError(this.error);

  final String error;
}
