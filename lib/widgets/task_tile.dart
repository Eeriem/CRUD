import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final int index;
  final VoidCallback onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.index,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.key.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task?'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Hive.box<Task>('taskBox').deleteAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${task.title}" deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading Icon
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Date
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(task.date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 6),

                    // Other fields
                    if (task.description.isNotEmpty)
                      _infoText('Description', task.description),
                    if (task.category.isNotEmpty)
                      _infoText('Category', task.category),
                    if (task.priority.isNotEmpty)
                      _infoText('Priority', task.priority),
                    if (task.status.isNotEmpty)
                      _infoText('Status', task.status),
                    if (task.notes.isNotEmpty)
                      _infoText('Notes', task.notes),
                    if (task.tags.isNotEmpty)
                      _infoText('Tags', task.tags),
                  ],
                ),
              ),

              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}