class TimerModel {
  final int durationSeconds;
  final bool isRunning;
  final int remainingSeconds;

  const TimerModel({
    this.durationSeconds = 1500, // 25 min default
    this.isRunning = false,
    this.remainingSeconds = 1500,
  });

  String get displayTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    if (durationSeconds == 0) return 0;
    return 1 - (remainingSeconds / durationSeconds);
  }

  TimerModel copyWith({
    int? durationSeconds,
    bool? isRunning,
    int? remainingSeconds,
  }) {
    return TimerModel(
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isRunning: isRunning ?? this.isRunning,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}
