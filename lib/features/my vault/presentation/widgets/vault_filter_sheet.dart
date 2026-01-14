import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_filter_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';

class VaultFilterSheet extends StatefulWidget {
  const VaultFilterSheet({super.key});

  @override
  State<VaultFilterSheet> createState() => _VaultFilterSheetState();
}

class _VaultFilterSheetState extends State<VaultFilterSheet> {
  final MyVaultController controller = Get.find<MyVaultController>();

  late VaultItemType _selectedType;
  late VaultFileType _selectedFileType;
  late VaultSortBy _selectedSortBy;
  late VaultSortOrder _selectedSortOrder;

  @override
  void initState() {
    super.initState();
    _selectedType = controller.filter.value.type;
    _selectedFileType = controller.filter.value.fileType;
    _selectedSortBy = controller.filter.value.sortBy;
    _selectedSortOrder = controller.filter.value.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.scaffoldBackgroundColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildHandle(),
          _buildHeader(textTheme, isDarkMode),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildSection(
                    title: 'Item Type',
                    textTheme: textTheme,
                    isDarkMode: isDarkMode,
                    child: _buildTypeChips(isDarkMode),
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),

                  if (_selectedType == VaultItemType.file) ...<Widget>[
                    const SizedBox(height: 20),
                    _buildSection(
                      title: 'File Type',
                      textTheme: textTheme,
                      isDarkMode: isDarkMode,
                      child: _buildFileTypeChips(isDarkMode),
                    ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1, end: 0),
                  ],

                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Sort By',
                    textTheme: textTheme,
                    isDarkMode: isDarkMode,
                    child: _buildSortByChips(isDarkMode),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Order',
                    textTheme: textTheme,
                    isDarkMode: isDarkMode,
                    child: _buildSortOrderChips(isDarkMode),
                  ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildActions(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Filters',
            style: textTheme.titleLarge?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Reset',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.gradient[0],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required TextTheme textTheme,
    required bool isDarkMode,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTypeChips(bool isDarkMode) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: VaultItemType.values.map((VaultItemType type) {
        final bool isSelected = _selectedType == type;
        return _FilterChip(
          label: type.label,
          icon: _getTypeIcon(type),
          isSelected: isSelected,
          isDarkMode: isDarkMode,
          onTap: () {
            setState(() {
              _selectedType = type;
              if (type != VaultItemType.file) {
                _selectedFileType = VaultFileType.all;
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildFileTypeChips(bool isDarkMode) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: VaultFileType.values.map((VaultFileType type) {
        final bool isSelected = _selectedFileType == type;
        return _FilterChip(
          label: type.label,
          icon: _getFileTypeIcon(type),
          isSelected: isSelected,
          isDarkMode: isDarkMode,
          onTap: () => setState(() => _selectedFileType = type),
        );
      }).toList(),
    );
  }

  Widget _buildSortByChips(bool isDarkMode) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: VaultSortBy.values.map((VaultSortBy sortBy) {
        final bool isSelected = _selectedSortBy == sortBy;
        return _FilterChip(
          label: sortBy.label,
          isSelected: isSelected,
          isDarkMode: isDarkMode,
          onTap: () => setState(() => _selectedSortBy = sortBy),
        );
      }).toList(),
    );
  }

  Widget _buildSortOrderChips(bool isDarkMode) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _FilterChip(
            label: 'Ascending',
            icon: Icons.arrow_upward_rounded,
            isSelected: _selectedSortOrder == VaultSortOrder.asc,
            isDarkMode: isDarkMode,
            onTap: () => setState(() => _selectedSortOrder = VaultSortOrder.asc),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterChip(
            label: 'Descending',
            icon: Icons.arrow_downward_rounded,
            isSelected: _selectedSortOrder == VaultSortOrder.desc,
            isDarkMode: isDarkMode,
            onTap: () => setState(() => _selectedSortOrder = VaultSortOrder.desc),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(bool isDarkMode) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradient),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Apply Filters',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  IconData _getTypeIcon(VaultItemType type) {
    switch (type) {
      case VaultItemType.all:
        return Icons.grid_view_rounded;
      case VaultItemType.folder:
        return Icons.folder_rounded;
      case VaultItemType.file:
        return Icons.insert_drive_file_rounded;
    }
  }

  IconData _getFileTypeIcon(VaultFileType type) {
    switch (type) {
      case VaultFileType.all:
        return Icons.all_inclusive_rounded;
      case VaultFileType.document:
        return Icons.description_rounded;
      case VaultFileType.media:
        return Icons.perm_media_rounded;
      case VaultFileType.note:
        return Icons.note_rounded;
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedType = VaultItemType.all;
      _selectedFileType = VaultFileType.all;
      _selectedSortBy = VaultSortBy.name;
      _selectedSortOrder = VaultSortOrder.asc;
    });
  }

  void _applyFilters() {
    final VaultFilter newFilter = VaultFilter(
      type: _selectedType,
      fileType: _selectedFileType,
      sortBy: _selectedSortBy,
      sortOrder: _selectedSortOrder,
    );
    controller.applyFilter(newFilter);
    Get.back();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: AppColors.gradient)
              : null,
          color: isSelected
              ? null
              : (isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDarkMode ? Colors.white12 : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
