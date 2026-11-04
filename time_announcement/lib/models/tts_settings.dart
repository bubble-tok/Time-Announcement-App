/// Speech settings applied to every announcement.
class TtsSettings {
  /// Whether announcements follow the device's system volume.
  final bool followSystemVolume;

  /// App-specific volume, 0.0-1.0. Used only when [followSystemVolume] is false.
  final double appVolume;

  /// Speech rate, 0.0-1.0.
  final double speechRate;

  /// [appVolume] and [speechRate] are clamped into 0.0-1.0.
  const TtsSettings({
    this.followSystemVolume = true,
    double appVolume = 1.0,
    double speechRate = 0.5,
  }) : appVolume = appVolume < 0.0 ? 0.0 : (appVolume > 1.0 ? 1.0 : appVolume),
       speechRate = speechRate < 0.0
           ? 0.0
           : (speechRate > 1.0 ? 1.0 : speechRate);

  /// Volume to pass to flutter_tts setVolume: 1.0 (full share of the system
  /// media volume) when following system, else [appVolume].
  double get effectiveVolume => followSystemVolume ? 1.0 : appVolume;

  TtsSettings copyWith({
    bool? followSystemVolume,
    double? appVolume,
    double? speechRate,
  }) {
    return TtsSettings(
      followSystemVolume: followSystemVolume ?? this.followSystemVolume,
      appVolume: appVolume ?? this.appVolume,
      speechRate: speechRate ?? this.speechRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsSettings &&
          other.followSystemVolume == followSystemVolume &&
          other.appVolume == appVolume &&
          other.speechRate == speechRate;

  @override
  int get hashCode => Object.hash(followSystemVolume, appVolume, speechRate);
}
