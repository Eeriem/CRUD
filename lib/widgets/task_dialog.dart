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
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _categoryController = TextEditingController(text: widget.task?.category ?? '');
    _priorityController = TextEditingController(text: widget.task?.priority ?? '');
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '1. Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 2. Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '2. Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // 3. Category
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: '3. Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Priority
              TextFormField(
                controller: _priorityController,
                decoration: const InputDecoration(
                  labelText: '4. Priority (High / Medium / Low)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
              ),
              const SizedBox(height: 12),

              // 5. Status
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(
                  labelText: '5. Status (Pending / Done)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
              ),
              const SizedBox(height: 12),

              // 6. Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '6. Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // 7. Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: '7. Tags',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 12),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}