import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/van_model.dart';
import '../../models/fuel_model.dart';
import '../../services/van_service.dart';
import '../../services/fuel_service.dart';
import '../../theme/app_theme.dart';

class FuelScreen extends StatefulWidget {
  final FuelService fuelService;
  final VanService vanService;

  const FuelScreen({
    super.key,
    required this.fuelService,
    required this.vanService,
  });

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litersCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  VanModel? _selectedVan;
  bool _isLoading = false;
  bool _showForm = false;

  @override
  void dispose() {
    _litersCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _addFuel(List<VanModel> vans) async {
    if (_selectedVan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a van')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final fuel = FuelModel(
      id: '',
      vanId: _selectedVan!.id,
      vanModel: _selectedVan!.vanModel,
      fuelLiters: double.tryParse(_litersCtrl.text) ?? 0,
      cost: double.tryParse(_costCtrl.text) ?? 0,
      createdAt: DateTime.now(),
    );

    try {
      await widget.fuelService.addFuelEntry(fuel);
      _litersCtrl.clear();
      _costCtrl.clear();
      setState(() {
        _selectedVan = null;
        _showForm = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fuel entry added!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VanModel>>(
      stream: widget.vanService.getVans(),
      builder: (ctx, vanSnap) {
        final vans = vanSnap.data ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fuel Records',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showForm = !_showForm),
                    icon: Icon(_showForm ? Icons.close : Icons.add, size: 18),
                    label: Text(_showForm ? 'Cancel' : 'Add Fuel'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add fuel form
              if (_showForm)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<VanModel>(
                            initialValue: _selectedVan,
                            hint: const Text('Select a Van'),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.airport_shuttle,
                                  color: AppTheme.primaryColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            items: vans
                                .map((c) => DropdownMenuItem(
                                    value: c, child: Text(c.vanModel)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedVan = v),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _litersCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (v) =>
                                v!.isEmpty ? 'Enter fuel amount' : null,
                            decoration: const InputDecoration(
                              labelText: 'Fuel (Liters)',
                              prefixIcon: Icon(Icons.local_gas_station,
                                  color: AppTheme.primaryColor),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _costCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (v) => v!.isEmpty ? 'Enter cost' : null,
                            decoration: const InputDecoration(
                              labelText: 'Cost (LKR)',
                              prefixIcon: Icon(Icons.payments,
                                  color: AppTheme.primaryColor),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : () => _addFuel(vans),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Add Fuel Entry'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Fuel History',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<FuelModel>>(
                stream: widget.fuelService.getFuelEntries(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final entries = snap.data ?? [];
                  if (entries.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.local_gas_station,
                                size: 48, color: Color(0xFFD1D5DB)),
                            SizedBox(height: 12),
                            Text('No fuel records yet',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  }
                  final total = entries.fold(0.0, (s, f) => s + f.cost);
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0E93A0),
                              const Color(0xFF0E93A0).withValues(alpha: 0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_gas_station,
                                color: Colors.white70, size: 32),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Fuel Cost',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                                Text(
                                  'LKR ${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ...entries.map((f) =>
                          _FuelCard(fuel: f, fuelService: widget.fuelService)),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FuelCard extends StatelessWidget {
  final FuelModel fuel;
  final FuelService fuelService;

  const _FuelCard({required this.fuel, required this.fuelService});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0E93A0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.local_gas_station, color: Color(0xFF0E93A0)),
        ),
        title: Text(fuel.vanModel,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${fuel.fuelLiters.toStringAsFixed(1)} L • ${DateFormat('dd MMM yyyy HH:mm').format(fuel.createdAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LKR ${fuel.cost.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () => fuelService.deleteFuelEntry(fuel.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
