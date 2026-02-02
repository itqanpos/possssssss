import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/visit/visit_bloc.dart';
import '../blocs/visit/visit_state.dart';
import '../blocs/visit/visit_event.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  static const LatLng _defaultLocation = LatLng(24.7136, 46.6753);

  @override
  void initState() {
    super.initState();
    context.read<VisitBloc>().add(const LoadTodayVisits());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _updateMarkers(List<dynamic> visits) {
    setState(() {
      _markers = visits.where((v) => v.location != null).map((visit) {
        return Marker(
          markerId: MarkerId(visit.id),
          position: LatLng(
            visit.location.latitude,
            visit.location.longitude,
          ),
          infoWindow: InfoWindow(
            title: visit.customerName,
            snippet: visit.purpose ?? 'زيارة',
          ),
          icon: _getMarkerIcon(visit.status),
        );
      }).toSet();
    });
  }

  BitmapDescriptor _getMarkerIcon(String status) {
    switch (status) {
      case 'completed':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen);
      case 'in_progress':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      case 'cancelled':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة الزيارات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.route),
            onPressed: () {
              final state = context.read<VisitBloc>().state;
              if (state.todayVisits.isNotEmpty) {
                final visitIds =
                    state.todayVisits.map((v) => v.id).toList();
                context.read<VisitBloc>().add(
                      GetOptimizedRoute(visitIds),
                    );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state.todayVisits.isNotEmpty) {
            _updateMarkers(state.todayVisits);
          }
          if (state.optimizedRoute != null) {
            setState(() {
              _polylines = {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: state.optimizedRoute!,
                  color: Colors.blue,
                  width: 5,
                ),
              };
            });
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _defaultLocation,
                  zoom: 12,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapToolbarEnabled: true,
                zoomControlsEnabled: true,
              ),
              if (state.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildVisitsList(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVisitsList(VisitState state) {
    if (state.todayVisits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: state.todayVisits.length,
        itemBuilder: (context, index) {
          final visit = state.todayVisits[index];
          return _buildVisitCard(visit);
        },
      ),
    );
  }

  Widget _buildVisitCard(dynamic visit) {
    return GestureDetector(
      onTap: () {
        if (visit.location != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(
                visit.location.latitude,
                visit.location.longitude,
              ),
              16,
            ),
          );
        }
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getStatusColor(visit.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getStatusColor(visit.status).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              visit.customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              visit.purpose ?? 'زيارة',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  _getStatusIcon(visit.status),
                  size: 14,
                  color: _getStatusColor(visit.status),
                ),
                const SizedBox(width: 4),
                Text(
                  _getStatusText(visit.status),
                  style: TextStyle(
                    color: _getStatusColor(visit.status),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.directions_walk;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'مكتمل';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'مجدول';
    }
  }
}
