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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found with this email.'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      final doc = querySnapshot.docs.first;
      
      // Update their role to worker and assign the station ID
      await doc.reference.update({
        'role': UserRole.worker.name,
        'stationId': widget.stationId,
      });

      _emailController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker added successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding worker: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _removeWorker(String workerUid, String workerName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Worker'),
        content: Text('Are you sure you want to remove $workerName from your station?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Revert their role to basic user and remove the station ID
      await FirebaseFirestore.instance.collection('users').doc(workerUid).update({
        'role': UserRole.user.name,
        'stationId': FieldValue.delete(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker removed.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddWorkerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Worker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the email of a registered user to add them as a worker.'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'User Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _emailController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
             onPressed: () {
                Navigator.pop(ctx);
                _addWorker();
             },
             child: const Text('Add Worker'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(stationWorkersProvider(widget.stationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'STATION WORKERS',
              style: TextStyle(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blueGrey,
              ),
            ),
            if (_isAdding)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              IconButton(
                icon: const Icon(Icons.person_add, color: Colors.green),
                tooltip: 'Add new worker',
                onPressed: _showAddWorkerDialog,
              ),
          ],
        ),
        const SizedBox(height: 12),
        workersAsync.when(
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          )),
          error: (err, stack) => Text('Error loading workers: $err'),
          data: (workers) {
            if (workers.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No workers assigned yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withAlpha(20),
                      backgroundImage: worker.photoURL != null ? NetworkImage(worker.photoURL!) : null,
                      child: worker.photoURL == null ? const Icon(Icons.person, color: Colors.blue) : null,
                    ),
                    title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(worker.email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Remove worker',
                      onPressed: () => _removeWorker(worker.uid, worker.name),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
