import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, state, _) {
            final timer = state.timerModel;
            final durationMinutes = timer.durationSeconds ~/ 60;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Header
                  const Text(
                    'Focus Timer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Set your session duration',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                  ),

                  const Spacer(),

                  // Big clock display
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: timer.isRunning ? _pulseAnim.value : 1.0,
                          child: child,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular progress ring
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: CircularProgressIndicator(
                              value: timer.progress,
                              strokeWidth: 6,
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                timer.isRunning
                                    ? const Color(0xFF00E5FF)
                                    : Colors.white24,
                              ),
                            ),
                          ),
                          // Glow circle
                          if (timer.isRunning)
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                timer.displayTime,
                                style: TextStyle(
                                  color: timer.isRunning
                                      ? const Color(0xFF00E5FF)
                                      : Colors.white,
                                  fontSize: 56,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: 4,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              Text(
                                timer.isRunning ? 'RUNNING' : 'READY',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 11,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Duration controls (disabled while running)
                  AnimatedOpacity(
                    opacity: timer.isRunning ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        Text(
                          'Duration',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // -5 min
                            _AdjustButton(
                              label: '−5',
                              onPressed: timer.isRunning
                                  ? null
                                  : () {
                                      final newVal =
                                          (durationMinutes - 5).clamp(5, 120);
                                      state.setTimerDuration(newVal * 60);
                                    },
                            ),
                            const SizedBox(width: 20),
                            // Duration display
                            Container(
                              width: 90,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A2E),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$durationMinutes min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // +5 min
                            _AdjustButton(
                              label: '+5',
                              onPressed: timer.isRunning
                                  ? null
                                  : () {
                                      final newVal =
                                          (durationMinutes + 5).clamp(5, 120);
                                      state.setTimerDuration(newVal * 60);
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 18),
                            activeTrackColor: const Color(0xFF00E5FF),
                            inactiveTrackColor: Colors.white12,
                            thumbColor: const Color(0xFF00E5FF),
                            overlayColor: const Color(0x2200E5FF),
                          ),
                          child: Slider(
                            value: durationMinutes.toDouble(),
                            min: 5,
                            max: 120,
                            divisions: 23,
                            onChanged: timer.isRunning
                                ? null
                                : (v) => state.setTimerDuration(v.round() * 60),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Start / Stop button
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (timer.isRunning) {
                          state.stopTimer();
                        } else {
                          state.startTimer(timer.durationSeconds);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 180,
                        height: 56,
                        decoration: BoxDecoration(
                          color: timer.isRunning
                              ? const Color(0xFFFF1744).withValues(alpha: 0.15)
                              : const Color(0xFF00E5FF),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: timer.isRunning
                                ? const Color(0xFFFF1744)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (!timer.isRunning)
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          timer.isRunning ? 'STOP' : 'START',
                          style: TextStyle(
                            color: timer.isRunning
                                ? const Color(0xFFFF1744)
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _AdjustButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: onPressed == null ? Colors.white24 : const Color(0xFF00E5FF),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
