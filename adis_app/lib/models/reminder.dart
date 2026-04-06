import 'package:intl/intl.dart';

class Reminder {
  final String id;
  final String title;
  final String time; // HH:mm 24h format

  const Reminder({
    required this.id,
    required this.title,
    required this.time,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String,
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'time': time,
      };

  /// True if the reminder's time is still ahead of now today.
  bool get isUpcoming {
    try {
      final parts = time.split(':');
      final rHour = int.parse(parts[0]);
      final rMin = int.parse(parts[1]);
      final now = DateTime.now();
      return rHour > now.hour ||
          (rHour == now.hour && rMin > now.minute);
    } catch (_) {
      return false;
    }
  }

  /// Formatted as 12-hour time, e.g. "02:30 PM".
  String get displayTime {
    try {
      final parts = time.split(':');
      final dt = DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return time;
    }
  }

  Reminder copyWith({String? id, String? title, String? time}) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Reminder && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
