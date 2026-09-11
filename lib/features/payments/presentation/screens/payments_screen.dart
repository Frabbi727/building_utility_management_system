import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../controllers/payments_controller.dart';
import '../widgets/payment_submissions_list.dart';
import '../widgets/submit_payment_bottom_sheet.dart';
import '../widgets/verified_payments_list.dart';

class PaymentsScreen extends GetView<PaymentsController> {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => SubmitPaymentBottomSheet.show(context),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.submitPaymentProof),
      ),
      body: Column(
        children: [
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Obx(() {
              final selected = controller.selectedTabIndex.value;

              return SegmentedButton<int>(
                segments: [
                  ButtonSegment<int>(
                    value: 0,
                    icon: const Icon(Icons.verified),
                    label: Text(context.l10n.verifiedPayments),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    icon: const Icon(Icons.history),
                    label: Text(context.l10n.paymentSubmissions),
                  ),
                ],
                selected: {selected},
                onSelectionChanged: (set) => controller.changeTab(set.first),
              );
            }),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() {
              final selected = controller.selectedTabIndex.value;
              return IndexedStack(
                index: selected,
                children: const [
                  VerifiedPaymentsList(),
                  PaymentSubmissionsList(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
