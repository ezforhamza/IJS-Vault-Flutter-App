import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/settings/data/models/legal_page_model.dart';
import 'package:ijs_vault/features/settings/data/repository/legal_repo.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class LegalPageScreen extends StatefulWidget {
  const LegalPageScreen({super.key, required this.type, required this.title});
  final String type;
  final String title;

  @override
  State<LegalPageScreen> createState() => _LegalPageScreenState();
}

class _LegalPageScreenState extends State<LegalPageScreen> {
  final LegalRepo _repo = LegalRepo();
  bool _isLoading = true;
  LegalPageModel? _page;

  @override
  void initState() {
    super.initState();
    _loadLegalPage();
  }

  Future<void> _loadLegalPage() async {
    try {
      final ApiResponse response = await _repo.getLegalPageByType(type: widget.type);

      if (response.success && response.data != null) {
        setState(() {
          _page = LegalPageModel.fromJson(response.data['page']);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading legal page: $e');
      AppToasts.showErrorToast(message: 'Failed to load page');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      appBar: CustomAppBar(text: widget.title),
      body: _isLoading
          ? _buildShimmer(isDarkMode)
          : _page == null
              ? _buildErrorState(isDarkMode)
              : _buildContent(isDarkMode),
    );
  }

  Widget _buildShimmer(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 24,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            ...List<Widget>.generate(
              8,
              (int index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDarkMode ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load content',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _loadLegalPage();
            },
            child: Text(
              'Try Again',
              style: TextStyle(color: AppColors.gradient[0]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Version and last updated info
          if (_page!.updatedAt != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.update,
                    size: 16,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last updated: ${DateFormat('MMMM d, yyyy').format(_page!.updatedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'v${_page!.version}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gradient[0],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          // HTML Content
          HtmlWidget(
            _page!.content,
            textStyle: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
