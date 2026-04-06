import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import '../models/timer_model.dart';
import '../services/api_service.dart';

enum PostureStatus { good, bad, unknown }

class AppState extends ChangeNotifier {
  // ── Server connection ──────────────────────────────────────────────────────
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // ── Posture ────────────────────────────────────────────────────────────────
  PostureStatus _posture = PostureStatus.unknown;
  PostureStatus get posture => _posture;

  String _statusMessage = 'Connecting to ADIS...';
  String get statusMessage => _statusMessage;

  String _currentScreen = 'HOME';
  String get currentScreen => _currentScreen;

  // ── Timer ──────────────────────────────────────────────────────────────────
  TimerModel _timerModel = const TimerModel();
  TimerModel get timerModel => _timerModel;

  Timer? _countdownTimer;
  Timer? _pollTimer;

  // ── Reminders ─────────────────────────────────────────────────────────────
  List<Reminder> _reminders = [];
  List<Reminder> get reminders => List.unmodifiable(_reminders);

  Reminder? get nextReminder {
    final upcoming = _reminders.where((r) => r.isUpcoming).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  AppState() {
    _loadRemindersFromLocal();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchState());
    _fetchState(); // immediate first fetch
  }

  Future<void> _fetchState() async {
    final data = await ApiService.instance.getState();
    if (data == null) {
      if (_isConnected) {
        _isConnected = false;
        _statusMessage = 'Server unreachable';
        notifyListeners();
      }
      return;
    }
    _isConnected = true;
    _currentScreen = data['screen'] as String? ?? 'HOME';
    _statusMessage = data['message'] as String? ?? '';
    final statusStr = (data['status'] as String? ?? '').toUpperCase();
    _posture = statusStr == 'GOOD'
        ? PostureStatus.good
        : statusStr == 'BAD'
            ? PostureStatus.bad
            : PostureStatus.unknown;
    notifyListeners();
  }

  // ── Timer control ──────────────────────────────────────────────────────────
  Future<void> startTimer(int durationSeconds) async {
    await ApiService.instance.startTimer(durationSeconds);
    _timerModel = TimerModel(
      durationSeconds: durationSeconds,
      isRunning: true,
      remainingSeconds: durationSeconds,
    );
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final remaining = _timerModel.remainingSeconds - 1;
      if (remaining <= 0) {
        t.cancel();
        _timerModel = _timerModel.copyWith(isRunning: false, remainingSeconds: 0);
      } else {
        _timerModel = _timerModel.copyWith(remainingSeconds: remaining);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> stopTimer() async {
    await ApiService.instance.stopTimer();
    _countdownTimer?.cancel();
    _timerModel = _timerModel.copyWith(
      isRunning: false,
      remainingSeconds: _timerModel.durationSeconds,
    );
    notifyListeners();
  }

  void setTimerDuration(int seconds) {
    if (_timerModel.isRunning) return;
    _timerModel = TimerModel(durationSeconds: seconds, remainingSeconds: seconds);
    notifyListeners();
  }

  // ── Reminders ─────────────────────────────────────────────────────────────
  Future<void> addReminder(String title, String time) async {
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      time: time,
    );
    _reminders.add(reminder);
    _reminders.sort((a, b) => a.time.compareTo(b.time));
    await _saveRemindersToLocal();
    // Best-effort sync to server
    ApiService.instance.addTask(title, time);
    notifyListeners();
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _saveRemindersToLocal();
    notifyListeners();
  }

  Future<void> _loadRemindersFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('reminders');
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList();
      _reminders = list;
      notifyListeners();
    }
  }

  Future<void> _saveRemindersToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'reminders',
      jsonEncode(_reminders.map((r) => r.toJson()).toList()),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
