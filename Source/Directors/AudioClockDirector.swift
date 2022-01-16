//
//  AudioClockDirector.swift
//  SwiftAudioPlayer
//
//  Created by Tanha Kabir on 2019-01-29.
//  Copyright © 2019 Tanha Kabir, Jon Mercer
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import CoreMedia
import Foundation

class AudioClockDirector {
  static let shared = AudioClockDirector()
  private var currentAudioKey: Key?

  private var depNeedleClosures: DirectorThreadSafeClosuresDeprecated<Needle> =
    DirectorThreadSafeClosuresDeprecated()
  private var depDurationClosures: DirectorThreadSafeClosuresDeprecated<Duration> =
    DirectorThreadSafeClosuresDeprecated()
  private var depPlayingStatusClosures: DirectorThreadSafeClosuresDeprecated<SAPlayingStatus> =
    DirectorThreadSafeClosuresDeprecated()
  private var depBufferClosures: DirectorThreadSafeClosuresDeprecated<SAAudioAvailabilityRange> =
    DirectorThreadSafeClosuresDeprecated()

  private var needleClosures: DirectorThreadSafeClosures<Needle> = DirectorThreadSafeClosures()
  private var durationClosures: DirectorThreadSafeClosures<Duration> = DirectorThreadSafeClosures()
  private var playingStatusClosures: DirectorThreadSafeClosures<SAPlayingStatus> =
    DirectorThreadSafeClosures()
  private var bufferClosures: DirectorThreadSafeClosures<SAAudioAvailabilityRange> =
    DirectorThreadSafeClosures()

  private init() {}

  func setKey(_ key: Key) {
    currentAudioKey = key
  }

  func resetCache() {
    Task {
      await needleClosures.resetCache()
      await durationClosures.resetCache()
      await playingStatusClosures.resetCache()
      await bufferClosures.resetCache()
    }
  }

  func clear() {
    depNeedleClosures.clear()
    depDurationClosures.clear()
    depPlayingStatusClosures.clear()
    depBufferClosures.clear()

    Task {
      await needleClosures.clear()
      await durationClosures.clear()
      await playingStatusClosures.clear()
      await bufferClosures.clear()
    }
  }

  // MARK: - Attaches

  // Needle
  func attachToChangesInNeedle(closure: @escaping (Needle) throws -> Void) async -> UInt {
    return await needleClosures.attach(closure: closure)
  }

  // Duration
  func attachToChangesInDuration(closure: @escaping (Duration) throws -> Void) async -> UInt {
    return await durationClosures.attach(closure: closure)
  }

  // Playing status
  @available(
    *, deprecated, message: "Use subscribe without key in the closure for current audio updates"
  )
  func attachToChangesInPlayingStatus(closure: @escaping (Key, SAPlayingStatus) throws -> Void)
    -> UInt
  {
    return depPlayingStatusClosures.attach(closure: closure)
  }

  func attachToChangesInPlayingStatus(closure: @escaping (SAPlayingStatus) throws -> Void) async -> UInt {
    return await playingStatusClosures.attach(closure: closure)
  }

  // Buffer
  @available(
    *, deprecated, message: "Use subscribe without key in the closure for current audio updates"
  )
  func attachToChangesInBufferedRange(
    closure: @escaping (Key, SAAudioAvailabilityRange) throws -> Void
  ) -> UInt {
    return depBufferClosures.attach(closure: closure)
  }

  func attachToChangesInBufferedRange(closure: @escaping (SAAudioAvailabilityRange) throws -> Void)
    async -> UInt
  {
    return await bufferClosures.attach(closure: closure)
  }

  // MARK: - Detaches
  func detachFromChangesInNeedle(withID id: UInt) {
    depNeedleClosures.detach(id: id)
    Task { await needleClosures.detach(id: id) }
  }

  func detachFromChangesInDuration(withID id: UInt) {
    depDurationClosures.detach(id: id)
    Task { await durationClosures.detach(id: id) }
  }

  func detachFromChangesInPlayingStatus(withID id: UInt) {
    depPlayingStatusClosures.detach(id: id)
    Task { await playingStatusClosures.detach(id: id) }
  }

  func detachFromChangesInBufferedRange(withID id: UInt) {
    depBufferClosures.detach(id: id)
    Task { await bufferClosures.detach(id: id) }
  }
}

// MARK: - Receives notifications from AudioEngine on ticks
extension AudioClockDirector {
  func needleTick(_ key: Key, needle: Needle) {
    guard key == currentAudioKey else {
      Log.debug("silence old updates")
      return
    }
    depNeedleClosures.broadcast(key: key, payload: needle)
    Task { await needleClosures.broadcast(payload: needle) }
  }
}

extension AudioClockDirector {
  func durationWasChanged(_ key: Key, duration: Duration) {
    guard key == currentAudioKey else {
      Log.debug("silence old updates")
      return
    }
    depDurationClosures.broadcast(key: key, payload: duration)
    Task { await durationClosures.broadcast(payload: duration) }
  }
}

extension AudioClockDirector {
  func audioPlayingStatusWasChanged(_ key: Key, status: SAPlayingStatus) {
    guard key == currentAudioKey else {
      Log.debug("silence old updates")
      return
    }
    depPlayingStatusClosures.broadcast(key: key, payload: status)
    Task { await playingStatusClosures.broadcast(payload: status) }
  }
}

extension AudioClockDirector {
  func changeInAudioBuffered(_ key: Key, buffered: SAAudioAvailabilityRange) {
    guard key == currentAudioKey else {
      Log.debug("silence old updates")
      return
    }
    depBufferClosures.broadcast(key: key, payload: buffered)
    Task { await bufferClosures.broadcast(payload: buffered) }
  }
}
