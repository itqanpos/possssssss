import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../blocs/visit/visit_bloc.dart';
import '../blocs/visit/visit_event.dart';
import '../blocs/customer/customer_bloc.dart';
import '../blocs/customer/customer_event.dart';
import '../blocs/customer/customer_state.dart';

class NewVisitScreen extends StatefulWidget {
  const NewVisitScreen({Key? key}) : super(key: key);

  @override
  State<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends State<NewVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedCustomerName;
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زيارة جديدة'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerSelector(),
              const SizedBox(height: 24),
              _buildDateTimeSelector(),
              const SizedBox(height: 24),
              _buildPurposeField(),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 24),
              _buildLocationSelector(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text(
                    'جدولة الزيارة',
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
                                if (customer.location != null) {
                                  _selectedLocation = LatLng(
                                    customer.location!['latitude'] ?? 0,
                                    customer.location!['longitude'] ?? 0,
                                  );
                                }
                              });
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

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التاريخ والوقت',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _scheduledDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _scheduledDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  DateFormat('yyyy-MM-dd').format(_scheduledDate),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _scheduledTime,
                  );
                  if (time != null) {
                    setState(() {
                      _scheduledTime = time;
                    });
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(
                  _scheduledTime.format(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPurposeField() {
    return TextFormField(
      controller: _purposeController,
      decoration: InputDecoration(
        labelText: 'الغرض من الزيارة',
        hintText: 'مثال: عرض منتجات جديدة',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال الغرض من الزيارة';
        }
        return null;
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'ملاحظات',
        hintText: 'أي ملاحظات إضافية...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الموقع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation ??
                    const LatLng(24.7136, 46.6753),
                zoom: 14,
              ),
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _selectedLocation!,
                      ),
                    }
                  : {},
              onTap: (location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ),
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'الموقع المحدد: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCustomerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار عميل'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final scheduledAt = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

      context.read<VisitBloc>().add(
            ScheduleVisit(
              customerId: _selectedCustomerId!,
              customerName: _selectedCustomerName!,
              scheduledAt: scheduledAt,
              purpose: _purposeController.text,
              notes: _notesController.text.isEmpty
                  ? null
                  : _notesController.text,
              location: _selectedLocation,
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم جدولة الزيارة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
