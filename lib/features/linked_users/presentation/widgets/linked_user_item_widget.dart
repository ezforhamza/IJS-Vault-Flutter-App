import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/linked_users/data/models/linked_user_model.dart';
import 'package:intl/intl.dart';

class LinkedUserItemWidget extends StatelessWidget {
  const LinkedUserItemWidget({
    super.key,
    required this.user,
    required this.isDarkMode,
  });
  final LinkedUserModel user;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 25,
                // backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    // color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.gradient),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  user.primaryRole.capitalizeFirst!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildInfoItem(
                'Shared Items',
                '${user.totalSharedCount}',
                Icons.folder_shared_outlined,
              ),
              _buildInfoItem(
                'Last Shared',
                user.lastSharedAt != null
                    ? DateFormat('MMM dd, yyyy').format(user.lastSharedAt!)
                    : 'N/A',
                Icons.access_time,
              ),
            ],
          ),
          if (user.sharedItems.folders.isNotEmpty ||
              user.sharedItems.files.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Shared Folders:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...user.sharedItems.folders.map(
              (SharedFolderModel folder) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.folder,
                      size: 16,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        folder.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ),
                    Text(
                      folder.role.capitalizeFirst!,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.white38 : Colors.black38,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
