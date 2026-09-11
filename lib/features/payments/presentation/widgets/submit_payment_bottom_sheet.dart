import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../controllers/payments_controller.dart';
import 'slip_image_picker_field.dart';

class SubmitPaymentBottomSheet extends StatefulWidget {
  final String? initialAmount;
  final String? initialReference;

  const SubmitPaymentBottomSheet({
    super.key,
    this.initialAmount,
    this.initialReference,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialAmount,
    String? initialReference,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SubmitPaymentBottomSheet(
        initialAmount: initialAmount,
        initialReference: initialReference,
      ),
    );
  }

  @override
  State<SubmitPaymentBottomSheet> createState() => _SubmitPaymentBottomSheetState();
}

class _SubmitPaymentBottomSheetState extends State<SubmitPaymentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _refController;
  final _notesController = TextEditingController();

  String _selectedMethod = 'bkash';
  DateTime _selectedDate = DateTime.now();
  String? _slipPath;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.initialAmount ?? '');
    _refController = TextEditingController(text: widget.initialReference ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'bkash':
        return const Color(0xFFD12053);
      case 'nagad':
        return const Color(0xFFF7941D);
      case 'bank':
        return Colors.blue.shade700;
      case 'cash':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getMethodLabel(BuildContext context, String method) {
    switch (method) {
      case 'bkash':
        return context.l10n.methodBkash;
      case 'nagad':
        return context.l10n.methodNagad;
      case 'bank':
        return context.l10n.methodBank;
      case 'cash':
        return context.l10n.methodCash;
      default:
        return method.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<PaymentsController>();
    final methods = ['bkash', 'nagad', 'bank', 'cash'];

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
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
                    context.l10n.submitPaymentProof,
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
                context.l10n.paymentMethod,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: methods.map((m) {
                  final isSelected = _selectedMethod == m;
                  final color = _getMethodColor(m);

                  return ChoiceChip(
                    label: Text(
                      _getMethodLabel(context, m),
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: color,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMethod = m);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 14.h),
              Text(
                context.l10n.amount,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '৳ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter amount';
                  final num = double.tryParse(val.trim());
                  if (num == null || num <= 0) return 'Please enter valid amount';
                  return null;
                },
              ),
              SizedBox(height: 14.h),
              Text(
                context.l10n.referenceNumber,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _refController,
                decoration: InputDecoration(
                  hintText: 'e.g. TrxID / Deposit slip number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter transaction reference number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 14.h),
              Text(
                context.l10n.paymentDate,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                context.l10n.uploadSlip,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              SlipImagePickerField(
                onImageSelected: (path) => _slipPath = path,
              ),
              SizedBox(height: 14.h),
              Text(
                context.l10n.notes,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: context.l10n.optional,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
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
                              final formattedDate =
                                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
                              final success = await controller.submitPaymentProof(
                                amount: _amountController.text.trim(),
                                method: _selectedMethod,
                                referenceNumber: _refController.text.trim(),
                                paymentDate: formattedDate,
                                notes: _notesController.text.trim(),
                                slipFilePath: _slipPath,
                              );
                              if (success && context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.l10n.paymentSubmitted),
                                    backgroundColor: Colors.green,
                                  ),
                                );
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
