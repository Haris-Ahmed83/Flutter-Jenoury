import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _goalController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<StepProvider>();
    _goalController.text = provider.stepGoal.toString();
    _weightController.text = '70';
  }

  @override
  void dispose() {
    _goalController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Step Counter'),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.flag_rounded,
            iconColor: AppColors.stepsColor,
            title: 'Daily Step Goal',
            subtitle: 'Steps you want to hit each day',
            trailing: SizedBox(
              width: 100,
              child: TextField(
                controller: _goalController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                onSubmitted: (value) {
                  final goal = int.tryParse(value);
                  if (goal != null && goal > 0) {
                    context.read<StepProvider>().setStepGoal(goal);
                    _showSaved();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            icon: Icons.monitor_weight_rounded,
            iconColor: AppColors.primary,
            title: 'Body Weight',
            subtitle: 'Used for calorie estimation',
            trailing: SizedBox(
              width: 100,
              child: TextField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  isDense: true,
                  suffixText: 'kg',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                onSubmitted: (value) {
                  final weight = double.tryParse(value);
                  if (weight != null && weight > 0) {
                    context.read<StepProvider>().setUserWeight(weight);
                    _showSaved();
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.distanceColor,
            title: 'FitTrack',
            subtitle: 'Version 1.0.0',
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.caloriesColor,
            title: 'Built with Flutter',
            subtitle: 'Professional fitness tracking app',
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Quick Goals'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [5000, 8000, 10000, 12000, 15000, 20000].map((goal) {
              final isSelected =
                  _goalController.text == goal.toString();
              return ChoiceChip(
                label: Text('${goal ~/ 1000}k'),
                selected: isSelected,
                onSelected: (_) {
                  _goalController.text = goal.toString();
                  context.read<StepProvider>().setStepGoal(goal);
                  _showSaved();
                  setState(() {});
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (trailing != null) ...[trailing],
        ],
      ),
    );
  }

  void _showSaved() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Setting saved'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
