import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/intercom_api.g.dart',
    swiftOptions: SwiftOptions(),
    swiftOut: 'ios/Classes/IntercomApi.g.swift',
  ),
)
enum Visibility {
  visible,
  gone;
}

@HostApi()
abstract class IosIntercomApi {

  void initialize(
    String appId,
    String apiKey,
  );

  void setUserHash(String userHash);

  @async
  void loginIdentifiedUserWithEmail(String email);

  @async
  void loginIdentifiedWithUserIdAndEmail(String userId, String email);

  @async
  void loginIdentifiedWithUserId(String userId);

  @async
  void loginUnidentifiedUser();

  void logout();

  void setLauncherVisibility(Visibility visibility);

  @async
  int unreadConversationCount();

  void setInAppMessagesVisibility(Visibility visibility);

  void displayMessenger();

  void hideMessenger();

  void displayHelpCenter();

  void displayHelpCenterCollections(List<String> collectionIds);

  void displayMessages();

  void logEvent(String name);

  void logEventWithMetaData(String name, Map<String, Object?> metaData);

  void sendTokenToIntercom(String token);

  void handlePushMessage();

  void displayMessageComposer(String message);

  @async
  bool isIntercomPush(Map<String, String> message);

  void handlePush(Map<String, String> message);

  void setBottomPadding(int padding);

  void displayArticle(String articleId);

  void displayCarousel(String carouselId);

  void displaySurvey(String surveyId);
}
