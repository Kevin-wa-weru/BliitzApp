import 'package:bliitz/services/link_services.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetOwnersLinksCubit extends Cubit<GetOwnersLinksState> {
  GetOwnersLinksCubit({
    required LinkServices linkServices,
  }) : super(GetOwnersLinksStateInitial()) {
    _linkServices = linkServices;
  }

  late LinkServices _linkServices;

  Future<void> getLinks(
    String socialType,
  ) async {
    emit(GetOwnersLinksStateLoading());
    final userId = FirebaseAuth.instance.currentUser?.uid;
    var response = await _linkServices.fetchSpecificUserLinks(userId!);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('totalCommunities', response.length.toString());
    if (socialType == 'Facebook') {
      var facebookLinks =
          response.where((link) => link['socialType'] == 'Facebook').toList();
      emit(GetOwnersLinksStateLoaded(
        facebookLinks,
      ));
    } else {
      emit(GetOwnersLinksStateLoaded(
        response,
      ));
    }
  }

  Future<void> filtertLinksBySocial(
    String socialType,
  ) async {
    emit(GetOwnersLinksStateLoading());
    final userId = FirebaseAuth.instance.currentUser?.uid;
    var response =
        await _linkServices.fetchSpeicifcUserinksBySocial(socialType, userId!);
    emit(GetOwnersLinksStateLoaded(
      response,
    ));
  }
}

abstract class GetOwnersLinksState {}

class GetOwnersLinksStateInitial extends GetOwnersLinksState {}

class GetOwnersLinksStateLoading extends GetOwnersLinksState {}

class GetOwnersLinksStateLoaded extends GetOwnersLinksState {
  GetOwnersLinksStateLoaded(
    this.links,
  );
  final List<Map<String, dynamic>> links;
}

class GetOwnersLinksStateError extends GetOwnersLinksState {
  GetOwnersLinksStateError(this.error);

  final String error;
}
