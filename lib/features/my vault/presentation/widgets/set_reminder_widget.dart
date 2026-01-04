import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/features/reminders/presentation/controllers/reminder_controller.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class SetReminderWidget extends StatefulWidget {
  const SetReminderWidget({
    super.key,
    required this.title,
    required this.itemId,
  });

  final String itemId;
  final String title;

  @override
  State<SetReminderWidget> createState() => _SetReminderWidgetState();
}

class _SetReminderWidgetState extends State<SetReminderWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // ---------------- DATE PICKER ----------------
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  // ---------------- TIME PICKER ----------------
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------- SUBMIT FORM ----------------
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      Get.snackbar(
        'Validation Error',
        'Please select date and time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final DateTime reminderDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    await Get.find<ReminderController>().createReminder(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      reminderDateTime: reminderDateTime,
      itemId: widget.itemId,
    );

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header
              Row(
                children: <Widget>[
                  const SizedBox(width: 24),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: Get.back,
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 16),

              // Title
              CustomTextField(
                controller: _titleController,
                title: 'Title',
                hintText: 'Enter Title',
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              // const SizedBox(height: 10),

              // Description
              CustomTextField(
                controller: _descriptionController,
                title: 'Description (optional)',
                hintText: 'Write Description...',
                minLines: 4,
                maxLines: 4,
              ),
              // const SizedBox(height: 16),

              // Date & Time
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reminder Date & Time',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium!.copyWith(fontSize: 14),
                ),
              ),
              // const SizedBox(height: 8),
              Row(
                spacing: 10,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      behavior: HitTestBehavior.opaque,
                      child: IgnorePointer(
                        child: CustomTextField(
                          controller: _dateController,
                          isTitle: false,
                          title: '',
                          hintText: 'Select date',
                          validator: (_) {
                            if (_selectedDate == null) {
                              return 'Date is required';
                            }
                            return null;
                          },
                          suffixIcon: SvgPicture.asset(
                            AppImages.selectreminderdate,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      behavior: HitTestBehavior.opaque,
                      child: IgnorePointer(
                        child: CustomTextField(
                          controller: _timeController,
                          isTitle: false,
                          title: '',
                          readOnly: true,
                          hintText: 'Select time',
                          validator: (_) {
                            if (_selectedTime == null) {
                              return 'Time is required';
                            }
                            return null;
                          },
                          suffixIcon: SvgPicture.asset(
                            AppImages.selectremindertimeicon,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 20),

              // Submit button
              CustomButton(text: 'Set Reminder', onTap: _submitForm),
            ],
          ),
        ),
      ),
    );
  }
}
