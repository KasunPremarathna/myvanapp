import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/van_model.dart';
import '../../models/service_model.dart';
import '../../services/service_record_service.dart';
import '../../theme/app_theme.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final VanModel van;
  final ServiceRecordService serviceService;

  const ServiceHistoryScreen({
    super.key,
    required this.van,
    required this.serviceService,
  });

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  DateTime? _startFilter;
  DateTime? _endFilter;

  void _showFilterDialog() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: (_startFilter != null && _endFilter != null) 
          ? DateTimeRange(start: _startFilter!, end: _endFilter!) 
          : null,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startFilter = picked.start;
        _endFilter = picked.end;
      });
    }
  }

  List<ServiceModel> _applyFilter(List<ServiceModel> services) {
    if (_startFilter == null || _endFilter == null) return services;
    return services.where((s) {
      return s.serviceDate.isAfter(
              _startFilter!.subtract(const Duration(days: 1))) &&
          s.serviceDate.isBefore(_endFilter!.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History: ${widget.van.vanModel}'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter by date',
          ),
          if (_startFilter != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () =>
                  setState(() => _startFilter = _endFilter = null),
              tooltip: 'Clear filter',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_startFilter != null)
            Container(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.date_range,
                      size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(_startFilter!)} — ${DateFormat('dd MMM yyyy').format(_endFilter!)}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<ServiceModel>>(
              stream: widget.serviceService
                  .getServices(vanId: widget.van.id),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snap.data ?? [];
                final filtered = _applyFilter(all);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history,
                            size: 64, color: Color(0xFFD1D5DB)),
                        const SizedBox(height: 16),
                        Text(
                          all.isEmpty
                              ? 'No service records yet'
                              : 'No records in selected range',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // Summary
                final totalCost =
                    filtered.fold(0.0, (s, r) => s + r.serviceCost);

                return Column(
                  children: [
                    // Total cost banner
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryLight
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.build,
                              color: Colors.white70, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Service Cost',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                              Text(
                                'LKR ${totalCost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${filtered.length} record${filtered.length != 1 ? 's' : ''}',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) =>
                            _ServiceCard(record: filtered[i], service: widget.serviceService),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel record;
  final ServiceRecordService service;

  const _ServiceCard({required this.record, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM yyyy').format(record.serviceDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'LKR ${record.serviceCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                      onPressed: () => service.deleteService(record.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              record.description,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            if (record.nextServiceDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_available,
                      size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(
                    'Next: ${DateFormat('dd MMM yyyy').format(record.nextServiceDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
