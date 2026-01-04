import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:ijs_vault/features/settings/data/models/activity_log_model.dart';
import 'package:ijs_vault/features/settings/data/repository/activity_log_repository.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class ActivityLogController extends GetxController {
  final ActivityLogRepo _repo = ActivityLogRepo();

  final RxBool isLoading = false.obs;
  final RxList<ActivityLogItem> logs = <ActivityLogItem>[].obs;
  final RxString error = ''.obs;

  // Selected filter index as RxInt
  final RxInt selectedIndex = 0.obs;

  // Corrected filterTypes
  final RxList<String> filterTypes = <String>[
    'All Actions',
    'Created',
    'Uploaded',
    'Moved',
    'Deleted',
    'Edited', // Rename etc
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      isLoading.value = true;
      error.value = '';

      final ApiResponse response = await _repo.getActivityLogs();

      if (response.success) {
        final ActivityLogData parsedData = ActivityLogData.fromJson(
          response.data ?? <String, dynamic>{},
        );
        logs.assignAll(parsedData.logs);
      } else {
        error.value = response.message;
      }
    } catch (e) {
      error.value = 'Failed to fetch logs: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtered logs based on selectedIndex
  /// Filtered logs based on selectedIndex
  List<ActivityLogItem> get filteredLogs {
    final int index = selectedIndex.value;
    if (index == 0) {
      return logs.toList(); // All Actions
    }

    final String selectedType = filterTypes[index];
    String filterKey = '';

    // Map display label to API action keyword
    switch (selectedType) {
      case 'Created':
        filterKey = 'create';
        break;
      case 'Uploaded':
        filterKey = 'upload';
        break;
      case 'Moved':
        filterKey = 'move';
        break;
      case 'Deleted':
        filterKey = 'delete';
        break;
      case 'Edited':
        filterKey = 'edit';
        break;
      default:
        filterKey = selectedType.toLowerCase();
    }

    return logs.where((ActivityLogItem log) {
      final String action = log.action.toLowerCase();
      // Special case for 'Edited' matching 'rename' as well
      if (selectedType == 'Edited') {
        return action.contains('edit') || action.contains('rename');
      }
      return action.contains(filterKey);
    }).toList();
  }

  /// Change filter tab
  void changeFilter(int index) {
    selectedIndex.value = index;
  }
}
