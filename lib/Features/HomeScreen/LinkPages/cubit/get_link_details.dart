import 'package:bloc/bloc.dart';

class GetLinkDetailsCubit extends Cubit<GetLinkDetailsState> {
  GetLinkDetailsCubit() : super(GetLinkDetailsStateInitial());

  Future<void> updateLinkDetails(
      String imageUrl, String linkName, String description) async {
    emit(GetLinkDetailsStateLoading());

    emit(GetLinkDetailsStateLoaded(
      imageUrl: imageUrl,
      linkName: linkName,
      aboutLink: description,
    ));
  }
}

abstract class GetLinkDetailsState {}

class GetLinkDetailsStateInitial extends GetLinkDetailsState {}

class GetLinkDetailsStateLoading extends GetLinkDetailsState {}

class GetLinkDetailsStateLoaded extends GetLinkDetailsState {
  GetLinkDetailsStateLoaded({
    this.imageUrl,
    this.linkName,
    this.aboutLink,
  });
  final String? imageUrl;
  final String? linkName;
  final String? aboutLink;
}

class GetLinkDetailsStateError extends GetLinkDetailsState {
  GetLinkDetailsStateError(this.error);

  final String error;
}
