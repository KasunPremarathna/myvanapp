import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/van_model.dart';
import '../../models/service_model.dart';
import '../../services/service_record_service.dart';
import '../../theme/app_theme.dart';

class AddServiceScreen extends StatefulWidget {
  final VanModel van;
  final ServiceRecordService serviceService;

  const AddServiceScreen({
    super.key,
    required this.van,
    required this.serviceService,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  DateTime _serviceDate = DateTime.now();
  DateTime? _nextServiceDate;
  bool _noNextDate = false;
  bool _isLoading = false;

  final List<String> _quickTags = [
    'Oil Change',
    'Brake Change',
    'Tire Replacement',
    'Battery Check',
    'Air Filter',
    'Wheel Alignment',
  ];

  void _addTag(String tag) {
    final current = _descriptionCtrl.text;
    if (current.isEmpty) {
      _descriptionCtrl.text = tag;
    } else if (!current.contains(tag)) {
      _descriptionCtrl.text = '$current, $tag';
    }
  }

  Future<void> _pickServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _serviceDate = picked);
  }

  Future<void> _pickNextServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _nextServiceDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final service = ServiceModel(
      id: '',
      vanId: widget.van.id,
      vanModel: widget.van.vanModel,
      serviceDate: _serviceDate,
      description: _descriptionCtrl.text.trim(),
      serviceCost: double.tryParse(_costCtrl.text) ?? 0.0,
      nextServiceDate: _noNextDate ? null : _nextServiceDate,
      createdAt: DateTime.now(),
    );

    try {
      await widget.serviceService.addService(service);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service record added successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      }
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
  void dispose() {
    _descriptionCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Service: ${widget.van.vanModel}'),
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
              // Service date
              InkWell(
                onTap: _pickServiceDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Service Date',
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: AppTheme.primaryColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_serviceDate)),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                validator: (v) =>
                    v!.isEmpty ? 'Please enter service description' : null,
                decoration: const InputDecoration(
                  labelText: 'Service Description *',
                  hintText: 'Type or tap quick options below...',
                  prefixIcon: Icon(Icons.description, color: AppTheme.primaryColor),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              // Quick tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickTags.map((tag) {
                  return ActionChip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _addTag(tag),
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppTheme.primaryColor),
                    side: BorderSide(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Service cost
              TextFormField(
                controller: _costCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Service Cost (LKR)',
                  prefixIcon: Icon(Icons.payments, color: AppTheme.primaryColor),
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: 16),
              // Next service date
              if (!_noNextDate)
                InkWell(
                  onTap: _pickNextServiceDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Next Service Date',
                      prefixIcon: const Icon(Icons.event,
                          color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _nextServiceDate != null
                          ? DateFormat('dd MMM yyyy').format(_nextServiceDate!)
                          : 'Tap to select',
                      style: TextStyle(
                        color: _nextServiceDate != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('No Next Service Date'),
                value: _noNextDate,
                onChanged: (v) => setState(() => _noNextDate = v!),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Add Service'),
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
}
