import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/customer/customer_bloc.dart';
import '../blocs/customer/customer_event.dart';
import '../blocs/customer/customer_state.dart';
import '../models/customer_model.dart';
import 'customer_details_screen.dart';
import 'new_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<CustomerBloc>().state;
      if (state is CustomersLoaded && !state.hasReachedMax) {
        context.read<CustomerBloc>().add(
              LoadCustomers(page: state.currentPage + 1),
            );
      }
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<CustomerBloc>().add(const LoadCustomers());
    } else {
      context.read<CustomerBloc>().add(SearchCustomers(query));
    }
  }

  Future<void> _onRefresh() async {
    context.read<CustomerBloc>().add(const RefreshCustomers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العملاء'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'البحث عن عميل...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading && state is! CustomersLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CustomerError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _onRefresh,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is CustomersLoaded) {
                  if (state.customers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا يوجد عملاء',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NewCustomerScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة عميل'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.hasReachedMax
                          ? state.customers.length
                          : state.customers.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.customers.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final customer = state.customers[index];
                        return _buildCustomerCard(customer);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NewCustomerScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('عميل جديد'),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CustomerDetailsScreen(customer: customer),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _getCustomerTypeColor(customer.type),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (customer.address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        customer.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusChip(customer.status),
                  const SizedBox(height: 8),
                  if (customer.outstandingBalance != null &&
                      customer.outstandingBalance! > 0)
                    Text(
                      '${customer.outstandingBalance!.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'نشط';
        break;
      case 'inactive':
        color = Colors.grey;
        label = 'غير نشط';
        break;
      case 'blocked':
        color = Colors.red;
        label = 'محظور';
        break;
      default:
        color = Colors.blue;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCustomerTypeColor(String? type) {
    switch (type) {
      case 'retail':
        return Colors.blue;
      case 'wholesale':
        return Colors.purple;
      case 'corporate':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تصفية العملاء',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('العملاء النشطون'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CustomerBloc>().add(
                        const LoadCustomers(status: 'active'),
                      );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('العملاء غير النشطين'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CustomerBloc>().add(
                        const LoadCustomers(status: 'inactive'),
                      );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('العملاء المحظورون'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CustomerBloc>().add(
                        const LoadCustomers(status: 'blocked'),
                      );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('إزالة التصفية'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CustomerBloc>().add(const LoadCustomers());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
