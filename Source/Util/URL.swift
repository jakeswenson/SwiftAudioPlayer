//
//  URL.swift
//  Pods-SwiftAudioPlayer_Example
//
//  Created by Tanha Kabir on 2019-01-29.
//

import Foundation

extension URL {
    var key: String {
            return "audio_\(self.absoluteString.hashed)"
        }
    }

extension String {
  fileprivate var hashed: UInt64 {
            var result = UInt64 (8742)
            let buf = [UInt8](self.utf8)
            for b in buf {
      result = 127 * (result & 0x00ff_ffff_ffff_ffff) + UInt64(b)
            }
            return result
        }
    }
