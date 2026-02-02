import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../blocs/visit/visit_bloc.dart';
import '../blocs/visit/visit_event.dart';
import '../blocs/visit/visit_state.dart';
import '../models/visit_model.dart';
import 'visit_details_screen.dart';
import 'new_visit_screen.dart';
import 'map_screen.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({Key? key}) : super(key: key);

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<VisitBloc>().add(const LoadTodayVisits());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<VisitBloc>().state;
      if (state is VisitsLoaded && !state.hasReachedMax) {
        context.read<VisitBloc>().add(
              LoadVisits(page: state.currentPage + 1),
            );
      }
    }
  }

  Future<void> _onRefresh() async {
    context.read<VisitBloc>().add(const RefreshVisits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الزيارات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MapScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'اليوم'),
            Tab(text: 'القادمة'),
            Tab(text: 'السابقة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayVisitsTab(),
          _buildUpcomingVisitsTab(),
          _buildPastVisitsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NewVisitScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('زيارة جديدة'),
      ),
    );
  }

  Widget _buildTodayVisitsTab() {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        if (state.isLoading && state.todayVisits.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.todayVisits.isEmpty) {
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

        if (state.todayVisits.isEmpty) {
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
                  'لا توجد زيارات لهذا اليوم',
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
                        builder: (_) => const NewVisitScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('جدولة زيارة'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.todayVisits.length,
            itemBuilder: (context, index) {
              final visit = state.todayVisits[index];
              return _buildVisitCard(visit);
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingVisitsTab() {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        final upcomingVisits = state.visits
            .where((v) =>
                v.scheduledAt.isAfter(DateTime.now()) &&
                v.status != 'cancelled')
            .toList();

        if (upcomingVisits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد زيارات قادمة',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: upcomingVisits.length,
          itemBuilder: (context, index) {
            final visit = upcomingVisits[index];
            return _buildVisitCard(visit);
          },
        );
      },
    );
  }

  Widget _buildPastVisitsTab() {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        final pastVisits = state.visits
            .where((v) =>
                v.scheduledAt.isBefore(DateTime.now()) ||
                v.status == 'completed' ||
                v.status == 'cancelled')
            .toList();

        if (pastVisits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد زيارات سابقة',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: state.hasReachedMax
              ? pastVisits.length
              : pastVisits.length + 1,
          itemBuilder: (context, index) {
            if (index >= pastVisits.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final visit = pastVisits[index];
            return _buildVisitCard(visit);
          },
        );
      },
    );
  }

  Widget _buildVisitCard(Visit visit) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final timeFormat = DateFormat('HH:mm');

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
              builder: (_) => VisitDetailsScreen(visitId: visit.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(visit.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(visit.scheduledAt),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (visit.purpose != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.assignment,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      visit.purpose!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              if (visit.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${visit.location!.latitude.toStringAsFixed(4)}, ${visit.location!.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  visit.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
              if (visit.status == 'in_progress' || visit.status == 'checked_in')
                ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _completeVisit(visit);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('إنهاء'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _completeVisit(Visit visit) {
    showDialog(
      context: context,
      builder: (context) {
        final notesController = TextEditingController();
        String outcome = 'successful';

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
                          visitId: visit.id,
                          location: state.currentLocation!,
                          notes: notesController.text,
                          outcome: outcome,
                        ),
                      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('جاري تحديد الموقع...'),
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
