import Flutter
import Intercom
import UIKit

extension FlutterError: Error {}

public class UnreadStreamHandler : NSObject, FlutterStreamHandler {
    
    private var unread : Any?

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        events(Intercom.unreadConversationCount())
        unread = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.IntercomUnreadConversationCountDidChange,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            events(Intercom.unreadConversationCount())
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if(unread != nil) {
            NotificationCenter.default.removeObserver(unread as Any)
        }
        return nil
    }
}

public class IntercomIosPlugin: NSObject, FlutterPlugin, IosIntercomApi {
    
    private static var eventChannel: FlutterEventChannel? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let api : IosIntercomApi & NSObjectProtocol = IntercomIosPlugin()
        let unreadStreamHandler = UnreadStreamHandler()
        IosIntercomApiSetup.setUp(binaryMessenger: messenger, api: api)
        eventChannel = FlutterEventChannel(name: "dev.flutter.pigeon.IosIntercomApi.getUnreadStream", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(unreadStreamHandler)
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        IntercomIosPlugin.eventChannel?.setStreamHandler(nil)
        IntercomIosPlugin.eventChannel = nil
        IosIntercomApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
    }
    
    func initialize(appId: String, apiKey: String) throws {
        return Intercom.setApiKey(apiKey, forAppId: appId)
    }
    
    func setUserHash(userHash: String) throws {
        return Intercom.setUserHash(userHash)
    }
    
    func loginIdentifiedUserWithEmail(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let attributes = ICMUserAttributes()
        attributes.email = email
        
        Intercom.loginUser(with: attributes) { result in
            switch result {
            case .success(): completion(Result.success(Void()))
            case .failure(let error as NSError): completion(Result.failure(convertIntercomErrorToFlutter(error: error)))
            }
        }
    }
    
    func loginIdentifiedWithUserIdAndEmail(userId: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let attributes = ICMUserAttributes()
        attributes.userId = userId
        attributes.email = email
        
        return Intercom.loginUser(with: attributes) { result in
            switch result {
            case .success(): completion(Result.success(Void()))
            case .failure(let error as NSError): completion(Result.failure(convertIntercomErrorToFlutter(error: error)))
            }
        }
    }
    
    func loginIdentifiedWithUserId(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let attributes = ICMUserAttributes()
        attributes.userId = userId
        
        Intercom.loginUser(with: attributes) { result in
            switch result {
            case .success(): completion(Result.success(Void()))
            case .failure(let error as NSError): completion(Result.failure(convertIntercomErrorToFlutter(error: error)))
            }
        }
    }
    
    func loginUnidentifiedUser(completion: @escaping (Result<Void, Error>) -> Void) {
        return Intercom.loginUnidentifiedUser(){ result in
            switch result {
            case .success(): completion(Result.success(Void()))
            case .failure(let error as NSError): completion(Result.failure(convertIntercomErrorToFlutter(error: error)))
            }
        }
    }
    
    func logout() throws {
        return Intercom.logout()
    }
    
    func setLauncherVisibility(visibility: Visibility) throws {
        return Intercom.setLauncherVisible(Visibility.visible == visibility)
    }
    
    func unreadConversationCount(completion: @escaping (Result<Int64, Error>) -> Void) {
        let unreadConversationCount: UInt = Intercom.unreadConversationCount()
        completion(Result.success(Int64(unreadConversationCount)))
    }
    
    func setInAppMessagesVisibility(visibility: Visibility) throws {
        return Intercom.setInAppMessagesVisible(Visibility.visible == visibility)
    }
    
    func displayMessenger() throws {
        return Intercom.present()
    }

    func hideMessenger() throws {
        return Intercom.hide()
    }
    
    func displayHelpCenter() throws {
        return Intercom.present(Space.helpCenter)
    }
    
    func displayHelpCenterCollections(collectionIds: [String]) throws {
        return Intercom.presentContent(Intercom.Content.helpCenterCollections(ids: collectionIds))
    }
    
    func displayMessages() throws {
        return Intercom.present(Space.messages)
    }
    
    func logEvent(name: String) throws {
        return Intercom.logEvent(withName: name)
    }
    
    func logEventWithMetaData(name: String, metaData: [String : Any?]) throws {
        return Intercom.logEvent(withName: name, metaData: metaData as [AnyHashable : Any])
    }
    
    func sendTokenToIntercom(token: String) throws {
        return Intercom.setDeviceToken(token.data(using: .utf8)!)
    }
    
    func handlePushMessage() throws {
        //No op
    }
    
    func displayMessageComposer(message: String) throws {
        return Intercom.presentMessageComposer(message)
    }
    
    func isIntercomPush(message: [String : String], completion: @escaping (Result<Bool, Error>) -> Void) {
        return completion(Result.success(Intercom.isIntercomPushNotification(message)))
    }
    
    func handlePush(message: [String : String]) throws {
        return Intercom.handlePushNotification(message)
    }
    
    func setBottomPadding(padding: Int64) throws {
        return Intercom.setBottomPadding(CGFloat(padding))
    }
    
    func displayArticle(articleId: String) throws {
        return Intercom.presentContent(Intercom.Content.article(id: articleId))
    }
    
    func displayCarousel(carouselId: String) throws {
        return Intercom.presentContent(Intercom.Content.carousel(id: carouselId))
    }
    
    func displaySurvey(surveyId: String) throws {
        return Intercom.presentContent(Intercom.Content.survey(id: surveyId))
    }
}


func convertIntercomErrorToFlutter(error: NSError) -> FlutterError {
    let code = error.code
    let message = error.localizedDescription
    
    let details : NSMutableDictionary = NSMutableDictionary.init();
    details["errorCode"] = code
    details["errorMessage"] = message
    
    return FlutterError(code: String(code), message: message, details: details)
}
