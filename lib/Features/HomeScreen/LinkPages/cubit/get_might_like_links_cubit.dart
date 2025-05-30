import 'package:bliitz/services/link_services.dart';
import 'package:bloc/bloc.dart';

class GetMighLikeLinksCubit extends Cubit<GetMighLikeLinksState> {
  GetMighLikeLinksCubit({
    required LinkServices linkServices,
  }) : super(GetMighLikeLinksStateInitial()) {
    _linkServices = linkServices;
  }

  late LinkServices _linkServices;

  Future<void> getLinks(Map<String, dynamic> currentLinkDetails) async {
    emit(GetMighLikeLinksStateLoading());
    var response = await _linkServices.fetchYouMightAlsoLikeLinks(
      currentLinkId: currentLinkDetails['id'],
      category: currentLinkDetails['Category'],
      searchKeywords: currentLinkDetails['searchKeywords'] ?? [],
      uploaderId: currentLinkDetails['createdBy'],
    );

    emit(GetMighLikeLinksStateLoaded(
      response,
    ));
  }
}

abstract class GetMighLikeLinksState {}

class GetMighLikeLinksStateInitial extends GetMighLikeLinksState {}

class GetMighLikeLinksStateLoading extends GetMighLikeLinksState {}

class GetMighLikeLinksStateLoaded extends GetMighLikeLinksState {
  GetMighLikeLinksStateLoaded(
    this.links,
  );
  final List<Map<String, dynamic>> links;
}

class GetMighLikeLinksStateError extends GetMighLikeLinksState {
  GetMighLikeLinksStateError(this.error);

  final String error;
}
