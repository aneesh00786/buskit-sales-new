// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for LeadsController

class LeadsStatusSelect extends StatefulWidget {
  final int customerId;
  // final String screenType; // Add screenType parameter to identify the calling page

  const LeadsStatusSelect({
    super.key,
    required this.customerId,
    // required this.screenType, // Required to identify the page (leads or rejects)
  });

  @override
  _LeadsStatusSelectState createState() => _LeadsStatusSelectState();
}

class _LeadsStatusSelectState extends State<LeadsStatusSelect> {
  late String _selectedValue = 'Select';
  final LeadsController _leadsController = Get.put(LeadsController());
  // final RejectedLeadsController _rejectedLeadsController =
  //     Get.put(RejectedLeadsController());

  @override
  void initState() {
    super.initState();

    // Set the initial dropdown value based on screenType
    // if (widget.screenType == 'leads') {
    //   _selectedValue = 'Select';
    // } else if (widget.screenType == 'rejects') {
    //   _selectedValue = 'Rejected';
    // }
  }

  void _onDropdownChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedValue = newValue;
      });

      // Call acceptRejectLeads when the dropdown value changes
      if (_selectedValue == 'Accept') {
        _leadsController.handleLeadsStatus(widget.customerId, 'accept');
      } else if (_selectedValue == 'Reject') {
        _leadsController.handleLeadsStatus(widget.customerId, 'reject');
      }
      //  else if (_selectedValue == 'Move to Leads') {
      //   _leadsController.handleLeadsStatus(widget.customerId, 'move_lead');
      // }
      print('Customer ID: ${widget.customerId}');
      print('Selected value: $newValue');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine dropdown options based on screenType
    List<String> dropdownItems = ['Select', 'Accept', 'Reject'];

    // if (widget.screenType == 'leads') {
    //   dropdownItems = ['Select', 'Accept', 'Reject'];
    // } else if (widget.screenType == 'rejects') {
    //   dropdownItems = ['Rejected', 'Accept', 'Move to Leads'];
    // }

    return Container(
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        color: const Color.fromARGB(255, 197, 247, 252),
        border: Border.all(color: const Color.fromARGB(255, 215, 215, 215))
         // Background color
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedValue,
          isExpanded: true, // Make dropdown fill the width
          icon: Icon(Icons.arrow_drop_down,
              color: Colors.black), // Customize dropdown icon
          iconSize: 15, // Icon size
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black, // Text color
          ),
          onChanged: _onDropdownChanged,
          items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3), // Add padding inside each item
                child: Text(value),
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
  // final String screenType; // Add screenType parameter to identify the calling page

  const LeadsRejectedStatusSelect({
    super.key,
    required this.customerId,
    // required this.screenType, // Required to identify the page (leads or rejects)
  });

  @override
  _LeadsRejectedStatusSelectState createState() => _LeadsRejectedStatusSelectState();
}

class _LeadsRejectedStatusSelectState extends State<LeadsRejectedStatusSelect> {
  late String _selectedValue = 'Rejected';
  final RejectedLeadsController _rejectedLeadsController = Get.put(RejectedLeadsController());
  // final RejectedLeadsController _rejectedLeadsController =
  //     Get.put(RejectedLeadsController());

  @override
  void initState() {
    super.initState();

    // Set the initial dropdown value based on screenType
    // if (widget.screenType == 'leads') {
    //   _selectedValue = 'Select';
    // } else if (widget.screenType == 'rejects') {
    //   _selectedValue = 'Rejected';
    // }
  }

  void _onDropdownChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedValue = newValue;
      });

      // Call acceptRejectLeads when the dropdown value changes
      if (_selectedValue == 'Accept') {
        _rejectedLeadsController.handleRejectedLeadStatus(widget.customerId, 'accept');
      }
      // else if (_selectedValue == 'Reject') {
      //   _leadsController.handleLeadsStatus(widget.customerId, 'reject');
      // }
       else if (_selectedValue == 'Move to Leads') {
        _rejectedLeadsController.handleRejectedLeadStatus(widget.customerId, 'move_lead');
      }
      print('Customer ID: ${widget.customerId}');
      print('Selected value: $newValue');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine dropdown options based on screenType
    List<String> dropdownItems = ['Rejected', 'Accept', 'Move to Leads'];

    // if (widget.screenType == 'leads') {
    //   dropdownItems = ['Select', 'Accept', 'Reject'];
    // } else if (widget.screenType == 'rejects') {
    //   dropdownItems = ['Rejected', 'Accept', 'Move to Leads'];
    // }

    return Container(
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5), // Rounded corners
        color: const Color.fromARGB(255, 220, 231, 236), // Background color
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedValue,
          isExpanded: true, // Make dropdown fill the width
          icon: Icon(Icons.arrow_drop_down,
              color: Colors.black), // Customize dropdown icon
          iconSize: 15, // Icon size
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black, // Text color
          ),
          onChanged: _onDropdownChanged,
          items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3), // Add padding inside each item
                child: Text(value),
              ),
            );
          }).toList(),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}
