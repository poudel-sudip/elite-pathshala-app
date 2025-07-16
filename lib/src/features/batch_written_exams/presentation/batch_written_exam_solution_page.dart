import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/batch_written_exam_models.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/batch_written_exam_service.dart';

class BatchWrittenExamSolutionPage extends StatefulWidget {
  final String solutionUrl;
  final BatchWrittenQuestion question;
  final VoidCallback onSolutionUpdated;

  const BatchWrittenExamSolutionPage({
    super.key,
    required this.solutionUrl,
    required this.question,
    required this.onSolutionUpdated,
  });

  @override
  State<BatchWrittenExamSolutionPage> createState() => _BatchWrittenExamSolutionPageState();
}

class _BatchWrittenExamSolutionPageState extends State<BatchWrittenExamSolutionPage> {
  BatchWrittenExamSolutionData? _solutionData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSolution();
  }

  Future<void> _loadSolution() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await BatchWrittenExamService.getBatchWrittenExamSolution(widget.solutionUrl);
      setState(() {
        _solutionData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final List<File> imageFiles = pickedFiles.map((file) => File(file.path)).toList();
        await _uploadImages(imageFiles);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImages(List<File> images) async {
    if (_solutionData == null) return;

    try {
      setState(() {
        _isUploading = true;
      });

      final response = await BatchWrittenExamService.addImageToSolution(
        _solutionData!.addImageLink,
        images,
      );

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
          await _loadSolution();
          widget.onSolutionUpdated();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteImage(BatchWrittenSolutionImage image) async {
    try {
      final response = await BatchWrittenExamService.deleteImageFromSolution(image.deleteLink);
      
      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
          await _loadSolution();
          widget.onSolutionUpdated();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BatchWrittenSolutionImage image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteImage(image);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_solutionData?.exam.name ?? 'Solution'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildAddImageButton(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSolution,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_solutionData == null) {
      return const Center(
        child: Text('No solution data available'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionInfo(),
            const SizedBox(height: 24),
            _buildSolutionImages(),
          ],
        ),
      ),
    );
  }



  Widget _buildQuestionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _solutionData!.question.group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '(${_solutionData!.question.marks} marks)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              'Question:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _solutionData!.question.question,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionImages() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solution Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_solutionData!.solutionImages.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No images uploaded yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _solutionData!.solutionImages.length,
                itemBuilder: (context, index) {
                  final image = _solutionData!.solutionImages[index];
                  return _buildImageCard(image);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(BatchWrittenSolutionImage image) {
    final status = _solutionData!.exam.status.toLowerCase();
    final canEdit = status == 'pending' || status == 'unsolved';

    return Card(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image.imgUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          if (canEdit)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _showDeleteConfirmation(image),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    if (_solutionData == null) return const SizedBox.shrink();

    final status = _solutionData!.exam.status.toLowerCase();
    final canEdit = status == 'pending' || status == 'unsolved';

    if (!canEdit) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getExamStatusColor(status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusMessage(status),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getStatusTextColor(status),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _isUploading ? null : _pickImages,
        icon: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_photo_alternate),
        label: Text(
          _isUploading ? 'Uploading...' : 'Add Images',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'under evaluation':
        return Colors.purple;
      case 'published':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'under evaluation':
        return 'Exam is Under Evaluation - Cannot Edit';
      case 'published':
        return 'Exam Results Published - Cannot Edit';
      default:
        return 'Cannot Edit Answer';
    }
  }

  Color _getExamStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'unsolved':
        return Colors.orange.shade100;
      case 'pending':
        return Colors.blue.shade100;
      case 'under evaluation':
        return Colors.purple.shade100;
      case 'published':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
} 