//
//  AudioQueueDirector.swift
//  SwiftAudioPlayer
//
//  Created by Joe Williams on 3/10/21.
//

import Foundation

class AudioQueueDirector {
  static let shared = AudioQueueDirector()
  var closures: DirectorThreadSafeClosures<URL> = DirectorThreadSafeClosures()
  private init() {}

  func create() {}

  func clear() {
    Task {
      await closures.clear()
    }
  }

  func attach(closure: @escaping (URL) throws -> Void) async -> UInt {
    return await closures.attach(closure: closure)
  }

  func detach(withID id: UInt) {
    Task {
      await closures.detach(id: id)
    }
  }

  func changeInQueue(url: URL) {
    Task {
      await closures.broadcast(payload: url)
    }
  }
}
