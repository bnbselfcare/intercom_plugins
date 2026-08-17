package com.igniscor.plugins.intercom

import android.app.Application
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.intercom.android.sdk.Intercom
import io.intercom.android.sdk.IntercomContent
import io.intercom.android.sdk.IntercomError
import io.intercom.android.sdk.IntercomSpace
import io.intercom.android.sdk.IntercomStatusCallback
import io.intercom.android.sdk.UnreadConversationCountListener
import io.intercom.android.sdk.identity.Registration
import io.intercom.android.sdk.push.IntercomPushClient

class IntercomAndroidPlugin : FlutterPlugin, AndroidIntercomApi, EventChannel.StreamHandler {

    private var application: Application? = null
    private val intercomPushClient = IntercomPushClient()
    private var unreadConversationCountListener: UnreadConversationCountListener? = null
    private var eventChannel: EventChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AndroidIntercomApi.setUp(binding.binaryMessenger, this)
        application = binding.applicationContext as Application
        eventChannel = EventChannel(
            binding.binaryMessenger,
            "dev.flutter.pigeon.AndroidIntercomApi.getUnreadStream"
        )
        eventChannel?.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        application = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        unreadConversationCountListener?.let {
            Intercom.client().removeUnreadConversationCountListener(it)
        }
        AndroidIntercomApi.setUp(binding.binaryMessenger, null)
    }

    override fun initialize(appId: String, androidApiKey: String) {
        Intercom.initialize(application, androidApiKey, appId)
    }

    override fun setUserHash(userHash: String) {
        Intercom.client().setUserHash(userHash)
    }

    override fun loginIdentifiedUserWithEmail(email: String, callback: (Result<Unit>) -> Unit) {
        Intercom.client().loginIdentifiedUser(
            Registration.create().withEmail(email),
            object : IntercomStatusCallback {
                override fun onFailure(intercomError: IntercomError) {
                    callback.invoke(Result.failure(convertIntercomErrorToFlutter(intercomError)))
                }

                override fun onSuccess() {
                    callback.invoke(Result.success(Unit))
                }
            })
    }

    override fun loginIdentifiedWithUserIdAndEmail(
        userId: String,
        email: String,
        callback: (Result<Unit>) -> Unit
    ) {
        Intercom.client().loginIdentifiedUser(
            Registration.create().withEmail(email).withUserId(userId),
            object : IntercomStatusCallback {
                override fun onFailure(intercomError: IntercomError) {
                    callback.invoke(Result.failure(convertIntercomErrorToFlutter(intercomError)))
                }

                override fun onSuccess() {
                    callback.invoke(Result.success(Unit))
                }
            })
    }

    override fun loginIdentifiedWithUserId(userId: String, callback: (Result<Unit>) -> Unit) {
        Intercom.client().loginIdentifiedUser(
            Registration.create().withUserId(userId),
            object : IntercomStatusCallback {
                override fun onFailure(intercomError: IntercomError) {
                    callback.invoke(Result.failure(convertIntercomErrorToFlutter(intercomError)))
                }

                override fun onSuccess() {
                    callback.invoke(Result.success(Unit))
                }
            })
    }

    override fun loginUnidentifiedUser(callback: (Result<Unit>) -> Unit) {
        Intercom.client().loginUnidentifiedUser(object : IntercomStatusCallback {
            override fun onFailure(intercomError: IntercomError) {
                callback.invoke(Result.failure(convertIntercomErrorToFlutter(intercomError)))
            }

            override fun onSuccess() {
                callback.invoke(Result.success(Unit))
            }
        })
    }

    override fun logout() {
        Intercom.client().logout()
    }

    override fun setLauncherVisibility(visibility: Visibility) {
        val intercomVisibility = when (visibility) {
            Visibility.VISIBLE -> Intercom.Visibility.VISIBLE
            Visibility.GONE -> Intercom.Visibility.GONE
        }
        Intercom.client().setLauncherVisibility(intercomVisibility)
    }

    override fun unreadConversationCount(callback: (Result<Long>) -> Unit) {
        val unreadConversationCount: Long = Intercom.client().unreadConversationCount.toLong()
        callback.invoke(Result.success(unreadConversationCount))
    }

    override fun setInAppMessagesVisibility(visibility: Visibility) {
        val intercomVisibility = when (visibility) {
            Visibility.VISIBLE -> Intercom.Visibility.VISIBLE
            Visibility.GONE -> Intercom.Visibility.GONE
        }
        Intercom.client().setInAppMessageVisibility(intercomVisibility)
    }

    override fun displayMessenger() {
        Intercom.client().present()
    }

    override fun hideMessenger() {
        Intercom.client().hideIntercom()
    }

    override fun displayHelpCenter() {
        Intercom.client().present(IntercomSpace.HelpCenter)
    }

    override fun displayHelpCenterCollections(collectionIds: List<String>) {
        Intercom.client().presentContent(IntercomContent.HelpCenterCollections(collectionIds))
    }

    override fun displayMessages() {
        Intercom.client().present(IntercomSpace.Messages)
    }

    override fun logEvent(name: String) {
        Intercom.client().logEvent(name)
    }

    override fun logEventWithMetaData(name: String, metaData: Map<String, Any?>) {
        Intercom.client().logEvent(name, metaData)
    }

    override fun sendTokenToIntercom(token: String) {
        intercomPushClient.sendTokenToIntercom(application!!, token)
    }

    override fun handlePushMessage() {
        Intercom.client().handlePushMessage()
    }

    override fun displayMessageComposer(message: String) {
        Intercom.client().displayMessageComposer(message)
    }

    override fun isIntercomPush(message: Map<String, String>, callback: (Result<Boolean>) -> Unit) {
        callback.invoke(Result.success(intercomPushClient.isIntercomPush(message)))
    }

    override fun handlePush(message: Map<String, String>) {
        intercomPushClient.handlePush(application!!, message)
    }

    override fun setBottomPadding(padding: Long) {
        Intercom.client().setBottomPadding(padding.toInt())
    }

    override fun displayArticle(articleId: String) {
        Intercom.client().presentContent(IntercomContent.Article(articleId))
    }

    override fun displayCarousel(carouselId: String) {
        Intercom.client().presentContent(IntercomContent.Carousel(carouselId))
    }

    override fun displaySurvey(surveyId: String) {
        Intercom.client().presentContent(IntercomContent.Survey(surveyId))
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        unreadConversationCountListener =
            UnreadConversationCountListener { count -> events?.success(count) }
                .also {
                    Intercom.client().addUnreadConversationCountListener(it)
                }
    }

    override fun onCancel(arguments: Any?) {
        if (unreadConversationCountListener != null) {
            Intercom.client().removeUnreadConversationCountListener(unreadConversationCountListener)
        }
    }

    private fun convertIntercomErrorToFlutter(error: IntercomError): FlutterError {
        val code = error.errorCode
        val message = error.errorMessage
        val details = mapOf(
            "errorCode" to code,
            "errorMessage" to message,
        )
        return FlutterError(code.toString(), message, details)
    }
}
