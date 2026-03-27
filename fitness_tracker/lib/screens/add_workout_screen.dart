import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../services/workout_service.dart';
import '../utils/constants.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Workout? editWorkout;

  const AddWorkoutScreen({super.key, this.editWorkout});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _caloriesController = TextEditingController();

  WorkoutType _selectedType = WorkoutType.running;
  DateTime _startTime = DateTime.now();
  bool _autoCalcCalories = true;
  final List<_SetEntry> _sets = [];

  bool get _isEditing => widget.editWorkout != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final w = widget.editWorkout!;
      _titleController.text = w.title;
      _notesController.text = w.notes;
      _durationController.text = w.durationMinutes.toString();
      _distanceController.text = w.distanceKm?.toString() ?? '';
      _caloriesController.text = w.caloriesBurned.toStringAsFixed(0);
      _selectedType = w.type;
      _startTime = w.startTime;
      _autoCalcCalories = false;
      _sets.addAll(w.sets.map((s) => _SetEntry(
            nameController: TextEditingController(text: s.exerciseName),
            repsController: TextEditingController(text: s.reps.toString()),
            weightController:
                TextEditingController(text: s.weightKg.toString()),
          )));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _caloriesController.dispose();
    for (final set in _sets) {
      set.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Workout' : 'Log Workout'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveWorkout,
            child: Text(
              _isEditing ? 'Update' : 'Save',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _titleController,
              label: 'Workout Title',
              hint: 'e.g., Morning Run, Leg Day',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            _buildDateTimePicker(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _durationController,
                    label: 'Duration (min)',
                    hint: '30',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _recalcCalories(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(v) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _distanceController,
                    label: 'Distance (km)',
                    hint: 'Optional',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCaloriesField(),
            const SizedBox(height: 16),
            _buildSetsSection(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _notesController,
              label: 'Notes',
              hint: 'How did it go?',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Workout Type', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WorkoutType.values.map((type) {
            final isSelected = type == _selectedType;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedType = type);
                _recalcCalories();
                if (_titleController.text.isEmpty ||
                    WorkoutType.values
                        .any((t) => _titleController.text == t.label)) {
                  _titleController.text = type.label;
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(type.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _startTime,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date == null || !mounted) return;

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_startTime),
        );
        if (time == null) return;

        setState(() {
          _startTime = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date & Time',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  '${_startTime.day}/${_startTime.month}/${_startTime.year} at ${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _caloriesController,
                label: 'Calories Burned',
                hint: 'Auto-calculated',
                keyboardType: TextInputType.number,
                enabled: !_autoCalcCalories,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                const Text('Auto', style: AppTextStyles.caption),
                Switch(
                  value: _autoCalcCalories,
                  onChanged: (v) {
                    setState(() => _autoCalcCalories = v);
                    if (v) _recalcCalories();
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSetsSection() {
    final showSets = _selectedType == WorkoutType.weightLifting ||
        _selectedType == WorkoutType.other;

    if (!showSets) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Exercise Sets', style: AppTextStyles.heading3),
            IconButton(
              onPressed: _addSet,
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: set.nameController,
                    decoration: const InputDecoration(
                      hintText: 'Exercise',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: set.repsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Reps',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Text('×', style: TextStyle(color: AppColors.textLight)),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: set.weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'kg',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _sets[index].dispose();
                    _sets.removeAt(index);
                  }),
                  child: const Icon(Icons.close,
                      size: 18, color: AppColors.textLight),
                ),
              ],
            ),
          );
        }),
        if (_sets.isEmpty)
          GestureDetector(
            onTap: _addSet,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFFE5E7EB), style: BorderStyle.solid),
              ),
              child: const Center(
                child: Text('Tap + to add exercise sets',
                    style: AppTextStyles.bodySecondary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _saveWorkout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          _isEditing ? 'Update Workout' : 'Save Workout',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: enabled ? AppColors.surface : const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _addSet() {
    setState(() {
      _sets.add(_SetEntry(
        nameController: TextEditingController(),
        repsController: TextEditingController(text: '10'),
        weightController: TextEditingController(text: '0'),
      ));
    });
  }

  void _recalcCalories() {
    if (!_autoCalcCalories) return;
    final duration = int.tryParse(_durationController.text) ?? 0;
    if (duration > 0) {
      final cal = WorkoutService.estimateCalories(
        type: _selectedType,
        durationMinutes: duration,
      );
      _caloriesController.text = cal.toStringAsFixed(0);
    }
  }

  void _saveWorkout() {
    if (!_formKey.currentState!.validate()) return;

    final duration = int.tryParse(_durationController.text) ?? 0;
    final distance = double.tryParse(_distanceController.text);
    final calories = double.tryParse(_caloriesController.text) ?? 0;

    final exerciseSets = _sets.asMap().entries.map((entry) {
      final set = entry.value;
      return ExerciseSet(
        workoutId: widget.editWorkout?.id ?? 0,
        exerciseName: set.nameController.text,
        setNumber: entry.key + 1,
        reps: int.tryParse(set.repsController.text) ?? 0,
        weightKg: double.tryParse(set.weightController.text) ?? 0,
      );
    }).toList();

    final workout = Workout(
      id: widget.editWorkout?.id,
      title: _titleController.text.trim(),
      type: _selectedType,
      startTime: _startTime,
      endTime: _startTime.add(Duration(minutes: duration)),
      durationMinutes: duration,
      caloriesBurned: calories,
      notes: _notesController.text.trim(),
      sets: exerciseSets,
      distanceKm: distance,
    );

    final provider = context.read<WorkoutProvider>();
    if (_isEditing) {
      provider.updateWorkout(workout);
    } else {
      provider.addWorkout(workout);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Workout updated!' : 'Workout saved!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _SetEntry {
  final TextEditingController nameController;
  final TextEditingController repsController;
  final TextEditingController weightController;

  _SetEntry({
    required this.nameController,
    required this.repsController,
    required this.weightController,
  });

  void dispose() {
    nameController.dispose();
    repsController.dispose();
    weightController.dispose();
  }
}
