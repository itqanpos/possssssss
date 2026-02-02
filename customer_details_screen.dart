import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/customer_model.dart';
import '../blocs/sale/sale_bloc.dart';
import '../blocs/sale/sale_event.dart';
import '../blocs/sale/sale_state.dart';
import '../blocs/visit/visit_bloc.dart';
import '../blocs/visit/visit_event.dart';
import '../blocs/visit/visit_state.dart';
import 'new_sale_screen.dart';
import 'new_visit_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<SaleBloc>().add(
          LoadSalesByCustomer(widget.customer.id),
        );
    context.read<VisitBloc>().add(
          LoadVisitsByCustomer(widget.customer.id),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Edit customer
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المعلومات'),
            Tab(text: 'المبيعات'),
            Tab(text: 'الزيارات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildSalesTab(),
          _buildVisitsTab(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'sale',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NewSaleScreen(),
                ),
              );
            },
            child: const Icon(Icons.shopping_cart),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'visit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NewVisitScreen(),
                ),
              );
            },
            child: const Icon(Icons.location_on),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildContactCard(),
          const SizedBox(height: 16),
          if (widget.customer.address != null) ...[
            _buildAddressCard(),
            const SizedBox(height: 16),
          ],
          _buildFinancialCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _getCustomerTypeColor(widget.customer.type),
              child: Text(
                widget.customer.name.isNotEmpty
                    ? widget.customer.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customer.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(widget.customer.status),
                  const SizedBox(height: 4),
                  Text(
                    _getCustomerTypeName(widget.customer.type),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text('رقم الهاتف'),
            subtitle: Text(widget.customer.phone),
            trailing: IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                // TODO: Make phone call
              },
            ),
          ),
          if (widget.customer.email != null) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('البريد الإلكتروني'),
              subtitle: Text(widget.customer.email!),
              trailing: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  // TODO: Send email
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.red),
        title: const Text('العنوان'),
        subtitle: Text(widget.customer.address!),
        trailing: IconButton(
          icon: const Icon(Icons.map),
          onPressed: () {
            // TODO: Open map
          },
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المعلومات المالية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialItem(
                    'إجمالي المشتريات',
                    '${widget.customer.totalPurchases?.toStringAsFixed(2) ?? "0.00"} ر.س',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildFinancialItem(
                    'الرصيد المستحق',
                    '${widget.customer.outstandingBalance?.toStringAsFixed(2) ?? "0.00"} ر.س',
                    Colors.red,
                  ),
                ),
              ],
            ),
            if (widget.customer.creditLimit != null) ...[
              const SizedBox(height: 16),
              _buildFinancialItem(
                'حد الائتمان',
                '${widget.customer.creditLimit!.toStringAsFixed(2)} ر.س',
                Colors.blue,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesTab() {
    return BlocBuilder<SaleBloc, SaleState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final customerSales = state.sales
            .where((s) => s.customerId == widget.customer.id)
            .toList();

        if (customerSales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مبيعات',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customerSales.length,
          itemBuilder: (context, index) {
            final sale = customerSales[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.receipt, color: Colors.green),
                title: Text('فاتورة #${sale.invoiceNumber ?? sale.id}'),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd').format(sale.createdAt),
                ),
                trailing: Text(
                  '${sale.total.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVisitsTab() {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final customerVisits = state.visits
            .where((v) => v.customerId == widget.customer.id)
            .toList();

        if (customerVisits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد زيارات',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customerVisits.length,
          itemBuilder: (context, index) {
            final visit = customerVisits[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.orange),
                title: Text(visit.purpose ?? 'زيارة'),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(visit.scheduledAt),
                ),
                trailing: _buildVisitStatusChip(visit.status),
              ),
            );
          },
        );
      },
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

  Widget _buildVisitStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'scheduled':
        color = Colors.blue;
        label = 'مجدول';
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'قيد التنفيذ';
        break;
      case 'completed':
        color = Colors.green;
        label = 'مكتمل';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'ملغي';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
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

  String _getCustomerTypeName(String? type) {
    switch (type) {
      case 'retail':
        return 'تجزئة';
      case 'wholesale':
        return 'جملة';
      case 'corporate':
        return 'شركة';
      default:
        return 'عميل';
    }
  }
}
