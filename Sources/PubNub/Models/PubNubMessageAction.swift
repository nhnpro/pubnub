//
//  PubNubMessageAction.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

// MARK: Outbound Protocol

/// A protocol that represents a PubNub Message Action
public protocol PubNubMessageAction {
  /// The type of action
  var actionType: String { get }
  /// The value that cooresponds to the type
  var actionValue: String { get }
  /// The `Timetoken` for this specific action
  var actionTimetoken: Timetoken { get }
  /// The `Timetoken` for the message this action relates to
  var messageTimetoken: Timetoken { get }
  /// The publisher of the message action
  var publisher: String { get }
  /// The channel the action (and message) were sent on
  var channel: String { get }
  /// The subscription match string potentionally used
  var subscription: String? { get }
  /// The `Timetoken` for when the publish event was received from PubNub
  var published: Timetoken? { get }

  /// Allows for converting between different MessageEvent types
  init(from other: PubNubMessageAction) throws
}

public extension PubNubMessageAction {
  /// Converts this protocol into a custom type
  /// - Parameter into: The explicit type for the returned value
  /// - Returns: The protocol intiailized as a custom type
  /// - Throws: An error why the custom type was unable to be created using this protocol instance
  func transcode<T: PubNubMessageAction>(into _: T.Type) throws -> T {
    return try transcode()
  }

  /// Converts this protocol into a custom type
  /// - Returns: The protocol intiailized as a custom type
  /// - Throws: An error why the custom type was unable to be created using this protocol instance
  func transcode<T: PubNubMessageAction>() throws -> T {
    // Check if we're already that object, and return
    if let custom = self as? T {
      return custom
    }

    return try T(from: self)
  }
}

// MARK: Concrete Base Class

/// The default implementation of the `PubNubMessageAction` protocol
public struct PubNubMessageActionBase: PubNubMessageAction, Codable, Hashable {
  /// The type of action
  public let actionType: String
  /// The value that cooresponds to the type
  public let actionValue: String
  /// The `Timetoken` for this specific action
  public let actionTimetoken: Timetoken
  /// The `Timetoken` for the message this action relates to
  public let messageTimetoken: Timetoken
  /// The publisher of the message action
  public let publisher: String
  /// The channel the action (and message) were sent on
  public let channel: String
  /// The subscription match string potentionally used
  public let subscription: String?
  /// The `Timetoken` for when the publish event was received from PubNub
  public let published: Timetoken?

  /// Allows for converting between different MessageEvent types
  public init(from other: PubNubMessageAction) throws {
    self.init(
      actionType: other.actionType,
      actionValue: other.actionValue,
      actionTimetoken: other.actionTimetoken,
      messageTimetoken: other.messageTimetoken,
      publisher: other.publisher,
      channel: other.channel,
      subscription: other.subscription,
      published: other.published
    )
  }

  /// Attempts to create a PubNubMessageAction from a Subscription Response Message
  init?(from subscribe: SubscribeMessagePayload) {
    guard let messageAction = try? subscribe.payload.decode(SubscribeMessageActionPayload.self),
          let publisher = subscribe.publisher
    else {
      return nil
    }

    self.init(
      actionType: messageAction.actionType,
      actionValue: messageAction.actionValue,
      actionTimetoken: messageAction.actionTimetoken,
      messageTimetoken: messageAction.messageTimetoken,
      publisher: publisher,
      channel: subscribe.channel,
      subscription: subscribe.subscription,
      published: subscribe.publishTimetoken.timetoken
    )
  }

  /// Attempts to create a PubNubMessageAction from a Subscription Response Message
  init(from payload: MessageActionPayload, on channel: String) {
    self.init(
      actionType: payload.type,
      actionValue: payload.value,
      actionTimetoken: payload.actionTimetoken,
      messageTimetoken: payload.messageTimetoken,
      publisher: payload.uuid,
      channel: channel
    )
  }

  /// Default init
  public init(
    actionType: String,
    actionValue: String,
    actionTimetoken: Timetoken,
    messageTimetoken: Timetoken,
    publisher: String,
    channel: String,
    subscription: String? = nil,
    published: Timetoken? = nil
  ) {
    self.actionType = actionType
    self.actionValue = actionValue
    self.actionTimetoken = actionTimetoken
    self.messageTimetoken = messageTimetoken
    self.publisher = publisher
    self.channel = channel
    self.subscription = subscription
    self.published = published
  }
}

extension Array where Element == PubNubMessageActionBase {
  init(
    raw actions: [String: [String: [MessageHistoryMessageAction]]],
    message timetoken: Timetoken,
    on channel: String
  ) {
    var baseActions = [PubNubMessageActionBase]()

    actions.forEach { actionType, actionValues in
      actionValues.forEach { actionValue, actionUsersAndTimes in
        actionUsersAndTimes.forEach { actionUserAndTime in
          baseActions.append(
            PubNubMessageActionBase(
              actionType: actionType,
              actionValue: actionValue,
              actionTimetoken: actionUserAndTime.actionTimetoken,
              messageTimetoken: timetoken,
              publisher: actionUserAndTime.uuid,
              channel: channel
            )
          )
        }
      }
    }

    self.init(baseActions)
  }
}
