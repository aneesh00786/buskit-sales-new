// ignore_for_file: must_be_immutable

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:enefty_icons/enefty_icons.dart';
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
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                  child: Center(
                    child: CustomText(content: feature?.name ?? featureName),
                  ),
                ),
              ),
              ...plans.take(3).map((plan) {
                String? status =
                    plan.planFeatures?.features?[feature?.tagId]?.status;
                return Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        right:
                            BorderSide(color: Colors.grey.shade400, width: 1),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        status == 'true'
                            ? EneftyIcons.tick_circle_outline
                            : EneftyIcons.close_circle_outline,
                        color: status == 'true' ? Colors.green : Colors.red,
                        size: 15,
                      ),
                      // child: Center(
                      //   child: Image.asset(
                      //     status == 'true'
                      //         ? "assets/images/close and tick.png"
                      //         : "assets/images/close png.png",
                      //     height: 20,
                      //   ),
                      // ),
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
}

class TableTitle extends StatelessWidget {
  String title;
  TableTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomText(
        content: title,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
