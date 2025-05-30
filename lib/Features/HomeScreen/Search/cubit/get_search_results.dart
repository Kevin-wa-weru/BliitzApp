import 'package:bliitz/services/link_services.dart';
import 'package:bloc/bloc.dart';

class GetSearchResultsCubit extends Cubit<GetSearchResultsState> {
  GetSearchResultsCubit({
    required LinkServices linkServices,
  }) : super(GetSearchResultsStateInitial()) {
    _linkServices = linkServices;
  }

  late LinkServices _linkServices;

  Future<void> getSearchResults(String query) async {
    emit(GetSearchResultsStateLoading());
    var response = await _linkServices.searchLinks(query);

    emit(GetSearchResultsStateLoaded(
      response,
    ));
  }

  resetState() {
    emit(GetSearchResultsStateInitial());
  }
}

abstract class GetSearchResultsState {}

class GetSearchResultsStateInitial extends GetSearchResultsState {}

class GetSearchResultsStateLoading extends GetSearchResultsState {}

class GetSearchResultsStateLoaded extends GetSearchResultsState {
  GetSearchResultsStateLoaded(
    this.links,
  );
  final List<Map<String, dynamic>> links;
}

class GetSearchResultsStateError extends GetSearchResultsState {
  GetSearchResultsStateError(this.error);

  final String error;
}
