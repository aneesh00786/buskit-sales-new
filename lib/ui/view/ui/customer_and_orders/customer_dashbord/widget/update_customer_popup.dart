import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class UpdateCustomerPopup extends StatefulWidget {
  final String customerId;
  final String initialName;

  const UpdateCustomerPopup({
    Key? key,
    required this.customerId,
    required this.initialName,
  }) : super(key: key);

  @override
  State<UpdateCustomerPopup> createState() => UpdateCustomerPopupState();
}

class UpdateCustomerPopupState extends State<UpdateCustomerPopup> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // Controllers for Address
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _deliveryContactController;
  late TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    // 1. Initialize empty controllers
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipController = TextEditingController();
    _deliveryContactController = TextEditingController();
    _remarkController = TextEditingController();

    // 2. Fetch the real data
    _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    try {
      final response = await ApiService().fetchOneCustomer(widget.customerId);

      // 2. Check response
      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final customer = response.data[0];

        if (mounted) {
          setState(() {
            // 3. Assign the NEW fields from the updated Model
            _addressController.text = customer.deliveryAddress ?? '';
            _cityController.text = customer.deliveryTown ?? '';
            _stateController.text = customer.deliveryState ?? '';

            // Convert int to String for the text field
            _zipController.text = customer.deliveryZipcode?.toString() ?? '';

            _deliveryContactController.text = customer.deliveryContact ?? '';
            _remarkController.text = customer.remark ?? '';

            // 4. Handle Checkbox
            // _sameAsAbove = customer.addressCheckbox == "ON";

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      log("Error loading customer: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _deliveryContactController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Get the logged in Salesman/User ID
        // Adjust this line to match how you save login data
        String currentUserId =
            SessionHelper.loginSavedData?.salesmanId ?? "SALES1";

        final apiService = ApiService();

        final response = await apiService.updateDeliveryAddress(
          customerId: widget.customerId,
          companyId: SessionHelper.loginSavedData?.company_id ?? 0,
          address: _addressController.text,
          town: _cityController.text,
          state: _stateController.text,
          zipcode: _zipController.text,
          contact: _deliveryContactController.text,
          updatedBy: currentUserId,
        );

        setState(() => _isLoading = false);

        if (response.status == true) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Updated Successfully"),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh Dashboard Data here if needed
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.message ?? "Update Failed")),
            );
          }
        }
      } catch (e) {
        log("Update Error: $e");
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

//  void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true); // Show loading

//       try {
//         // Access your ApiService (assuming you use Provider or GetIt)
//         final apiService = ApiService();
//         // OR if it's inside CustomersProvider:
//         // final provider = Provider.of<CustomersProvider>(context, listen: false);

//         final response = await apiService.updateDeliveryAddress(
//           customerId: widget.customerId,
//           companyId: SessionHelper.loginSavedData?.company_id ?? 0,
//           address: _addressController.text,
//           town: _cityController.text,
//           state: _stateController.text,
//           zipcode: _zipController.text,
//           contact: _deliveryContactController.text,
//           remark: _remarkController.text,
//         );

//         setState(() => _isLoading = false);

//         if (response.status == true) {
//           if (mounted) {
//             Navigator.pop(context); // Close popup
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(response.message ?? "Updated Successfully"),
//                 backgroundColor: Colors.green,
//               ),
//             );

//             // Optional: Refresh the dashboard data
//             // Provider.of<CustomersProvider>(context, listen: false).fetchCustomersDataDash(widget.customerId);
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(response.message ?? "Update Failed")),
//             );
//           }
//         }
//       } catch (e) {
//         log("Update Error: $e");
//         if (mounted) {
//           setState(() => _isLoading = false);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error: $e")),
//           );
//         }
//       }
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- Header ---
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              gradient: LinearGradient(
                colors: [primaryColor, Color(0xFF2D3748)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Update Customer",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                dialogCloseButton1(context, Colors.white),
              ],
            ),
          ),

          // --- Body ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header for section
                          _buildSectionHeader("DELIVERY ADDRESS"),
                          const SizedBox(height: 15),

                          // Address Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                _buildEditableField(
                                  label: "Address",
                                  controller: _addressController,
                                  icon: Icons.location_on_outlined,
                                  isWhiteBg: true,
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildEditableField(
                                            label: "City/Suburb",
                                            controller: _cityController,
                                            isWhiteBg: true)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: _buildEditableField(
                                            label: "State",
                                            controller: _stateController,
                                            isWhiteBg: true)),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                _buildEditableField(
                                    label: "Zip/Post Code",
                                    controller: _zipController,
                                    isWhiteBg: true,
                                    keyboardType: TextInputType.number),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(),
                                ),
                                _buildEditableField(
                                  label: "Delivery Contact Number",
                                  controller: _deliveryContactController,
                                  icon: Icons.phone_in_talk_outlined,
                                  isWhiteBg: true,
                                ),
                                const SizedBox(height: 15),
                                _buildEditableField(
                                  label: "Remark",
                                  controller: _remarkController,
                                  icon: Icons.note_alt_outlined,
                                  isWhiteBg: true,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // --- Footer Button ---
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Update Customer",
                  style: TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool isWhiteBg = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: Colors.grey[400])
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: isWhiteBg ? Colors.white : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins_Regular',
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF64748B),
        letterSpacing: 1.0,
      ),
    );
  }
}
