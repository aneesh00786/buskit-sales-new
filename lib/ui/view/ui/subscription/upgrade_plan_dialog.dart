import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/sibscription_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UpgradePlanScreen extends StatefulWidget {
  const UpgradePlanScreen({super.key});

  @override
  State<UpgradePlanScreen> createState() => _UpgradePlanScreenState();
}

class _UpgradePlanScreenState extends State<UpgradePlanScreen> {
  final SubscriptionController subscriptionController =
      Get.find<SubscriptionController>();

  final ScrollController _scrollController = ScrollController();

  int selectedPlanIndex = 0;
  String endDate = '';

  List<String> planNames = [];
  String selectedPlanName = '';
  List<SubscribtionPlanDetailsData> selectedPlanOptions = [];
  SubscribtionPlanDetailsData? selectedPaymentOption;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    await subscriptionController.loadSubscriptionPlanDetails();

    final allPlans = subscriptionController.plansData;

    final uniquePlanNames = <String>{};
    for (var plan in allPlans) {
      uniquePlanNames.add(plan.planName);
    }

    setState(() {
      planNames = uniquePlanNames.toList();
      if (planNames.isNotEmpty) {
        selectedPlanName = planNames.last;
        selectedPlanOptions =
            allPlans.where((p) => p.planName == selectedPlanName).toList();
        selectedPaymentOption = selectedPlanOptions.first;
        _updateEndDate();
      }
    });
  }

  void _updateEndDate() {
    final now = DateTime.now();
    if (selectedPaymentOption == null) return;

    DateTime calculatedDate;
    if (selectedPaymentOption!.billingCycle.toLowerCase().contains('monthly')) {
      calculatedDate = DateTime(now.year, now.month + 1, now.day);
    } else {
      calculatedDate = DateTime(now.year + 1, now.month, now.day);
    }

    endDate = DateFormat('MMMM dd, yyyy').format(calculatedDate);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Obx(() {
        if (subscriptionController.isSubscriptionPlanDetailsLoading.value) {
          return SizedBox(
              height: fullScreenHeight(context) * 0.4,
              child: const Center(child: CircularProgressIndicator()));
        }

        if (subscriptionController.plansData.isEmpty) {
          return const Center(child: Text('No Plans Available'));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Color(0xFF7578EA),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upgrade Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  dialogCloseButton1(context, red),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(planNames.length, (index) {
                            final planName = planNames[index];
                            final isSelected = planName == selectedPlanName;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedPlanName = planName;
                                    selectedPlanOptions = subscriptionController
                                        .plansData
                                        .where((p) =>
                                            p.planName == selectedPlanName)
                                        .toList();
                                    selectedPaymentOption =
                                        selectedPlanOptions.first;
                                    _updateEndDate();
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE9E3FF)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF7578EA)
                                          : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      planName.capitalizeFirst!,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: List.generate(selectedPlanOptions.length,
                              (index) {
                            final option = selectedPlanOptions[index];
                            final isSelected =
                                option.id == selectedPaymentOption?.id;
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPaymentOption = option;
                                      _updateEndDate();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFE9E3FF)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF7578EA)
                                            : Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(option
                                                .billingCycle.capitalizeFirst ??
                                            ''),
                                        const Spacer(),
                                        Text(formatAmount(option.price)),
                                        Text(option.billingCycle
                                                .contains("monthly")
                                            ? " / Month"
                                            : " / Year"),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 25,
                          color: primaryColor,
                          child: const Center(
                              child: Text(
                            "Features",
                            style: TextStyle(
                                color: white,
                                fontSize: 16,
                                letterSpacing: 0.7,
                                fontWeight: FontWeight.w600),
                          )),
                        ),
                        const SizedBox(height: 10),
                        if (selectedPaymentOption
                                ?.planFeatures.features.isNotEmpty ??
                            false)
                          SizedBox(
                            height: 300,
                            child: ScrollbarTheme(
                              data: const ScrollbarThemeData(
                                  thumbColor:
                                      WidgetStatePropertyAll(primaryColor),
                                  radius: Radius.circular(10)),
                              child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                child: ListView.separated(
                                  controller: _scrollController,
                                  itemCount: selectedPaymentOption!
                                      .planFeatures.features.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 0.5,
                                    color: Colors.black12,
                                  ),
                                  itemBuilder: (context, index) {
                                    final entry = selectedPaymentOption!
                                        .planFeatures.features.entries
                                        .elementAt(index);
                                    final feature = entry.value;
                                    final isEnabled =
                                        feature.status.toLowerCase() == 'true';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              feature.name,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            isEnabled
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: isEnabled
                                                ? Colors.green
                                                : Colors.red,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        else
                          const Text("No features available."),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Credit Card'),
                          _buildInputField('Card holder name'),
                          const SizedBox(height: 10),
                          _buildLabel('Payment Details'),
                          _buildInputField('Card Number'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildInputField('MM')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildInputField('YY')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildInputField('CVV')),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildDropdown('Select Country'),
                          const SizedBox(height: 10),
                          _buildDropdown('Select State'),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'End on: $endDate',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              formatAmount(selectedPaymentOption?.price),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.green),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    backgroundColor:
                                        primaryColor.withOpacity(0.2),
                                  ),
                                  child: const Text(
                                    // 'Subscribe - \$${subscriptionController.plansData[selectedPlanIndex].price}',
                                    'Subscribe',
                                    // 'Subscribe - ${formatAmount(selectedPaymentOption?.price)}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [],
      onChanged: (value) {},
    );
  }
}
