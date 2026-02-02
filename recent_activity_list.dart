import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivityList({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد نشاطات حديثة',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: activities.map((activity) {
        return _buildActivityItem(activity);
      }).toList(),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type = activity['type'] as String? ?? 'unknown';
    final title = activity['title'] as String? ?? '';
    final subtitle = activity['subtitle'] as String?;
    final timestamp = activity['timestamp'] as DateTime?;
    final amount = activity['amount'] as double?;

    IconData icon;
    Color color;

    switch (type) {
      case 'sale':
        icon = Icons.shopping_cart;
        color = Colors.green;
        break;
      case 'visit':
        icon = Icons.location_on;
        color = Colors.orange;
        break;
      case 'customer':
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      case 'payment':
        icon = Icons.payment;
        color = Colors.purple;
        break;
      case 'collection':
        icon = Icons.account_balance_wallet;
        color = Colors.teal;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : timestamp != null
                ? Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  )
                : null,
        trailing: amount != null
            ? Text(
                '${amount.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  color: type == 'sale' ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
