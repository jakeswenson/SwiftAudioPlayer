import Combine
import AVFoundation

public struct AudioUpdates {

  public let playingStatus: CurrentValueSubject<SAPlayingStatus, Never> = CurrentValueSubject(.buffering)

  public let elapsedTime: CurrentValueSubject<TimeInterval, Never> = CurrentValueSubject(-1)

  public let duration: CurrentValueSubject<TimeInterval, Never> = CurrentValueSubject(-1)

  public let streamingBuffer: CurrentValueSubject<SAAudioAvailabilityRange?, Never> = CurrentValueSubject(nil)

  public let audioDownloading: CurrentValueSubject<Double, Never> = CurrentValueSubject(0)
  public let streamingDownloadProgress: CurrentValueSubject<(url: URL, progress: Double)?, Never> = CurrentValueSubject(nil)

  public let audioQueue: CurrentValueSubject<URL?, Never> = CurrentValueSubject(nil)

  init() {
    let audioDownloading = self.audioDownloading


    AudioDataManager.shared.attach { (key, progress) in
      audioDownloading.send(progress)
    }
  }
}
