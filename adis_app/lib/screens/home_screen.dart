import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, state, _) {
            return FadeTransition(
              opacity: _fadeIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),

                    // Top row: title + connection badge
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ADIS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              'Adaptive Display Intelligence',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _ConnectionBadge(connected: state.isConnected),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // ── Posture Status Card ──────────────────────────────
                    _PostureCard(posture: state.posture, message: state.statusMessage),

                    const SizedBox(height: 20),

                    // ── Timer Card (if running) ──────────────────────────
                    if (state.timerModel.isRunning) ...[
                      _TimerStatusCard(
                          displayTime: state.timerModel.displayTime,
                          progress: state.timerModel.progress),
                      const SizedBox(height: 20),
                    ],

                    // ── Next Reminder ────────────────────────────────────
                    _NextReminderCard(reminder: state.nextReminder),

                    const Spacer(),

                    // ── Ambient message ──────────────────────────────────
                    Center(
                      child: Text(
                        _ambientMessage(state.posture),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.18),
                          fontSize: 13,
                          letterSpacing: 1.2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _ambientMessage(PostureStatus posture) {
    switch (posture) {
      case PostureStatus.good:
        return '"Keep it up — stay in the flow."';
      case PostureStatus.bad:
        return '"Sit up straight. Your future self thanks you."';
      case PostureStatus.unknown:
        return '"Stay mindful. Stay focused."';
    }
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _ConnectionBadge extends StatelessWidget {
  final bool connected;
  const _ConnectionBadge({required this.connected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: connected
            ? const Color(0xFF00C853).withValues(alpha: 0.12)
            : const Color(0xFFFF1744).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: connected
              ? const Color(0xFF00C853).withValues(alpha: 0.4)
              : const Color(0xFFFF1744).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: connected ? const Color(0xFF00C853) : const Color(0xFFFF1744),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            connected ? 'Live' : 'Offline',
            style: TextStyle(
              color: connected ? const Color(0xFF00C853) : const Color(0xFFFF1744),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostureCard extends StatelessWidget {
  final PostureStatus posture;
  final String message;
  const _PostureCard({required this.posture, required this.message});

  @override
  Widget build(BuildContext context) {
    final isGood = posture == PostureStatus.good;
    final isUnknown = posture == PostureStatus.unknown;

    final color = isUnknown
        ? Colors.white24
        : isGood
            ? const Color(0xFF00C853)
            : const Color(0xFFFF1744);

    final label = isUnknown ? 'UNKNOWN' : isGood ? 'GOOD' : 'BAD';
    final icon = isUnknown
        ? Icons.device_unknown_rounded
        : isGood
            ? Icons.sentiment_satisfied_alt_rounded
            : Icons.sentiment_very_dissatisfied_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'POSTURE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimerStatusCard extends StatelessWidget {
  final String displayTime;
  final double progress;
  const _TimerStatusCard({required this.displayTime, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF00E5FF).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFF00E5FF), size: 20),
          const SizedBox(width: 12),
          const Text(
            'Session active',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const Spacer(),
          Text(
            displayTime,
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextReminderCard extends StatelessWidget {
  final dynamic reminder;
  const _NextReminderCard({this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined,
              color: Colors.white38, size: 20),
          const SizedBox(width: 12),
          const Text(
            'Next reminder',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const Spacer(),
          if (reminder != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  reminder.displayTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  reminder.title,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            )
          else
            const Text(
              'None set',
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
        ],
      ),
    );
  }
}
