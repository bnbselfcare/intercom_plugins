import 'package:flutter/services.dart';
import 'package:intercom_ios/src/intercom_api.g.dart';
import 'package:intercom_platform_interface/intercom_platform_interface.dart';

class IosIntercom extends IntercomPlatform {
  final IosIntercomApi _intercomApi = IosIntercomApi();

  /// Registers this class as the default instance of [IntercomPlatform].
  static void registerWith() {
    IntercomPlatform.instance = IosIntercom();
  }

  @override
  Future<void> initialize({required String appId, String? androidApiKey, String? iosApiKey}) {
    if (iosApiKey != null && iosApiKey.isNotEmpty) {
      return _intercomApi.initialize(appId, iosApiKey);
    }
    throw ArgumentError('iosApiKey can not be empty or null');
  }

  @override
  Stream<int> getUnreadStream() {
    return _eventChannelFor().receiveBroadcastStream().cast();
  }

  @override
  Future<void> setUserHash(String userHash) {
    return _intercomApi.setUserHash(userHash);
  }

  @override
  Future<void> loginIdentifiedWithEmail({
    required String email,
    IntercomStatusCallback? statusCallback,
  }) async {
    assert(email.isNotEmpty, 'Email can not empty');
    try {
      await _intercomApi.loginIdentifiedUserWithEmail(email);
      return statusCallback?.onSuccess?.call();
    } on PlatformException catch(e) {
      return statusCallback?.onFailure?.call(convertExceptionToIntercomError(e));
    }
  }

  @override
  Future<void> loginIdentifiedWithUserId({
    required String userId,
    IntercomStatusCallback? statusCallback,
  }) async {
    assert(userId.isNotEmpty, 'UserId can not empty');
    try {
      await _intercomApi.loginIdentifiedWithUserId(userId);
      return statusCallback?.onSuccess?.call();
    } on PlatformException catch(e) {
      return statusCallback?.onFailure?.call(convertExceptionToIntercomError(e));
    }
  }

  @override
  Future<void> loginIdentifiedUser({
    required String userId,
    required String email,
    IntercomStatusCallback? statusCallback,
  }) async {
    assert(email.isNotEmpty, 'Email can not empty');
    assert(userId.isNotEmpty, 'UserId can not empty');
    try {
      await _intercomApi.loginIdentifiedWithUserIdAndEmail(userId, email);
      return statusCallback?.onSuccess?.call();
    } on PlatformException catch(e) {
      return statusCallback?.onFailure?.call(convertExceptionToIntercomError(e));
    }
  }

  @override
  Future<void> loginUnidentifiedUser({IntercomStatusCallback? statusCallback}) async {
    try {
      await _intercomApi.loginUnidentifiedUser();
      return statusCallback?.onSuccess?.call();
    } on PlatformException catch (e) {
      return statusCallback?.onFailure?.call(convertExceptionToIntercomError(e));
    }
  }

  @override
  Future<void> logout() {
    return _intercomApi.logout();
  }

  @override
  Future<void> setLauncherVisibility(IntercomVisibility visibility) {
    Visibility launcherVisibility = switch (visibility) {
      IntercomVisibility.visible => Visibility.visible,
      IntercomVisibility.gone => Visibility.gone,
    };
    return _intercomApi.setLauncherVisibility(launcherVisibility);
  }

  @override
  Future<int> unreadConversationCount() {
    return _intercomApi.unreadConversationCount();
  }

  @override
  Future<void> setInAppMessagesVisibility(IntercomVisibility visibility) {
    Visibility inAppMessagesVisibility = switch (visibility) {
      IntercomVisibility.visible => Visibility.visible,
      IntercomVisibility.gone => Visibility.gone,
    };
    return _intercomApi.setInAppMessagesVisibility(inAppMessagesVisibility);
  }

  @override
  Future<void> displayMessenger() {
    return _intercomApi.displayMessenger();
  }

  @override
  Future<void> hideMessenger() {
    return _intercomApi.hideMessenger();
  }

  @override
  Future<void> displayHelpCenter() {
    return _intercomApi.displayHelpCenter();
  }

  @override
  Future<void> displayHelpCenterCollections(List<String> collectionIds) {
    return _intercomApi.displayHelpCenterCollections(collectionIds);
  }

  @override
  Future<void> displayMessages() {
    return _intercomApi.displayMessages();
  }

  @override
  Future<void> logEvent(String name, [Map<String, Object?>? metaData]) {
    if (metaData != null) {
      return _intercomApi.logEventWithMetaData(name, metaData);
    }
    return _intercomApi.logEvent(name);
  }

  @override
  Future<void> sendTokenToIntercom(String token) {
    assert(token.isNotEmpty, 'Token can not empty');
    return _intercomApi.sendTokenToIntercom(token);
  }

  @override
  Future<void> handlePushMessage() {
    return _intercomApi.handlePushMessage();
  }

  @override
  Future<void> displayMessageComposer(String message) {
    return _intercomApi.displayMessageComposer(message);
  }

  @override
  Future<bool> isIntercomPush(Map<String, String> message) async {
    return _intercomApi.isIntercomPush(message);
  }

  @override
  Future<void> handlePush(Map<String, String> message) {
    return _intercomApi.handlePush(message);
  }

  @override
  Future<void> setBottomPadding(int padding) {
    return _intercomApi.setBottomPadding(padding);
  }

  @override
  Future<void> displayArticle(String articleId) {
    return _intercomApi.displayArticle(articleId);
  }

  @override
  Future<void> displayCarousel(String carouselId) {
    return _intercomApi.displayCarousel(carouselId);
  }

  @override
  Future<void> displaySurvey(String surveyId) {
    return _intercomApi.displaySurvey(surveyId);
  }

  EventChannel _eventChannelFor() {
    return const EventChannel('dev.flutter.pigeon.IosIntercomApi.getUnreadStream');
  }
}
