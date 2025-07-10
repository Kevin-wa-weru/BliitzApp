import 'package:bliitz/services/auth_services.dart';
import 'package:bliitz/services/link_services.dart';
import 'package:bloc/bloc.dart';

class GetVisitedProfileDetailsCubit
    extends Cubit<GetVisitedProfileDetailsState> {
  GetVisitedProfileDetailsCubit({
    required LinkServices linkServices,
    required AuthServices authServices,
  }) : super(GetVisitedProfileDetailsStateInitial()) {
    _authServices = authServices;
  }

  late AuthServices _authServices;
  Future<void> getProfileDetails(String userId) async {
    emit(GetVisitedProfileDetailsStateLoading());
    var userDetails = await _authServices.fetchSpecificUserProfile(userId);
    emit(GetVisitedProfileDetailsStateLoaded(
      imageUrl: userDetails!['photoURL'],
      userName: userDetails['name'],
      aboutUser: userDetails['about'],
      isVerified: userDetails['verified'],
      totalFavs: userDetails['totalFavorites'].toString(),
      totalImpressions: userDetails['totalImpressions'].toString(),
      totalCommunities: userDetails['totalCommunities'].toString(),
    ));
  }
}

abstract class GetVisitedProfileDetailsState {}

class GetVisitedProfileDetailsStateInitial
    extends GetVisitedProfileDetailsState {}

class GetVisitedProfileDetailsStateLoading
    extends GetVisitedProfileDetailsState {
  GetVisitedProfileDetailsStateLoading();
}

class GetVisitedProfileDetailsStateLoaded
    extends GetVisitedProfileDetailsState {
  GetVisitedProfileDetailsStateLoaded({
    this.totalFavs,
    this.totalImpressions,
    this.totalCommunities,
    this.imageUrl,
    this.userName,
    this.aboutUser,
    this.isVerified,
    this.isOwnerProfile,
  });
  final String? imageUrl;
  final String? userName;
  final String? aboutUser;
  final bool? isVerified;
  final bool? isOwnerProfile;
  final String? totalImpressions;
  final String? totalFavs;
  final String? totalCommunities;
}

class GetVisitedProfileDetailsStateError extends GetVisitedProfileDetailsState {
  GetVisitedProfileDetailsStateError(this.error);

  final String error;
}
