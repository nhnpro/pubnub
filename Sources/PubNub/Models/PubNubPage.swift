//
//  PubNubPage.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

// MARK: - Bounded Page

/// A response page that is bounded by one or more Timetokens
public protocol PubNubBoundedPage {
  /// The start value for the next set of remote data
  var start: Timetoken? { get }
  /// The bounded end value that will be eventually fetched to
  var end: Timetoken? { get }
  /// The previous limiting value (if any)
  var limit: Int? { get }

  /// Allows for converting  between different PubNubBoundedPage types
  init(from other: PubNubBoundedPage) throws
}

public extension PubNubBoundedPage {
  /// Converts this protocol into a custom type
  /// - Parameter into: The explicit type for the returned value
  /// - Returns: The protocol intiailized as a custom type
  /// - Throws: An error why the custom type was unable to be created using this protocol instance
  func transcode<T: PubNubBoundedPage>(into _: T.Type) throws -> T {
    return try transcode()
  }

  /// Converts this protocol into a custom type
  /// - Returns: The protocol intiailized as a custom type
  /// - Throws: An error why the custom type was unable to be created using this protocol instance
  func transcode<T: PubNubBoundedPage>() throws -> T {
    // Check if we're already that object, and return
    if let custom = self as? T {
      return custom
    }

    return try T(from: self)
  }
}

// MARK: Concrete Base Class

/// The default implementation of the `PubNubBoundedPage` protocol
public struct PubNubBoundedPageBase: PubNubBoundedPage, Codable, Hashable {
  public let start: Timetoken?
  public let end: Timetoken?
  public let limit: Int?

  public init?(start: Timetoken? = nil, end: Timetoken? = nil, limit: Int? = nil) {
    if start == nil, end == nil, limit == nil {
      return nil
    }

    self.start = start
    self.end = end
    self.limit = limit
  }

  public init(from other: PubNubBoundedPage) throws {
    start = other.start
    end = other.end
    limit = other.limit
  }
}

// MARK: - Hashed Page

/// A cursor for the next page of a remote data
public protocol PubNubHashedPage {
  /// The hash value representing the netxt set of data
  var start: String? { get }
  /// The hash value representing the previous set of data
  var end: String? { get }
  /// The total count of all objects withing range
  var totalCount: Int? { get }

  /// Allows for converting  between different PubNubHashedPage types
  init(from other: PubNubHashedPage) throws
}

public extension PubNubHashedPage {
  /// Converts this protocol into a custom type
  /// - Parameter into: The explicit type for the returned value
  /// - Returns: The protocol intiailized as a custom type
  /// - Throws: An error why the custom type was unable to be created using this protocol instance
  func transcode<T: PubNubHashedPage>(into _: T.Type) throws -> T {
    return try transcode()
  }

  /// Converts this protocol into a custom type
  /// - Returns: The protocol intiailized as a custom type
  /// - Throws: An error why the custom type was unable to be created using this protocol instance
  func transcode<T: PubNubHashedPage>() throws -> T {
    // Check if we're already that object, and return
    if let custom = self as? T {
      return custom
    }

    return try T(from: self)
  }

  /// Convenience to align with the `next` parameter of certain APIs
  ///
  /// This is the same as calling `start`
  var next: String? {
    return start
  }

  /// Convenience to align with the `prev` parameter of certain APIs
  ///
  /// This is the same as calling `end`
  var prev: String? {
    return end
  }
}

// MARK: Concrete Base Class

/// The default implementation of the `PubNubHashedPage` protocol
public struct PubNubHashedPageBase: PubNubHashedPage, Codable, Hashable {
  public var start: String?
  public var end: String?
  public var totalCount: Int?

  public init(
    start: String? = nil,
    end: String? = nil,
    totalCount: Int? = nil
  ) {
    self.start = start
    self.end = end
    self.totalCount = totalCount
  }

  public init(from other: PubNubHashedPage) throws {
    self.init(
      start: other.start,
      end: other.end,
      totalCount: other.totalCount
    )
  }
}

// MARK: Other Internal Extensions

extension PubNubChannelsMetadataResponsePayload: PubNubHashedPage {
  public var start: String? {
    return next
  }

  public var end: String? {
    return prev
  }

  public init(from other: PubNubHashedPage) throws {
    self.init(
      status: 200, data: [],
      totalCount: other.totalCount, next: other.start, prev: other.end
    )
  }
}

extension PubNubMembershipsResponsePayload: PubNubHashedPage {
  public var start: String? {
    return next
  }

  public var end: String? {
    return prev
  }

  public init(from other: PubNubHashedPage) throws {
    self.init(
      status: 200, data: [],
      totalCount: other.totalCount, next: other.start, prev: other.end
    )
  }
}

extension FetchMultipleResponse: PubNubHashedPage {
  public var start: String? {
    return next
  }

  public var end: String? {
    return prev
  }

  public init(from other: PubNubHashedPage) throws {
    self.init(
      status: 200, data: [],
      totalCount: other.totalCount, next: other.start, prev: other.end
    )
  }
}
