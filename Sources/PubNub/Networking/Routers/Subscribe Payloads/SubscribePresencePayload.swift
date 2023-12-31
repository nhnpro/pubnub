//
//  SubscribePresencePayload.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

struct SubscribePresencePayload: Codable {
  let occupancy: Int
  let timestamp: Timetoken
  let state: AnyJSON?
  let uuid: String?

  let actionEvent: Action
  let refreshHereNow: Bool

  let join: [String]
  let leave: [String]
  let timeout: [String]

  /// The type of presence change that occurred
  enum Action: String, Codable, Hashable {
    /// Another user has joined the channel
    case join
    /// Another user has explicitly left the channel
    case leave
    /// Another user has timed out on the channel and has left
    case timeout
    /// A user has updated their state
    case stateChange = "state-change"
    /// Multiple presence changes have taken place in a single response
    case interval
  }

  enum CodingKeys: String, CodingKey {
    case action
    case timestamp
    case occupancy

    // Internval Keys
    case join
    case leave
    case timeout

    // State breakdown
    case uuid
    case state = "data"
    case refreshHereNow = "here_now_refresh"
  }

  public init(
    actionEvent: Action,
    occupancy: Int,
    uuid: String?,
    timestamp: Timetoken,
    refreshHereNow: Bool,
    state: AnyJSON?,
    join: [String] = [],
    leave: [String] = [],
    timeout: [String] = []
  ) {
    self.actionEvent = actionEvent
    self.uuid = uuid
    self.occupancy = occupancy
    self.timestamp = timestamp
    self.refreshHereNow = refreshHereNow
    self.state = state
    self.join = join
    self.leave = leave
    self.timeout = timeout
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    actionEvent = try container.decode(Action.self, forKey: .action)
    occupancy = try container.decode(Int.self, forKey: .occupancy)
    timestamp = try container.decode(Timetoken.self, forKey: .timestamp)
    refreshHereNow = try container.decodeIfPresent(Bool.self, forKey: .refreshHereNow) ?? false
    state = try container.decodeIfPresent(AnyJSON.self, forKey: .state)
    uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
    join = try container.decodeIfPresent([String].self, forKey: .join) ?? []
    leave = try container.decodeIfPresent([String].self, forKey: .leave) ?? []
    timeout = try container.decodeIfPresent([String].self, forKey: .timeout) ?? []
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(actionEvent, forKey: .action)
    try container.encode(timestamp, forKey: .timestamp)
    try container.encode(occupancy, forKey: .occupancy)
    try container.encode(refreshHereNow, forKey: .refreshHereNow)
    try container.encodeIfPresent(uuid, forKey: .uuid)
    try container.encodeIfPresent(state, forKey: .state)
    try container.encode(join, forKey: .join)
    try container.encode(leave, forKey: .leave)
    try container.encode(timeout, forKey: .timeout)
  }
}
