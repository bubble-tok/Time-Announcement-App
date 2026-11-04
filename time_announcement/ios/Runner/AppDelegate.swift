import AVFoundation
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let speechClipWriter = SpeechClipWriter()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required by flutter_local_notifications to show notifications in the foreground.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SpeechClipWriter") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "time_announcement/speech_clips",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "writeClip" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let args = call.arguments as? [String: Any],
        let text = args["text"] as? String,
        let fileName = args["fileName"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "text and fileName are required", details: nil))
        return
      }
      let language = args["language"] as? String ?? "en-US"
      let rate = Float(args["rate"] as? Double ?? 0.5)
      self?.speechClipWriter.write(text: text, fileName: fileName, language: language, rate: rate) { error in
        DispatchQueue.main.async {
          if let error = error {
            result(FlutterError(code: "write_failed", message: error.localizedDescription, details: nil))
          } else {
            result(nil)
          }
        }
      }
    }
  }
}

/// Renders speech to Library/Sounds/<fileName> as 16-bit linear PCM CAF, a
/// format iOS accepts for custom notification sounds (max 30 seconds).
final class SpeechClipWriter {
  private let synthesizer = AVSpeechSynthesizer()

  enum ClipError: LocalizedError {
    case noAudio
    var errorDescription: String? { "The speech synthesizer produced no audio." }
  }

  func write(
    text: String,
    fileName: String,
    language: String,
    rate: Float,
    completion: @escaping (Error?) -> Void
  ) {
    let soundsDir = FileManager.default
      .urls(for: .libraryDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("Sounds", isDirectory: true)
    let url = soundsDir.appendingPathComponent(fileName)

    do {
      try FileManager.default.createDirectory(at: soundsDir, withIntermediateDirectories: true)
      if FileManager.default.fileExists(atPath: url.path) {
        try FileManager.default.removeItem(at: url)
      }
    } catch {
      completion(error)
      return
    }

    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: language)
      ?? AVSpeechSynthesisVoice(language: "en-US")
    // flutter_tts uses the same 0–1 scale, with 0.5 as the normal rate.
    utterance.rate = min(max(rate, AVSpeechUtteranceMinimumSpeechRate), AVSpeechUtteranceMaximumSpeechRate)

    var file: AVAudioFile?
    var finished = false
    func finish(_ error: Error?) {
      guard !finished else { return }
      finished = true
      file = nil  // Releasing the AVAudioFile flushes and closes it.
      completion(error)
    }

    synthesizer.write(utterance) { buffer in
      guard let pcm = buffer as? AVAudioPCMBuffer else { return }
      // A zero-length buffer marks the end of the utterance.
      if pcm.frameLength == 0 {
        finish(file == nil ? ClipError.noAudio : nil)
        return
      }
      do {
        if file == nil {
          let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: pcm.format.sampleRate,
            AVNumberOfChannelsKey: pcm.format.channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
          ]
          file = try AVAudioFile(
            forWriting: url,
            settings: settings,
            commonFormat: pcm.format.commonFormat,
            interleaved: pcm.format.isInterleaved
          )
        }
        try file?.write(from: pcm)
      } catch {
        finish(error)
      }
    }
  }
}
