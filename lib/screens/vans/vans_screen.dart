import 'package:flutter/material.dart';
import '../../models/van_model.dart';
import '../../services/van_service.dart';
import '../../services/service_record_service.dart';
import '../service/add_service_screen.dart';
import '../service/service_history_screen.dart';
import '../reminder/set_reminder_screen.dart';
import 'add_van_screen.dart';
import '../../theme/app_theme.dart';

class VansScreen extends StatelessWidget {
  final VanService vanService;
  final ServiceRecordService serviceService;

  const VansScreen({
    super.key,
    required this.vanService,
    required this.serviceService,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Vans',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddVanScreen(vanService: vanService)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Van'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<VanModel>>(
              stream: vanService.getVans(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final vans = snap.data ?? [];
                if (vans.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.airport_shuttle,
                            size: 64, color: Color(0xFFD1D5DB)),
                        SizedBox(height: 16),
                        Text('No vans added yet',
                            style: TextStyle(
                                fontSize: 18, color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: vans.length,
                  itemBuilder: (ctx, i) => _VanListTile(
                    van: vans[i],
                    vanService: vanService,
                    serviceService: serviceService,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VanListTile extends StatelessWidget {
  final VanModel van;
  final VanService vanService;
  final ServiceRecordService serviceService;

  const _VanListTile({
    required this.van,
    required this.vanService,
    required this.serviceService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.airport_shuttle, color: AppTheme.primaryColor),
        ),
        title: Text(van.vanModel,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${van.vanNumber} • ${van.vanYear}'),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (action) {
            switch (action) {
              case 'history':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ServiceHistoryScreen(
                            van: van, serviceService: serviceService)));
                break;
              case 'add_service':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddServiceScreen(
                            van: van, serviceService: serviceService)));
                break;
              case 'reminder':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SetReminderScreen(van: van)));
                break;
              case 'edit':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddVanScreen(
                            vanService: vanService, existingVan: van)));
                break;
              case 'delete':
                vanService.deleteVan(van.id);
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'history', child: Text('View History')),
            PopupMenuItem(value: 'add_service', child: Text('Add Service')),
            PopupMenuItem(value: 'reminder', child: Text('Set Reminder')),
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
