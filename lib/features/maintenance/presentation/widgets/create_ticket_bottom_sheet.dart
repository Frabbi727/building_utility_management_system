import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/maintenance_request_entity.dart';
import '../controllers/maintenance_controller.dart';

class CreateTicketBottomSheet extends StatefulWidget {
  const CreateTicketBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const CreateTicketBottomSheet(),
    );
  }

  @override
  State<CreateTicketBottomSheet> createState() => _CreateTicketBottomSheetState();
}

class _CreateTicketBottomSheetState extends State<CreateTicketBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  MaintenanceCategory _selectedCategory = MaintenanceCategory.other;
  MaintenancePriority _selectedPriority = MaintenancePriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<MaintenanceController>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.createTicket,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                context.l10n.ticketCategory,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              DropdownButtonFormField<MaintenanceCategory>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                items: MaintenanceCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              SizedBox(height: 14.h),
              Text(
                context.l10n.ticketPriority,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              DropdownButtonFormField<MaintenancePriority>(
                initialValue: _selectedPriority,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                items: MaintenancePriority.values.map((pri) {
                  return DropdownMenuItem(
                    value: pri,
                    child: Text(pri.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPriority = val);
                },
              ),
              SizedBox(height: 14.h),
              Text(
                context.l10n.ticketTitle,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: context.l10n.enterTicketTitle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.l10n.enterTicketTitle;
                  }
                  return null;
                },
              ),
              SizedBox(height: 14.h),
              Text(
                context.l10n.ticketDescription,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: context.l10n.enterTicketDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.l10n.enterTicketDescription;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              Obx(() {
                final isSubmitting = controller.isSubmitting.value;

                return SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final confirmed = await ConfirmDialog.show(
                                context,
                                title: context.l10n.createTicket,
                                message:
                                    'Are you sure you want to submit this maintenance request?',
                                details: {
                                  context.l10n.ticketCategory:
                                      _selectedCategory.name.toUpperCase(),
                                  context.l10n.ticketPriority:
                                      _selectedPriority.name.toUpperCase(),
                                  context.l10n.ticketTitle:
                                      _titleController.text.trim(),
                                },
                                confirmText: context.l10n.submit,
                                cancelText: context.l10n.cancel,
                              );

                              if (confirmed == true && context.mounted) {
                                final success = await controller.submitRequest(
                                  title: _titleController.text.trim(),
                                  description: _descController.text.trim(),
                                  category: _selectedCategory.value,
                                  priority: _selectedPriority.value,
                                );
                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.l10n.ticketSubmitted),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    child: isSubmitting
                        ? SizedBox(
                            width: 24.sp,
                            height: 24.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(context.l10n.submit),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
