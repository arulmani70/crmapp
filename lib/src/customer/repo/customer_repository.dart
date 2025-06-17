import 'package:crmapp/src/common/common.dart';
import 'package:crmapp/src/common/constants/constansts.dart';
import 'package:crmapp/src/common/models/models.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class CustomerRepository {
  final ApiRepository apiRepo;
  final PreferencesRepository prefRepo;
  final Dio _dio = Dio();
  final log = Logger();
  final String baseUrl = Constants.api.API_BASE_URL.endsWith('/')
      ? Constants.api.API_BASE_URL.substring(
          0,
          Constants.api.API_BASE_URL.length - 1,
        )
      : Constants.api.API_BASE_URL;

  CustomerRepository({required this.apiRepo, required this.prefRepo});

  Future<List<CustomerModel>> getCustomerList() async {
    try {
      final response = await _dio.get('$baseUrl/customers/');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<CustomerModel> customers = data
            .map((json) => CustomerModel.fromJson(json))
            .toList();

        return customers;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      log.d('Error fetching users: $e');
      return [];
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      final response = await _dio.delete('$baseUrl/customers/$id');

      if (response.statusCode == 200) {
        log.d('Customer deleted successfully: ${response.data}');
      } else {
        throw Exception('Failed to delete customer');
      }
    } catch (e) {
      log.e('Error deleting customer: $e');
    }
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      final response = await _dio.post(
        '$baseUrl/customers/',
        data: customer.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        log.d('Customer added successfully: ${response.data}');
      } else {
        throw Exception('Failed to add customer');
      }
    } catch (e) {
      log.e('Error adding customer: $e');
      rethrow;
    }
  }

  Future<void> updateCustomer(String id, CustomerModel updatedCustomer) async {
    try {
      final response = await _dio.put(
        '$baseUrl/customers/$id',
        data: updatedCustomer.toJson(),
      );

      if (response.statusCode == 200) {
        log.d('Customer updated successfully: ${response.data}');
      } else {
        throw Exception('Failed to update customer');
      }
    } catch (e) {
      log.e('Error updating customer: $e');
    }
  }
}
