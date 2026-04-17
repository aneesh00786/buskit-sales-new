// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadsStatusSelect extends StatefulWidget {
  final int customerId;

  const LeadsStatusSelect({
    super.key,
    required this.customerId,
  });

  @override

  _LeadsStatusSelectState createState() => _LeadsStatusSelectState();
}

class _LeadsStatusSelectState extends State<LeadsStatusSelect> {
  late String _selectedValue = 'Select';
  final LeadsController _leadsController = Get.put(LeadsController());
  final CustomersController _leadsCustomerController =
      Get.put(CustomersController());
  final RejectedLeadsController _leadsRejectController =
      Get.put(RejectedLeadsController());

  void _onDropdownChanged(String? newValue) async {
    bool isConnected = await ConnectivityService().isOnline();
    if (!mounted) return;
    if (!isConnected) {
      errorSnackbar("No internet connection . please check your network");
      return;
    }
    if (newValue != null) {
      setState(() {
        _selectedValue = newValue;
      });
      if (_selectedValue == 'Accept') {
        _leadsController.handleLeadsStatus(widget.customerId, 'accept');
      } else if (_selectedValue == 'Reject') {
        _leadsController.handleLeadsStatus(widget.customerId, 'reject');
      }
      _leadsController.loadLeadsCustomerData;
      _leadsCustomerController.loadLeadsCustomerData;
      _leadsRejectController.loadRejectedLeadsData;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> dropdownItems = ['Select', 'Accept', 'Reject'];
    return Container(
      height: 26,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 197, 247, 252),
          border: Border.all(color: const Color.fromARGB(255, 215, 215, 215))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          iconSize: 15,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          onChanged: _onDropdownChanged,
          items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(value.tr),
              ),
            );
          }).toList(),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}

class LeadsRejectedStatusSelect extends StatefulWidget {
  final int customerId;

  const LeadsRejectedStatusSelect({
    super.key,
    required this.customerId,
  });

  @override

  _LeadsRejectedStatusSelectState createState() =>
      _LeadsRejectedStatusSelectState();
}

class _LeadsRejectedStatusSelectState extends State<LeadsRejectedStatusSelect> {
  late String _selectedValue = 'Rejected';
  final LeadsController _leadsController = Get.put(LeadsController());
  final CustomersController _leadsCustomerController =
      Get.put(CustomersController());
  final RejectedLeadsController _leadsRejectController =
      Get.put(RejectedLeadsController());

  @override
  void initState() {
    super.initState();
  }

  void _onDropdownChanged(String? newValue) async {
    bool isConnected = await ConnectivityService().isOnline();

    if (!mounted) return;

    if (!isConnected) {
      errorSnackbar("No internet connection . please check your network");
      return;
    }

    if (newValue != null) {
      setState(() {
        _selectedValue = newValue;
      });

      if (_selectedValue == 'Accept') {
        _leadsRejectController.handleRejectedLeadStatus(
            widget.customerId, 'accept');
      } else if (_selectedValue == 'Move to Leads') {
        _leadsRejectController.handleRejectedLeadStatus(
            widget.customerId, 'move_lead');
      }
      _leadsController.loadLeadsCustomerData;
      _leadsCustomerController.loadLeadsCustomerData;
      _leadsRejectController.loadRejectedLeadsData;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> dropdownItems = ['Rejected', 'Accept', 'Move to Leads'];
    return Container(
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 220, 231, 236),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          iconSize: 15,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          onChanged: _onDropdownChanged,
          items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(value.tr),
              ),
            );
          }).toList(),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}
