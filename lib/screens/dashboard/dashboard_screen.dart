import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/van_service.dart';
import '../../services/service_record_service.dart';
import '../../services/fuel_service.dart';
import '../../models/van_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../vans/vans_screen.dart';
import '../fuel/fuel_screen.dart';
import '../fuelpass/fuel_pass_screen.dart';
import '../profile/profile_screen.dart';
import '../vans/add_van_screen.dart';
import '../service/add_service_screen.dart';
import '../service/service_history_screen.dart';
import '../reminder/set_reminder_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  double _totalServiceCost = 0;
  double _totalFuelCost = 0;

  late AuthService _authService;
  late VanService _vanService;
  late ServiceRecordService _serviceService;
  late FuelService _fuelService;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _vanService = VanService(_authService);
    _serviceService = ServiceRecordService(_authService);
    _fuelService = FuelService(_authService);
    _loadCosts();
  }

  Future<void> _loadCosts() async {
    final services =
        await _serviceService.getServicesFiltered(_startDate, _endDate);
    final fuels = await _fuelService.getFuelFiltered(_startDate, _endDate);
    if (mounted) {
      setState(() {
        _totalServiceCost =
            services.fold(0, (sum, s) => sum + s.serviceCost);
        _totalFuelCost = fuels.fold(0, (sum, f) => sum + f.cost);
      });
    }
  }

  void _showDateFilter() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadCosts();
    }
  }

  Widget _buildDashboardBody() {
    return RefreshIndicator(
      onRefresh: _loadCosts,
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${_authService.displayName.split(' ').first}! 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Text(
                        'Manage your vans & services',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _showDateFilter,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('dd MMM yyyy').format(_startDate)} — ${DateFormat('dd MMM yyyy').format(_endDate)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Cost summary vands
            Row(
              children: [
                Expanded(
                  child: _CostCard(
                    title: 'Service Cost',
                    amount: _totalServiceCost,
                    icon: Icons.build_circle,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CostCard(
                    title: 'Fuel Cost',
                    amount: _totalFuelCost,
                    icon: Icons.local_gas_station,
                    color: const Color(0xFF0E93A0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Vans section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Vans',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddVanScreen(
                            vanService: _vanService)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Van'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<VanModel>>(
              stream: _vanService.getVans(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final vans = snap.data ?? [];
                if (vans.isEmpty) {
                  return _EmptyVans();
                }
                return Column(
                  children: vans
                      .map((van) => _VanCard(
                            van: van,
                            vanService: _vanService,
                            serviceService: _serviceService,
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboardBody(),
      VansScreen(vanService: _vanService, serviceService: _serviceService),
      FuelScreen(fuelService: _fuelService, vanService: _vanService),
      const FuelPassScreen(),
      ProfileScreen(authService: _authService),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.airport_shuttle, size: 28),
            SizedBox(width: 8),
            Text(
              'My Van',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 20,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _CostCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'LKR ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVans extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.airport_shuttle, size: 48, color: Color(0xFFD1D5DB)),
          SizedBox(height: 12),
          Text(
            'No vans yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap "Add Van" to get started',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _VanCard extends StatelessWidget {
  final VanModel van;
  final VanService vanService;
  final ServiceRecordService serviceService;

  const _VanCard({
    required this.van,
    required this.vanService,
    required this.serviceService,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Van'),
        content: Text('Delete ${van.vanModel}? All service records will remain.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              vanService.deleteVan(van.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

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
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.airport_shuttle,
                      color: AppTheme.primaryColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        van.vanModel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${van.vanNumber} • ${van.vanYear} • ${van.vanCategory}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionChip(
                  label: 'View History',
                  icon: Icons.history,
                  color: AppTheme.primaryColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceHistoryScreen(
                        van: van,
                        serviceService: serviceService,
                      ),
                    ),
                  ),
                ),
                _ActionChip(
                  label: 'Add Service',
                  icon: Icons.build,
                  color: const Color(0xFF059669),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddServiceScreen(
                        van: van,
                        serviceService: serviceService,
                      ),
                    ),
                  ),
                ),
                _ActionChip(
                  label: 'Set Reminder',
                  icon: Icons.alarm,
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SetReminderScreen(van: van),
                    ),
                  ),
                ),
                _ActionChip(
                  label: 'Edit',
                  icon: Icons.edit,
                  color: const Color(0xFF6366F1),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddVanScreen(
                        vanService: vanService,
                        existingVan: van,
                      ),
                    ),
                  ),
                ),
                _ActionChip(
                  label: 'Delete',
                  icon: Icons.delete,
                  color: Colors.red,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
