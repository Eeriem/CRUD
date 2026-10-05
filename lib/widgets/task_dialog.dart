import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final int? index;

  const TaskDialog({super.key, this.task, this.index});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priorityController;
  late TextEditingController _statusController;
  late TextEditingController _notesController;
  late TextEditingController _tagsController;
  late DateTime _selectedDate;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.task?.category ?? '',
    );
    _priorityController = TextEditingController(
      text: widget.task?.priority ?? '',
    );
    _statusController = TextEditingController(text: widget.task?.status ?? '');
    _notesController = TextEditingController(text: widget.task?.notes ?? '');
    _tagsController = TextEditingController(text: widget.task?.tags ?? '');
    _selectedDate = widget.task?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priorityController.dispose();
    _statusController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Task>('taskBox');
      final newTask = Task(
        title: _titleController.text.trim(),
        date: _selectedDate,
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        priority: _priorityController.text.trim(),
        status: _statusController.text.trim(),
        notes: _notesController.text.trim(),
        tags: _tagsController.text.trim(),
      );

      if (isEditing) {
        box.putAt(widget.index!, newTask);
      } else {
        box.add(newTask);
      }

      Navigator.of(context).pop();
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              return null;
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 380, // ← makes it more rectangular / wider
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Task' : 'Add New Task',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _titleController,
                  label: '1. Title',
                  icon: Icons.title,
                  isRequired: true,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _descriptionController,
                  label: '2. Description',
                  icon: Icons.description,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _categoryController,
                  label: '3. Category',
                  icon: Icons.category,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _priorityController,
                  label: '4. Priority',
                  icon: Icons.priority_high,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _statusController,
                  label: '5. Status',
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _notesController,
                  label: '6. Notes',
                  icon: Icons.notes,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _tagsController,
                  label: '7. Tags',
                  icon: Icons.tag,
                ),
                const SizedBox(height: 14),

                // Due Date
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF48FB1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _saveTask,
                      child: Text(isEditing ? 'Update' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
