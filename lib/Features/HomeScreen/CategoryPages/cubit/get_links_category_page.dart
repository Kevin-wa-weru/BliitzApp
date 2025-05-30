import 'package:bliitz/services/link_services.dart';
import 'package:bloc/bloc.dart';

class GetLinksInCategoriesPageCubit
    extends Cubit<GetLinksInCategoriesPageState> {
  GetLinksInCategoriesPageCubit({
    required LinkServices linkServices,
  }) : super(GetLinksInCategoriesPageStateInitial()) {
    _linkServices = linkServices;
  }

  late LinkServices _linkServices;

  Future<void> filtertLinksBySocialAndCatgory(
    String socialType,
    String category,
  ) async {
    emit(GetLinksInCategoriesPageStateLoading());
    var response = await _linkServices.filtertLinksBySocialAndCatgory(
      category,
      socialType,
    );
    emit(GetLinksInCategoriesPageStateLoaded(
      response,
    ));
  }
}

abstract class GetLinksInCategoriesPageState {}

class GetLinksInCategoriesPageStateInitial
    extends GetLinksInCategoriesPageState {}

class GetLinksInCategoriesPageStateLoading
    extends GetLinksInCategoriesPageState {}

class GetLinksInCategoriesPageStateLoaded
    extends GetLinksInCategoriesPageState {
  GetLinksInCategoriesPageStateLoaded(
    this.links,
  );
  final List<Map<String, dynamic>> links;
}

class GetLinksInCategoriesPageStateError extends GetLinksInCategoriesPageState {
  GetLinksInCategoriesPageStateError(this.error);

  final String error;
}
