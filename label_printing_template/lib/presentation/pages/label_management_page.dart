import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/label_viewmodel.dart';
import '../../domain/entities/label.dart';

class LabelManagementScreen extends StatefulWidget {
  const LabelManagementScreen({super.key});

  @override
  State<LabelManagementScreen> createState() => _LabelManagementScreenState();
}

class _LabelManagementScreenState extends State<LabelManagementScreen> {
  final _contentController = TextEditingController();
  final _qrDataController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _qrDataController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Label Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LabelViewModel>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<LabelViewModel>(
        builder: (context, labelViewModel, child) {
          if (labelViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (labelViewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${labelViewModel.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      labelViewModel.clearError();
                      labelViewModel.refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search labels',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        labelViewModel.clearSearch();
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    labelViewModel.searchLabels(value);
                  },
                ),
              ),

              // Statistics
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: labelViewModel.getLabelStatistics(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final stats = snapshot.data!;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Total',
                                stats['total'].toString(),
                              ),
                              _buildStatItem(
                                'Today',
                                stats['today'].toString(),
                              ),
                              _buildStatItem(
                                'This Week',
                                stats['thisWeek'].toString(),
                              ),
                              _buildStatItem(
                                'This Month',
                                stats['thisMonth'].toString(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Labels list
              Expanded(
                child:
                    labelViewModel.filteredLabels.isEmpty
                        ? const Center(child: Text('No labels found'))
                        : ListView.builder(
                          itemCount: labelViewModel.filteredLabels.length,
                          itemBuilder: (context, index) {
                            final label = labelViewModel.filteredLabels[index];
                            return _buildLabelCard(label, labelViewModel);
                          },
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateLabelDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLabelCard(Label label, LabelViewModel labelViewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        title: Text(
          label.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QR: ${label.qrData}'),
            Text(
              'Created: ${label.createdAt.toString().split('.')[0]}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditLabelDialog(context, label, labelViewModel);
                break;
              case 'delete':
                _showDeleteConfirmation(context, label, labelViewModel);
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  void _showCreateLabelDialog(BuildContext context) {
    _contentController.clear();
    _qrDataController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Label'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Label Content',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _qrDataController,
                  decoration: const InputDecoration(
                    labelText: 'QR Code Data',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_contentController.text.isNotEmpty &&
                      _qrDataController.text.isNotEmpty) {
                    final success = await context
                        .read<LabelViewModel>()
                        .createLabel(
                          content: _contentController.text,
                          qrData: _qrDataController.text,
                        );
                    if (success && mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Label created successfully'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showEditLabelDialog(
    BuildContext context,
    Label label,
    LabelViewModel labelViewModel,
  ) {
    _contentController.text = label.content;
    _qrDataController.text = label.qrData;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Label'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Label Content',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _qrDataController,
                  decoration: const InputDecoration(
                    labelText: 'QR Code Data',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_contentController.text.isNotEmpty &&
                      _qrDataController.text.isNotEmpty) {
                    final updatedLabel = label.copyWith(
                      content: _contentController.text,
                      qrData: _qrDataController.text,
                    );
                    final success = await labelViewModel.updateLabel(
                      updatedLabel,
                    );
                    if (success && mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Label updated successfully'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Label label,
    LabelViewModel labelViewModel,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Label'),
            content: Text(
              'Are you sure you want to delete "${label.content}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await labelViewModel.deleteLabel(label.id);
                  if (success && mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Label deleted successfully'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
