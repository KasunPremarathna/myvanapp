import 'package:flutter/material.dart';
import '../../models/van_model.dart';
import '../../services/van_service.dart';
import '../../theme/app_theme.dart';

class AddVanScreen extends StatefulWidget {
  final VanService vanService;
  final VanModel? existingVan;

  const AddVanScreen({
    super.key,
    required this.vanService,
    this.existingVan,
  });

  @override
  State<AddVanScreen> createState() => _AddVanScreenState();
}

class _AddVanScreenState extends State<AddVanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vanNumberCtrl = TextEditingController();
  final _vanModelCtrl = TextEditingController();
  final _vanYearCtrl = TextEditingController();
  String _selectedCategory = 'Petrol';
  bool _isLoading = false;

  final List<String> _categories = ['Petrol', 'Electric', 'Hybrid', 'Diesel'];

  @override
  void initState() {
    super.initState();
    if (widget.existingVan != null) {
      _vanNumberCtrl.text = widget.existingVan!.vanNumber;
      _vanModelCtrl.text = widget.existingVan!.vanModel;
      _vanYearCtrl.text = widget.existingVan!.vanYear;
      _selectedCategory = widget.existingVan!.vanCategory;
    }
  }

  @override
  void dispose() {
    _vanNumberCtrl.dispose();
    _vanModelCtrl.dispose();
    _vanYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final van = VanModel(
      id: widget.existingVan?.id ?? '',
      vanNumber: _vanNumberCtrl.text.trim().toUpperCase(),
      vanModel: _vanModelCtrl.text.trim(),
      vanYear: _vanYearCtrl.text.trim(),
      vanCategory: _selectedCategory,
      createdAt: widget.existingVan?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.existingVan != null) {
        await widget.vanService.updateVan(van);
      } else {
        await widget.vanService.addVan(van);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingVan != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Van' : 'Add New Van'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildField(
                controller: _vanNumberCtrl,
                label: 'Van Number *',
                hint: 'e.g. CAS-0000',
                icon: Icons.numbers,
                validator: (v) => v!.isEmpty ? 'Please enter van number' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _vanModelCtrl,
                label: 'Van Model *',
                hint: 'e.g. Toyota Corolla',
                icon: Icons.airport_shuttle,
                validator: (v) => v!.isEmpty ? 'Please enter van model' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _vanYearCtrl,
                label: 'Van Year *',
                hint: 'e.g. 2022',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Please enter year';
                  if (int.tryParse(v) == null) return 'Enter a valid year';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Van Category',
                  prefixIcon: const Icon(Icons.local_gas_station,
                      color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Update Van' : 'Add Van'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
      ),
    );
  }
}
