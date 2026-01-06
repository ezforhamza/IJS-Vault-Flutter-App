import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/settings/data/models/activity_log_model.dart';
import 'package:ijs_vault/features/settings/presentation/controllers/activity_log_controller.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/activity_log_widget.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/loader_widget.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  late final ActivityLogController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ActivityLogController());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.black : AppColors.white,
      appBar: const CustomAppBar(text: 'Activity Log'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),

            // FILTER TABS
            SizedBox(
              height: 35,
              child: Obx(() {
                final int selectedindex = controller.selectedIndex.value;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filterTypes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final bool isSelected = selectedindex == index;
                    return GestureDetector(
                      onTap: () => controller.changeFilter(index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000),
                          gradient: isSelected
                              ? const LinearGradient(colors: AppColors.gradient)
                              : null,
                          color: isSelected
                              ? null
                              : isDarkMode
                              ? const Color(0xFF20222b)
                              : Colors.grey[300],
                        ),
                        child: Center(
                          child: Text(
                            controller.filterTypes[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : (isDarkMode ? Colors.white : Colors.black),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 20),

            // LIST OF LOGS
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: LoaderWidget());
                }

                final List<ActivityLogItem> filteredLogs =
                    controller.filteredLogs;

                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Text(
                      'No activity found',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    final ActivityLogItem log = filteredLogs[index];
                    return ActivityLogWidget(isDarkMode: isDarkMode, log: log);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: filteredLogs.length,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
