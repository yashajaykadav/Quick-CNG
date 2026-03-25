import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/providers/user_provider.dart';

class WorkersListSection extends ConsumerStatefulWidget {
  final String stationId;

  const WorkersListSection({super.key, required this.stationId});

  @override
  ConsumerState<WorkersListSection> createState() => _WorkersListSectionState();
}

class _WorkersListSectionState extends ConsumerState<WorkersListSection> {
  final _emailController = TextEditingController();
  bool _isAdding = false;

  // ✅ Adaptive Dialog Helper
  void _showStyledDialog({
    required Widget title,
    required Widget content,
    List<Widget>? actions,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDark
              ? BorderSide(color: Colors.white.withAlpha(20))
              : BorderSide.none,
        ),
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  Future<void> _addWorker() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _isAdding = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          _showSnackBar('No user found with this email.', Colors.red);
        }
        return;
      }

      await querySnapshot.docs.first.reference.update({
        'role': UserRole.worker.name,
        'stationId': widget.stationId,
      });

      _emailController.clear();
      if (mounted) _showSnackBar('Worker added successfully!', Colors.green);
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _removeWorker(String workerUid, String workerName) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        title: const Text('Remove Worker'),
        content: Text('Are you sure you want to remove $workerName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(workerUid)
          .update({
            'role': UserRole.user.name,
            'stationId': FieldValue.delete(),
          });
      if (mounted) _showSnackBar('Worker removed.', Colors.green);
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _showAddWorkerDialog() {
    final theme = Theme.of(context);
    _showStyledDialog(
      title: const Text('Add Worker'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter the email of a registered user to assign them to your station.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'User Email',
              prefixIcon: const Icon(Icons.email_outlined),
              fillColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF1A1A1A)
                  : Colors.grey[100],
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _addWorker();
          },
          child: const Text('Add Worker'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(stationWorkersProvider(widget.stationId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STATION WORKERS',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: theme.hintColor,
              ),
            ),
            if (_isAdding)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.person_add_alt_1, color: Colors.green),
                onPressed: _showAddWorkerDialog,
              ),
          ],
        ),
        const SizedBox(height: 12),
        workersAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Text('Error: $err'),
          data: (workers) {
            if (workers.isEmpty) {
              return _buildEmptyState(theme, isDark);
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workers.length,
              itemBuilder: (context, index) =>
                  _buildWorkerCard(workers[index], theme, isDark),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white.withAlpha(20)) : null,
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: theme.hintColor.withAlpha(100),
          ),
          const SizedBox(height: 12),
          Text(
            'No workers assigned yet',
            style: TextStyle(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(dynamic worker, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white.withAlpha(20)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isDark
              ? Colors.blue[900]?.withAlpha(100)
              : Colors.blue[50],
          backgroundImage: worker.photoURL != null
              ? NetworkImage(worker.photoURL!)
              : null,
          child: worker.photoURL == null
              ? Icon(
                  Icons.person,
                  color: isDark ? Colors.blue[300] : Colors.blue,
                )
              : null,
        ),
        title: Text(
          worker.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          worker.email,
          style: TextStyle(fontSize: 12, color: theme.hintColor),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => _removeWorker(worker.uid, worker.name),
        ),
      ),
    );
  }
}
