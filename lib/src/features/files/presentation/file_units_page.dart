import 'package:flutter/material.dart';
import '../../../core/models/file_models.dart';
import '../../../core/models/course_classroom.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/file_service.dart';
import 'unit_files_page.dart';

class FileUnitsPage extends StatefulWidget {
  final ClassroomClass classroomClass;

  const FileUnitsPage({
    super.key,
    required this.classroomClass,
  });

  @override
  State<FileUnitsPage> createState() => _FileUnitsPageState();
}

class _FileUnitsPageState extends State<FileUnitsPage> {
  FileUnitsData? _fileUnitsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFileUnits();
  }

  Future<void> _loadFileUnits() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final filesUrl = widget.classroomClass.links.files;
      if (filesUrl == null || filesUrl.isEmpty) {
        setState(() {
          _errorMessage = 'No files available for this class';
          _isLoading = false;
        });
        return;
      }

      final response = await FileService.getFileUnits(filesUrl);
      setState(() {
        _fileUnitsData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_fileUnitsData?.name ?? 'File Units'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
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
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFileUnits,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_fileUnitsData == null || _fileUnitsData!.fileUnits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No file units available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _loadFileUnits,
      child: Column(
        children: [
          // Batch Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _fileUnitsData!.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileUnitsData!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _fileUnitsData!.course.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _fileUnitsData!.status == 'Running' 
                                  ? Colors.green 
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _fileUnitsData!.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // File Units List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _fileUnitsData!.fileUnits.length,
              itemBuilder: (context, index) {
                final unit = _fileUnitsData!.fileUnits[index];
                return _buildFileUnitCard(unit);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUnitCard(FileUnit unit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToUnitFiles(unit),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder_open,
                  color: Colors.green,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (unit.subUnitCount > 0) ...[
                          Icon(
                            Icons.folder,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${unit.subUnitCount} sub-unit${unit.subUnitCount != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else if (unit.fileCount > 0) ...[
                          Icon(
                            Icons.picture_as_pdf,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${unit.fileCount} file${unit.fileCount != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Empty unit',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUnitFiles(FileUnit unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnitFilesPage(
          fileUnit: unit,
          batchInfo: _fileUnitsData!,
        ),
      ),
    );
  }
} 