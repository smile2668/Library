import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/study_session_model.dart';
import '../providers/app_providers.dart';

class StudyTimerWidget extends StatefulWidget {
  final String studentId;
  final String libraryId;
  final StudySessionModel? activeSession;
  final VoidCallback onSessionChanged;

  const StudyTimerWidget({
    super.key,
    required this.studentId,
    required this.libraryId,
    required this.activeSession,
    required this.onSessionChanged,
  });

  @override
  State<StudyTimerWidget> createState() => _StudyTimerWidgetState();
}

class _StudyTimerWidgetState extends State<StudyTimerWidget> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _syncWithActiveSession();
  }

  @override
  void didUpdateWidget(StudyTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSession != oldWidget.activeSession) {
      _syncWithActiveSession();
    }
  }

  void _syncWithActiveSession() {
    if (widget.activeSession != null) {
      _isRunning = true;
      _elapsed = DateTime.now().difference(widget.activeSession!.startTime);
      _startTimer();
    } else {
      _isRunning = false;
      _timer?.cancel();
      _elapsed = Duration.zero;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {
        _elapsed = widget.activeSession != null
            ? DateTime.now().difference(widget.activeSession!.startTime)
            : _elapsed + const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _startSession() async {
    setState(() => _loading = true);
    try {
      final session = StudySessionModel(
        id: const Uuid().v4(),
        studentId: widget.studentId,
        libraryId: widget.libraryId,
        startTime: DateTime.now(),
        isActive: true,
      );
      await AppProviders.dbService.addStudySession(session);
      setState(() { _isRunning = true; _elapsed = Duration.zero; });
      _startTimer();
      widget.onSessionChanged();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Study session started')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _stopSession() async {
    if (widget.activeSession == null) return;
    setState(() => _loading = true);
    try {
      final endTime = DateTime.now();
      final durationMinutes = endTime.difference(widget.activeSession!.startTime).inMinutes;
      final updatedSession = StudySessionModel(
        id: widget.activeSession!.id,
        studentId: widget.activeSession!.studentId,
        libraryId: widget.activeSession!.libraryId,
        startTime: widget.activeSession!.startTime,
        endTime: endTime,
        durationMinutes: durationMinutes,
      );
      await AppProviders.dbService.updateStudySession(updatedSession);
      _timer?.cancel();
      setState(() { _isRunning = false; _elapsed = Duration.zero; });
      widget.onSessionChanged();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session ended. Duration: ${durationMinutes}m')),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: _isRunning
                ? [const Color(0xFF4CAF50).withValues(alpha: 0.1), const Color(0xFF2E7D32).withValues(alpha: 0.05)]
                : [const Color(0xFF3949AB).withValues(alpha: 0.08), const Color(0xFF1A237E).withValues(alpha: 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: _isRunning ? Colors.green : const Color(0xFF3949AB),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Study Timer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _isRunning ? Colors.green.shade700 : const Color(0xFF3949AB),
                  ),
                ),
                const Spacer(),
                if (_isRunning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('Active', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Timer display
            Text(
              _formatDuration(_elapsed),
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: _isRunning ? Colors.green.shade600 : Colors.grey.shade500,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isRunning ? 'Study session in progress' : 'Start a study session to track time',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Start/Stop button
            SizedBox(
              height: 46,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : (_isRunning ? _stopSession : _startSession),
                icon: _loading
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_isRunning ? Icons.stop_circle : Icons.play_circle),
                label: Text(
                  _loading ? '...' : (_isRunning ? 'Stop Session' : 'Start Study Session'),
                  style: const TextStyle(fontSize: 15),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.red.shade600 : const Color(0xFF3949AB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
