import 'dart:io';
import 'package:crmapp/src/common/models/customer_model.dart';
import 'package:csv/csv.dart';

import 'package:path_provider/path_provider.dart';

Future<void> exportToCsv(List<CustomerModel> customers) async {
  try {
    final rows = <List<String>>[
      ['Name', 'Email', 'Phone', 'Status'],
      ...customers.map(
        (c) => [c.name, c.email, c.phone, c.status ? 'Active' : 'Inactive'],
      ),
    ];

    final csvData = const ListToCsvConverter().convert(rows);

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/customers.csv';

    final file = File(path);
    await file.writeAsString(csvData);

    print('Exported to $path');
  } catch (e) {
    print('Export error: $e');
  }
}
