import 'package:bliitz/services/link_services.dart';
import 'package:bloc/bloc.dart';

class GetFovoritedLinksCubit extends Cubit<GetFovoritedLinksState> {
  GetFovoritedLinksCubit({
    required LinkServices linkServices,
  }) : super(GetFovoritedLinksStateInitial()) {
    _linkServices = linkServices;
  }

  late LinkServices _linkServices;

  Future<void> getFavourites({
    required String social,
    required bool isFilter,
    required String userId,
  }) async {
    emit(GetFovoritedLinksStateLoading(isFilter: isFilter));
    if (social == 'All Socials') {
      var response = await _linkServices.fetchFavoritedGroups(userId: userId);
      emit(GetFovoritedLinksStateLoaded(response, isFilter: isFilter));
    } else {
      var response = await _linkServices.fetchFavoritedLinksBySocial(social);
      emit(GetFovoritedLinksStateLoaded(response, isFilter: isFilter));
    }
  }
}

abstract class GetFovoritedLinksState {}

class GetFovoritedLinksStateInitial extends GetFovoritedLinksState {}

class GetFovoritedLinksStateLoading extends GetFovoritedLinksState {
  GetFovoritedLinksStateLoading({this.isFilter});
  final bool? isFilter;
}

class GetFovoritedLinksStateLoaded extends GetFovoritedLinksState {
  GetFovoritedLinksStateLoaded(this.links, {this.isFilter});
  final List<Map<String, dynamic>> links;
  final bool? isFilter;
}

class GetFovoritedLinksStateError extends GetFovoritedLinksState {
  GetFovoritedLinksStateError(this.error);

  final String error;
}
