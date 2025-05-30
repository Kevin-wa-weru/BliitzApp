part of '_index.dart';

class Singletons {
  static final _linkService = LinkServicesImpl();
  static final _authService = AuthServicesImpl();
  static final _backgroundPersistence = BackgroundPersistence();
  static List<BlocProvider> registerCubits() => [
        BlocProvider<GetOwnersLinksCubit>(
          create: (context) => GetOwnersLinksCubit(linkServices: _linkService),
        ),
        BlocProvider<GetLinksCubit>(
          create: (context) => GetLinksCubit(linkServices: _linkService),
        ),
        BlocProvider<GetProfileDetailsCubit>(
          create: (context) => GetProfileDetailsCubit(
              linkServices: _linkService, authServices: _authService),
        ),
        BlocProvider<GetFovoritedLinksCubit>(
          create: (context) => GetFovoritedLinksCubit(
            linkServices: _linkService,
          ),
        ),
        BlocProvider<GetLinkDetailsCubit>(
          create: (context) => GetLinkDetailsCubit(),
        ),
        BlocProvider<GetSpecificUserLinksCubit>(
          create: (context) =>
              GetSpecificUserLinksCubit(linkServices: _linkService),
        ),
        BlocProvider<GetLinksInCategoriesPageCubit>(
          create: (context) =>
              GetLinksInCategoriesPageCubit(linkServices: _linkService),
        ),
        BlocProvider<GetSearchResultsCubit>(
          create: (context) =>
              GetSearchResultsCubit(linkServices: _linkService),
        ),
        BlocProvider<GetBackgroundNotificationsCubit>(
          create: (context) => GetBackgroundNotificationsCubit(
              backgroundPersistence: _backgroundPersistence),
        ),
        BlocProvider<GetMighLikeLinksCubit>(
          create: (context) =>
              GetMighLikeLinksCubit(linkServices: _linkService),
        ),
        BlocProvider<GetVisitedProfileDetailsCubit>(
          create: (context) => GetVisitedProfileDetailsCubit(
              linkServices: _linkService, authServices: _authService),
        ),
      ];
}
