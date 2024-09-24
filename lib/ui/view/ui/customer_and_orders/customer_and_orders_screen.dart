import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/customer_and_orders_middel_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/customer_and_orders_top_widgets.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerAndOrdersScreen extends StatefulWidget {
  const CustomerAndOrdersScreen({super.key});

  @override
  State<CustomerAndOrdersScreen> createState() =>
      _CustomerAndOrdersScreenState();
}

class _CustomerAndOrdersScreenState extends State<CustomerAndOrdersScreen> {
  CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());

  LeadsController leadsController = Get.put(LeadsController());

  @override
  void initState() {
    customerAndOrderController.loadCustomer;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return Scaffold(
        body: Padding(
          padding: nkRegularPadding(),
          child: RefreshIndicator(
            onRefresh: () async {
              await customerAndOrderController.loadCustomer;
            },
            child:
                SingleChildScrollView(

                  child: Column(
                    children: [

                      CustomerAndOrdersTopWidgets(
                        customerAndOrderController: customerAndOrderController, staffDataList: [],
                      ),
                      nkMediumSizeBox(),
                      CustomerAndOrdersMiddelWidget(
                        custAndOrdController: customerAndOrderController,
                        leadsController: leadsController,
                        context: context,

                      ),

                    ],
                  ),
                  scrollDirection: Axis.vertical,
                )



          ),
        ),
      );
    });
  }
}
