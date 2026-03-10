// ignore_for_file: must_be_immutable

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:flutter/material.dart';

class PlansTableWidgets extends StatelessWidget {
  const PlansTableWidgets({
    super.key,
    required this.plans,
    required this.featureNamesListss,
  });

  final List<Plan> plans;
  final List<String> featureNamesListss;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: featureNamesListss.map((featureName) {
        final feature = plans.first.planFeatures?.features?.values
            .firstWhere((f) => f.name == featureName, orElse: () => Feature());

        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade400, width: 1),
              left: BorderSide(color: Colors.grey.shade400, width: 1),
              right: BorderSide(color: Colors.grey.shade400, width: 1),
              bottom: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                  child: Center(
                    child: CustomText(
                      content:
                          normalizeFeatureName(feature?.name ?? featureName),
                      fontFamily: commonFont,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              ...plans.take(3).map((plan) {
                String? status =
                    plan.planFeatures?.features?[feature?.tagId]?.status;
                return Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        right:
                            BorderSide(color: Colors.grey.shade400, width: 1),
                      ),
                    ),
                    child: Center(
                      child: Center(
                        child: Image.asset(
                          status == 'true'
                              ? "assets/images/close and tick.png"
                              : "assets/images/close png.png",
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  String normalizeFeatureName(String? featureName) {
    if (featureName == null) return '';

    switch (featureName.trim()) {
      case "Orders, drafts etc counters with MM/YY separation":
        return "Order/Estimate/Pre-order/Draft counters with MM/YY";
      case "Packed &amp; Ready for Delivery":
      case "Packed &amp; Ready for Delivery ":
        return "Packed & Ready for Delivery";
      default:
        return featureName;
    }
  }
}

class TableTitle extends StatelessWidget {
  String title;
  TableTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomText(
          content: title,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
