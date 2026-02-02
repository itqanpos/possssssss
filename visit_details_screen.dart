import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../blocs/visit/visit_bloc.dart';
import '../blocs/visit/visit_event.dart';
import '../blocs/visit/visit_state.dart';

class VisitDetailsScreen extends StatefulWidget {
  final String visitId;

  const VisitDetailsScreen({
    Key? key,
    required this.visitId,
  }) : super(key: key);

  @override
  State<VisitDetailsScreen> createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VisitBloc>().add(LoadVisitDetails(widget.visitId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الزيارة'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reschedule') {
                _showRescheduleDialog();
              } else if (value == 'cancel') {
                _showCancelDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reschedule',
                child: Row(
                  children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 8),
                    Text('إعادة الجدولة'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('إلغاء', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
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
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final visit = state.currentVisit;
          if (visit == null) {
            return const Center(child: Text('الزيارة غير موجودة'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(visit),
                const SizedBox(height: 16),
                if (visit.location != null) _buildLocationCard(visit),
                const SizedBox(height: 16),
                if (visit.checkIn != null) _buildCheckInCard(visit),
                const SizedBox(height: 16),
                if (visit.checkOut != null) _buildCheckOutCard(visit),
                const SizedBox(height: 16),
                if (visit.photos != null && visit.photos!.isNotEmpty)
                  _buildPhotosCard(visit),
                const SizedBox(height: 16),
                if (visit.notes != null) _buildNotesCard(visit.notes!),
                const SizedBox(height: 16),
                if (visit.status == 'scheduled' || visit.status == 'in_progress')
                  _buildActionButtons(visit),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(visit) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    visit.customerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(visit.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'مجدولة: ${dateFormat.format(visit.scheduledAt)}',
                ),
              ],
            ),
            if (visit.purpose != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.assignment, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(visit.purpose),
                ],
              ),
            ],
            if (visit.outcome != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('النتيجة: ${_getOutcomeText(visit.outcome)}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(visit) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'الموقع',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  visit.location.latitude,
                  visit.location.longitude,
                ),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('visit'),
                  position: LatLng(
                    visit.location.latitude,
                    visit.location.longitude,
                  ),
                ),
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard(visit) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      child: ListTile(
        leading: const Icon(Icons.login, color: Colors.green),
        title: const Text('تسجيل الدخول'),
        subtitle: Text(dateFormat.format(visit.checkIn!.at)),
        trailing: Text(
          '${visit.checkIn!.latitude.toStringAsFixed(4)}, ${visit.checkIn!.longitude.toStringAsFixed(4)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckOutCard(visit) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.orange),
        title: const Text('تسجيل الخروج'),
        subtitle: Text(dateFormat.format(visit.checkOut!.at)),
        trailing: Text(
          '${visit.checkOut!.latitude.toStringAsFixed(4)}, ${visit.checkOut!.longitude.toStringAsFixed(4)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosCard(visit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الصور',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: visit.photos!.length,
                itemBuilder: (context, index) {
                  final photo = visit.photos![index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, size: 40),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملاحظات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(notes),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(visit) {
    return Column(
      children: [
        if (visit.status == 'scheduled')
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                final state = context.read<VisitBloc>().state;
                if (state.currentLocation != null) {
                  context.read<VisitBloc>().add(
                        CheckInVisit(
                          visit.id,
                          state.currentLocation!,
                        ),
                      );
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('تسجيل الدخول'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          )
        else if (visit.status == 'in_progress' || visit.status == 'checked_in')
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _showCompleteDialog(visit);
              },
              icon: const Icon(Icons.check),
              label: const Text('إنهاء الزيارة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'scheduled':
        color = Colors.blue;
        label = 'مجدول';
        icon = Icons.event;
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'قيد التنفيذ';
        icon = Icons.directions_walk;
        break;
      case 'checked_in':
        color = Colors.purple;
        label = 'تم التسجيل';
        icon = Icons.login;
        break;
      case 'completed':
        color = Colors.green;
        label = 'مكتمل';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'ملغي';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getOutcomeText(String outcome) {
    switch (outcome) {
      case 'successful':
        return 'ناجحة';
      case 'unsuccessful':
        return 'غير ناجحة';
      case 'rescheduled':
        return 'تم إعادة الجدولة';
      default:
        return outcome;
    }
  }

  void _showRescheduleDialog() {
    DateTime newDate = DateTime.now();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إعادة جدولة الزيارة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: newDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    newDate = date;
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('اختيار التاريخ'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'سبب إعادة الجدولة',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<VisitBloc>().add(
                      RescheduleVisit(
                        widget.visitId,
                        newDate,
                        reasonController.text,
                      ),
                    );
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إلغاء الزيارة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هل أنت متأكد من إلغاء هذه الزيارة؟'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'سبب الإلغاء',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<VisitBloc>().add(
                      CancelVisit(widget.visitId, reasonController.text),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        );
      },
    );
  }

  void _showCompleteDialog(visit) {
    final notesController = TextEditingController();
    String outcome = 'successful';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إنهاء الزيارة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ما نتيجة الزيارة؟'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: outcome,
                items: const [
                  DropdownMenuItem(
                    value: 'successful',
                    child: Text('ناجحة'),
                  ),
                  DropdownMenuItem(
                    value: 'unsuccessful',
                    child: Text('غير ناجحة'),
                  ),
                  DropdownMenuItem(
                    value: 'rescheduled',
                    child: Text('تم إعادة الجدولة'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    outcome = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final state = context.read<VisitBloc>().state;
                if (state.currentLocation != null) {
                  context.read<VisitBloc>().add(
                        CompleteVisit(
                          visit.id,
                          state.currentLocation!,
                          notes: notesController.text,
                          outcome: outcome,
                        ),
                      );
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }
}
