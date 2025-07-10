import 'package:bliitz/services/link_services.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetLinksCubit extends Cubit<GetLinksState> {
  GetLinksCubit({
    required LinkServices linkServices,
  }) : super(GetLinksStateInitial()) {
    _linkServices = linkServices;
  }

  late LinkServices _linkServices;

  Future<void> getLinks(
      String currentpage, bool isUserLinks, String socialType) async {
    emit(GetLinksStateLoading());

    if (socialType == 'Facebook') {
      var response = await _linkServices.fetchUserFeedFromCloud(
          limit: 20, fetchFirstSocial: true);
      emit(GetLinksStateLoaded(response, currentPage: currentpage));
    } else {
      var response = await _linkServices.fetchUserFeedFromCloud(
          limit: 20, fetchFirstSocial: false);
      emit(GetLinksStateLoaded(response, currentPage: currentpage));
    }
  }

  Future<void> filtertLinksByType(
      String filterType, String currentpage, bool isUserLinks) async {
    emit(GetLinksStateLoading());

    List<Map<String, dynamic>> response = [];
    if (filterType == 'All') {
      response = await _linkServices.fetchLinks(isUserLinks);
    }
    if (filterType == 'Channels') {
      response = await _linkServices.fetchLinksByType('Channel');
    }
    if (filterType == 'Groups') {
      response = await _linkServices.fetchLinksByType('Group');
    }
    if (filterType == 'Pages') {
      response = await _linkServices.fetchLinksByType('Page');
    }

    emit(GetLinksStateLoaded(response, currentPage: currentpage));
  }

  Future<void> filtertLinksBySocial(
      String socialType, String currentpage, bool isUserLinks) async {
    emit(GetLinksStateLoading());

    var response =
        await _linkServices.fetchLinksBySocial(socialType, isUserLinks);
    emit(GetLinksStateLoaded(
      response,
      currentPage: currentpage,
    ));
  }

  Future<void> filtertLinksByCateogry(
      String category, String currentpage, bool isUserLinks) async {
    emit(GetLinksStateLoading());

    var response =
        await _linkServices.fetchLinksByCategory(category, isUserLinks);
    emit(GetLinksStateLoaded(response, currentPage: currentpage));
  }

  Future<void> getFavourites(
    String social,
    String currentpage,
  ) async {
    emit(GetLinksStateLoading());
    if (social == 'All Socials') {
      var response = await _linkServices.fetchFavoritedGroups(
          userId: FirebaseAuth.instance.currentUser!.uid);
      emit(GetLinksStateLoaded(response, currentPage: currentpage));
    }
  }
}

abstract class GetLinksState {}

class GetLinksStateInitial extends GetLinksState {}

class GetLinksStateLoading extends GetLinksState {}

class GetLinksStateLoaded extends GetLinksState {
  GetLinksStateLoaded(this.links, {this.currentPage});
  final List<Map<String, dynamic>> links;
  final String? currentPage;
}

class GetLinksStateError extends GetLinksState {
  GetLinksStateError(this.error);

  final String error;
}
