import 'package:crmapp/src/common/utils/toast_util.dart';
import 'package:crmapp/src/common/widgets/export_csv.dart';
import 'package:crmapp/src/customer/bloc/customer_bloc.dart';
import 'package:crmapp/src/customer/view/mobile/dialogs/add_customer_dialog.dart';

import 'package:crmapp/src/customer/view/mobile/widgets/customer_card.dart';
import 'package:crmapp/src/customer/view/mobile/widgets/empty_screens.dart';
import 'package:crmapp/src/customer/view/mobile/widgets/status_widget.dart';

import 'package:crmapp/src/common/models/models.dart';
import 'package:crmapp/src/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CustomerFilter { all, active, inactive }

class CustomerScreenMobile extends StatefulWidget {
  const CustomerScreenMobile({super.key});

  @override
  State<CustomerScreenMobile> createState() => _CustomerScreenMobileState();
}

class _CustomerScreenMobileState extends State<CustomerScreenMobile> {
  CustomerFilter _selectedFilter = CustomerFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<CustomerModel> _getFilteredCustomers(List<CustomerModel> customers) {
    List<CustomerModel> filtered = customers;

    switch (_selectedFilter) {
      case CustomerFilter.active:
        filtered = customers.where((c) => c.status == true).toList();
        break;
      case CustomerFilter.inactive:
        filtered = customers.where((c) => c.status == false).toList();
        break;
      case CustomerFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((customer) {
        return customer.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            customer.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            customer.phone.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Customer Management',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ProfileScreen(),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state.customerStatus == CustomerStatus.success) {
            ToastUtil.showSuccessToast(context, "Customer Created");
          } else if (state.customerStatus == CustomerStatus.deleted) {
            ToastUtil.showWarningToast(context, "Customer deleted");
          } else if (state.customerStatus == CustomerStatus.updated) {
            ToastUtil.showSuccessToast(context, "Customer Updated");
          } else if (state.customerStatus == CustomerStatus.error) {
            ToastUtil.showErrorToast(context, "Something went wrong");
          }
        },
        builder: (context, state) {
          if (state.customerStatus == CustomerStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 16),
                  Text(
                    'Loading customers...',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final filteredCustomers = _getFilteredCustomers(state.customerModel);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Customers',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${state.customerModel.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton.icon(
                          onPressed: () {
                            AddCustomerDialog().showAddCustomerDialog(
                              context,
                              context.read<CustomerBloc>(),
                            );
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Add Customer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: CurrentStatus().buildStatusCard(
                            'Active',
                            state.customerModel
                                .where((c) => c.status == true)
                                .length,
                            Colors.green,
                            Icons.check_circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CurrentStatus().buildStatusCard(
                            'Inactive',
                            state.customerModel
                                .where((c) => c.status == false)
                                .length,
                            Colors.orange,
                            Icons.pause_circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search customers...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[500],
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Text(
                          'Filter by:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  'All',
                                  CustomerFilter.all,
                                  state.customerModel.length,
                                  Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Active',
                                  CustomerFilter.active,
                                  state.customerModel
                                      .where((c) => c.status == true)
                                      .length,
                                  Colors.green,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Inactive',
                                  CustomerFilter.inactive,
                                  state.customerModel
                                      .where((c) => c.status == false)
                                      .length,
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child: ElevatedButton.icon(
                        //     onPressed: () {
                        //       () {
                        //         final customers = _getFilteredCustomers(
                        //           context
                        //               .read<CustomerBloc>()
                        //               .state
                        //               .customerModel,
                        //         );

                        //         exportToCsv(customers);

                        //         ToastUtil.showSuccessToast(
                        //           context,
                        //           'Exported as CSV',
                        //         );
                        //       };
                        //     },
                        //     icon: const Icon(Icons.download, size: 20),
                        //     label: const Text('Export'),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.teal,
                        //       foregroundColor: Colors.white,
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 16,
                        //         vertical: 12,
                        //       ),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //       elevation: 2,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),

              if (filteredCustomers.isNotEmpty || _searchQuery.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Search Results (${filteredCustomers.length})'
                            : _selectedFilter == CustomerFilter.all
                            ? 'All Customers (${filteredCustomers.length})'
                            : '${_selectedFilter == CustomerFilter.active ? 'Active' : 'Inactive'} Customers (${filteredCustomers.length})',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty ||
                          _selectedFilter != CustomerFilter.all)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = CustomerFilter.all;
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          child: const Text('Clear Filters'),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              Expanded(
                child: filteredCustomers.isEmpty
                    ? EmptyScreens().buildEmptyState(_searchQuery)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return CustomerCard().buildCustomerCard(
                            customer,
                            context,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      // bottomNavigationBar: BottomNavigationWidget(),
    );
  }

  Widget _buildFilterChip(
    String label,
    CustomerFilter filter,
    int count,
    Color color,
  ) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
