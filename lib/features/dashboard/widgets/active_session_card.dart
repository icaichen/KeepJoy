import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/deep_cleaning_session.dart';
import '../../../l10n/app_localizations.dart';
import 'package:keepjoy_app/features/deep_cleaning/deep_cleaning_flow.dart';

class ActiveSessionCard extends StatefulWidget {
  final DeepCleaningSession session;
  final void Function({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  }) onStopSession;

  const ActiveSessionCard({
    super.key,
    required this.session,
    required this.onStopSession,
  });

  @override
  State<ActiveSessionCard> createState() => _ActiveSessionCardState();
}

class _ActiveSessionCardState extends State<ActiveSessionCard> {
  late Timer _timer;
  late ValueNotifier<String> _timeNotifier;

  @override
  void initState() {
    super.initState();
    _timeNotifier = ValueNotifier(_getElapsedTime(widget.session.startTime));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeNotifier.value = _getElapsedTime(widget.session.startTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  String _getElapsedTime(DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE1E7EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dashboardActiveSessionTitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                ),
                Text(
                  l10n.deepCleaningTitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: _timeNotifier,
                        builder: (context, time, _) {
                          return Text(
                            time,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              height: 1.05,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.session.area} - ${l10n.inProgress}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DeepCleaningTimerPage(
                            area: widget.session.area,
                            beforePhotoPath: widget.session.localBeforePhotoPath ??
                                widget.session.remoteBeforePhotoPath,
                            onStopSession: widget.onStopSession,
                            sessionStartTime: widget.session.startTime,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 18,
                    ),
                    label: Text(l10n.resume),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF414B5A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.finishCleaning),
                          content: Text(l10n.finishCleaningConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AfterPhotoPage(
                                      area: widget.session.area,
                                      beforePhotoPath: widget.session.localBeforePhotoPath ??
                                          widget.session.remoteBeforePhotoPath,
                                      elapsedSeconds: DateTime.now()
                                          .difference(widget.session.startTime)
                                          .inSeconds,
                                      onStopSession: widget.onStopSession,
                                    ),
                                  ),
                                );
                              },
                              child: Text(l10n.stop),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.stop),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
