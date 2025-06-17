import 'package:crmapp/src/customer/bloc/customer_bloc.dart';
import 'package:crmapp/src/common/models/customer_model.dart';
import 'package:flutter/material.dart';

class DeleteCustomerDialog {
  void showDeleteConfirmation(
    BuildContext context,
    CustomerModel customer,
    CustomerBloc bloc,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Delete Customer',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                bloc.add(DeleteCustomer(id: customer.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
