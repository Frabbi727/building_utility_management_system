import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/flavors/app_flavor.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../payments/presentation/widgets/submit_payment_bottom_sheet.dart';
import '../../domain/entities/bill_entity.dart';
import '../controllers/bills_controller.dart';
import '../widgets/bill_items_list.dart';
import '../widgets/bill_status_chip.dart';

class BillDetailsScreen extends StatefulWidget {
  final BillEntity bill;

  const BillDetailsScreen({super.key, required this.bill});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  late BillEntity _currentBill;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentBill = widget.bill;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    final controller = Get.find<BillsController>();
    final detailed = await controller.getBillDetails(widget.bill.id);
    if (detailed != null && mounted) {
      setState(() {
        _currentBill = detailed;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _printBillPdf() async {
    try {
      final host = AppFlavor.baseUrl.replaceAll('/api/v1', '');
      final printUrl = '$host/bills/${_currentBill.id}/print';
      final uri = Uri.parse(printUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final fallback = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (!fallback) {
          Get.snackbar('Error', 'Could not open bill PDF link');
        }
      }
    } catch (_) {
      Get.snackbar('Error', 'Could not open bill PDF link');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.billBreakdown),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: context.l10n.printBill,
            onPressed: _printBillPdf,
          ),
        ],
      ),
      bottomNavigationBar: !_currentBill.isPaid
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: FilledButton.icon(
                  onPressed: () async {
                    await SubmitPaymentBottomSheet.show(
                      context,
                      initialAmount: _currentBill.totalAmount,
                      initialReference: _currentBill.billNo,
                    );
                    if (mounted) {
                      _fetchDetails();
                    }
                  },
                  icon: const Icon(Icons.payment),
                  label: Text(context.l10n.payNow),
                ),
              ),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _currentBill.billingMonth,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            BillStatusChip(status: _currentBill.status),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _currentBill.billNo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Divider(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        SizedBox(height: 8.h),
                        if (_currentBill.monthCharges != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.monthCharges,
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '৳ ${_currentBill.monthCharges}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                        ],
                        if (_currentBill.arrears != null &&
                            _currentBill.arrears != '0.00') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.arrears,
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '৳ ${_currentBill.arrears}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.totalPayable,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '৳ ${_currentBill.totalAmount}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  BillItemsList(items: _currentBill.items),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
    );
  }
}
