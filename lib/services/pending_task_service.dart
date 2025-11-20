import 'package:keepjoy_app/models/pending_task.dart';
import 'package:keepjoy_app/services/hive_service.dart';

class PendingTaskService {
  PendingTaskService._();

  static final PendingTaskService instance = PendingTaskService._();

  final _hiveService = HiveService.instance;

  static const _backoffSchedule = <Duration>[
    Duration(seconds: 3),
    Duration(seconds: 10),
    Duration(seconds: 30),
  ];

  Future<void> recordFailure({
    required PendingTaskType type,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    final id = _taskId(type, entityId);
    final existing = _hiveService.getPendingTask(id);
    final retryCount = (existing?.retryCount ?? 0) + 1;
    final delayIndex = (retryCount - 1).clamp(0, _backoffSchedule.length - 1);
    final nextAttempt = DateTime.now().add(_backoffSchedule[delayIndex]);

    final task = PendingTask(
      id: id,
      type: type,
      entityId: entityId,
      payload: payload,
      retryCount: retryCount,
      lastAttemptAt: DateTime.now(),
      nextAttemptAt: nextAttempt,
    );

    await _hiveService.savePendingTask(task);
  }

  Future<void> clearTask(PendingTaskType type, String entityId) async {
    await _hiveService.deletePendingTask(_taskId(type, entityId));
  }

  List<PendingTask> getDueTasks(DateTime now) {
    return _hiveService
        .getAllPendingTasks()
        .where((task) => !task.nextAttemptAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.nextAttemptAt.compareTo(b.nextAttemptAt));
  }

  Future<void> rescheduleTask(PendingTask task) async {
    await recordFailure(
      type: task.type,
      entityId: task.entityId,
      payload: task.payload,
    );
  }

  String _taskId(PendingTaskType type, String entityId) => '${type.name}::$entityId';
}
