import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sale/sale_bloc.dart';
import '../blocs/sale/sale_event.dart';
import '../blocs/sale/sale_state.dart';
import '../blocs/customer/customer_bloc.dart';
import '../blocs/customer/customer_event.dart';
import '../blocs/customer/customer_state.dart';
import '../models/sale_model.dart';
import '../models/product_model.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({Key? key}) : super(key: key);

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final _searchController = TextEditingController();
  String? _selectedCustomerId;
  String? _selectedCustomerName;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيع جديد'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _onClear,
            child: const Text(
              'مسح',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SaleBloc, SaleState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomerSelector(),
                      const SizedBox(height: 24),
                      _buildProductsSection(),
                      const SizedBox(height: 24),
                      _buildPaymentMethodSelector(state),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'العميل',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedCustomerId != null)
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(_selectedCustomerName!),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedCustomerId = null;
                    _selectedCustomerName = null;
                  });
                  context.read<SaleBloc>().add(const SetCustomer());
                },
              ),
            ),
          )
        else
          BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomersLoaded) {
                return Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'البحث عن عميل...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        context
                            .read<CustomerBloc>()
                            .add(SearchCustomers(value));
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.customers.length > 5
                            ? 5
                            : state.customers.length,
                        itemBuilder: (context, index) {
                          final customer = state.customers[index];
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(customer.name),
                            subtitle: Text(customer.phone),
                            onTap: () {
                              setState(() {
                                _selectedCustomerId = customer.id;
                                _selectedCustomerName = customer.name;
                              });
                              context.read<SaleBloc>().add(
                                    SetCustomer(
                                      customerId: customer.id,
                                      customerName: customer.name,
                                    ),
                                  );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
      ],
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'المنتجات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _showProductSelector();
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<SaleBloc, SaleState>(
          builder: (context, state) {
            if (state.currentItems.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لا توجد منتجات',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showProductSelector();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة منتج'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: state.currentItems.map((item) {
                return _buildSaleItemCard(item, state);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaleItemCard(SaleItem item, SaleState state) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${item.unitPrice.toStringAsFixed(2)} ر.س',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    context.read<SaleBloc>().add(
                          UpdateSaleItemQuantity(
                            item.productId,
                            item.quantity - 1,
                          ),
                        );
                  },
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    context.read<SaleBloc>().add(
                          UpdateSaleItemQuantity(
                            item.productId,
                            item.quantity + 1,
                          ),
                        );
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              '${item.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<SaleBloc>().add(
                      RemoveSaleItem(item.productId),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector(SaleState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'طريقة الدفع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildPaymentChip('cash', 'نقدي', Icons.money),
            _buildPaymentChip('card', 'بطاقة', Icons.credit_card),
            _buildPaymentChip('transfer', 'تحويل', Icons.account_balance),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentChip(String value, String label, IconData icon) {
    return BlocBuilder<SaleBloc, SaleState>(
      builder: (context, state) {
        final isSelected = state.paymentMethod == value;
        return ChoiceChip(
          avatar: Icon(icon, size: 18),
          label: Text(label),
          selected: isSelected,
          onSelected: (_) {
            context.read<SaleBloc>().add(SetPaymentMethod(value));
          },
        );
      },
    );
  }

  Widget _buildBottomBar(SaleState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المجموع:'),
                Text(
                  '${state.total.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: state.currentItems.isEmpty || state.isCreating
                    ? null
                    : _onSubmit,
                child: state.isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'إتمام البيع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'اختيار المنتج',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'البحث عن منتج...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.inventory),
                          title: Text('منتج ${index + 1}'),
                          subtitle: Text('${(index + 1) * 10} ر.س'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {
                              final item = SaleItem(
                                productId: 'prod_$index',
                                productName: 'منتج ${index + 1}',
                                quantity: 1,
                                unitPrice: (index + 1) * 10.0,
                                discount: 0,
                              );
                              context
                                  .read<SaleBloc>()
                                  .add(AddSaleItem(item));
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onClear() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('مسح البيع'),
          content: const Text('هل أنت متأكد من مسح جميع البيانات؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<SaleBloc>().add(const ClearCurrentSale());
                setState(() {
                  _selectedCustomerId = null;
                  _selectedCustomerName = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('مسح'),
            ),
          ],
        );
      },
    );
  }

  void _onSubmit() {
    final state = context.read<SaleBloc>().state;

    final sale = Sale(
      id: '',
      customerId: _selectedCustomerId,
      customerName: _selectedCustomerName,
      items: state.currentItems,
      subtotal: state.subtotal,
      discount: state.discount,
      tax: state.tax,
      total: state.total,
      paymentMethod: state.paymentMethod,
      status: 'completed',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<SaleBloc>().add(CreateSale(sale));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إتمام البيع بنجاح'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
