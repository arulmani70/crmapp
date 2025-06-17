import 'package:crmapp/src/customer/view/mobile/widgets/drop_down.dart';
import 'package:crmapp/src/customer/view/mobile/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crmapp/src/common/models/models.dart';
import 'package:crmapp/src/customer/bloc/customer_bloc.dart';

class UpdateCustomerDialog {
  void showUpdateDialogWithFormBuilder(
    BuildContext context,
    CustomerModel customer,
    Function(CustomerModel) onUpdate,
  ) {
    final _formKey = GlobalKey<FormBuilderState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 16,
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Update Customer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Modify customer information",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      children: [
                        ModernTextField().buildModernTextField(
                          name: 'name',
                          initialValue: customer.name,
                          label: 'Full Name',
                          icon: Icons.person_rounded,
                          validator: FormBuilderValidators.required(),
                        ),
                        const SizedBox(height: 20),
                        ModernTextField().buildModernTextField(
                          name: 'email',
                          initialValue: customer.email,
                          label: 'Email Address',
                          icon: Icons.email_rounded,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.email(),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        ModernTextField().buildModernTextField(
                          name: 'phone',
                          initialValue: customer.phone,
                          label: 'Phone Number',
                          icon: Icons.phone_rounded,
                          validator: FormBuilderValidators.required(),
                        ),
                        const SizedBox(height: 20),
                        MyDropDown().buildModernDropdown(
                          name: 'status',
                          initialValue: customer.status,
                          label: 'Status',
                          icon: Icons.toggle_on_rounded,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Active'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.pause_circle,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Inactive'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final data = _formKey.currentState!.value;
                              final updated = customer.copyWith(
                                name: data['name'],
                                email: data['email'],
                                phone: data['phone'],
                                status: data['status'],
                              );
                              onUpdate(updated);
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Update",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
