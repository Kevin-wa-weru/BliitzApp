import 'package:bliitz/services/auth_services.dart';
import 'package:bliitz/services/link_services.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetProfileDetailsCubit extends Cubit<GetProfileDetailsState> {
  GetProfileDetailsCubit({
    required LinkServices linkServices,
    required AuthServices authServices,
  }) : super(GetProfileDetailsStateInitial()) {
    _authServices = authServices;
  }

  late AuthServices _authServices;
  Future<void> getProfileDetails(bool isOwnerPage) async {
    emit(GetProfileDetailsStateLoading(
      isOwnerProfile: isOwnerPage,
    ));
    var userDetails = await _authServices.fetchUserProfile();
    if (userDetails == null) {
      emit(GetProfileDetailsStateLoaded(
        isOwnerProfile: isOwnerPage,
        imageUrl: FirebaseAuth.instance.currentUser?.photoURL,
        userName: FirebaseAuth.instance.currentUser?.displayName,
        aboutUser: null,
        isVerified: false,
      ));
    } else {
      emit(GetProfileDetailsStateLoaded(
        isOwnerProfile: isOwnerPage,
        imageUrl: FirebaseAuth.instance.currentUser?.photoURL,
        userName: FirebaseAuth.instance.currentUser?.displayName,
        aboutUser: userDetails['about'],
        isVerified: userDetails['isVerified'],
      ));
    }
  }

  Future<void> getProfileWithoutBio(
      String? bio, bool isVerified, bool isOwnerPage) async {
    emit(GetProfileDetailsStateLoading(isOwnerProfile: isOwnerPage));
    if (bio == null) {
      emit(GetProfileDetailsStateLoaded(
        isOwnerProfile: isOwnerPage,
        imageUrl: FirebaseAuth.instance.currentUser?.photoURL,
        userName: FirebaseAuth.instance.currentUser?.displayName,
        aboutUser: '',
        isVerified: isVerified,
      ));
    } else {
      emit(GetProfileDetailsStateLoaded(
        isOwnerProfile: isOwnerPage,
        imageUrl: FirebaseAuth.instance.currentUser?.photoURL,
        userName: FirebaseAuth.instance.currentUser?.displayName,
        aboutUser: bio,
        isVerified: isVerified,
      ));
    }
  }

  Future<void> getSpecificUserProfileDetails(
      bool isOwnerPage, String userId) async {
    emit(GetProfileDetailsStateLoading(
      isOwnerProfile: isOwnerPage,
    ));
    var userDetails = await _authServices.fetchSpecificUserProfile(userId);

    if (userDetails == null) {
      emit(GetProfileDetailsStateLoaded(
        isOwnerProfile: isOwnerPage,
        imageUrl: FirebaseAuth.instance.currentUser?.photoURL,
        userName: FirebaseAuth.instance.currentUser?.displayName,
        aboutUser: null,
        isVerified: false,
      ));
    } else {
      emit(GetProfileDetailsStateLoaded(
        isOwnerProfile: isOwnerPage,
        imageUrl: FirebaseAuth.instance.currentUser?.photoURL,
        userName: FirebaseAuth.instance.currentUser?.displayName,
        aboutUser: userDetails['about'],
        isVerified: userDetails['isVerified'],
      ));
    }
  }
}

abstract class GetProfileDetailsState {}

class GetProfileDetailsStateInitial extends GetProfileDetailsState {}

class GetProfileDetailsStateLoading extends GetProfileDetailsState {
  GetProfileDetailsStateLoading({required this.isOwnerProfile});
  final bool isOwnerProfile;
}

class GetProfileDetailsStateLoaded extends GetProfileDetailsState {
  GetProfileDetailsStateLoaded({
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
}

class GetProfileDetailsStateError extends GetProfileDetailsState {
  GetProfileDetailsStateError(this.error);

  final String error;
}
