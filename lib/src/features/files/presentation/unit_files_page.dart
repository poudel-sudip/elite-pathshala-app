import 'package:flutter/material.dart';
import '../../../core/models/file_models.dart';
import '../../../core/utils/nepal_timezone.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/file_service.dart';
import 'pdf_viewer_page.dart';

class UnitFilesPage extends StatefulWidget {
  final FileUnit fileUnit;
  final FileUnitsData batchInfo;

  const UnitFilesPage({
    super.key,
    required this.fileUnit,
    required this.batchInfo,
  });

  @override
  State<UnitFilesPage> createState() => _UnitFilesPageState();
}

class _UnitFilesPageState extends State<UnitFilesPage> {
  UnitFilesData? _unitData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUnitFiles();
  }

  Future<void> _loadUnitFiles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await FileService.getUnitFiles(widget.fileUnit.fileApiLink);
      setState(() {
        _unitData = response.data;
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
          title: Text(_unitData?.batch.name ?? 'Files'),
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
              onPressed: _loadUnitFiles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_unitData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _loadUnitFiles,
      child: Column(
        children: [
          // Unit Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _unitData!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (_unitData!.hasSubUnits)
                  Text(
                    '${_unitData!.subUnitCount} sub-unit${_unitData!.subUnitCount != 1 ? 's' : ''} available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  )
                else if (_unitData!.hasPdfFiles)
                  Text(
                    '${_unitData!.fileCount} file${_unitData!.fileCount != 1 ? 's' : ''} available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  )
                else
                  Text(
                    'Empty unit',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          // Content List
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // If unit has sub-units, show sub-units (ignoring PDF files)
    if (_unitData!.hasSubUnits) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _unitData!.fileUnits.length,
        itemBuilder: (context, index) {
          final subUnit = _unitData!.fileUnits[index];
          return _buildSubUnitCard(subUnit);
        },
      );
    }
    
    // If unit has PDF files and no sub-units, show PDF files
    if (_unitData!.hasPdfFiles) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _unitData!.pdfFiles.length,
        itemBuilder: (context, index) {
          final pdfFile = _unitData!.pdfFiles[index];
          return _buildPdfFileCard(pdfFile, index + 1);
        },
      );
    }
    
    // Empty unit
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'This unit is empty',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSubUnitCard(FileUnit subUnit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToSubUnit(subUnit),
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
                  Icons.folder,
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
                      subUnit.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (subUnit.subUnitCount > 0) ...[
                          Icon(
                            Icons.folder,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${subUnit.subUnitCount} sub-unit${subUnit.subUnitCount != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.picture_as_pdf,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${subUnit.fileCount} file${subUnit.fileCount != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
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

  Widget _buildPdfFileCard(PdfFile pdfFile, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToPdfViewer(pdfFile),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // PDF Icon/Index
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                    // Positioned(
                    //   bottom: 4,
                    //   right: 4,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    //     decoration: BoxDecoration(
                    //       color: Colors.red,
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: Text(
                    //       index.toString(),
                    //       style: const TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 10,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // File Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pdfFile.fileTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${pdfFile.userName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(pdfFile.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // View arrow indicator
              Icon(
                Icons.open_in_new,
                color: Colors.green,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    return NepalTimezone.formatNotificationDate(dateString);
  }

  void _navigateToSubUnit(FileUnit subUnit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnitFilesPage(
          fileUnit: subUnit,
          batchInfo: widget.batchInfo,
        ),
      ),
    );
  }

  void _navigateToPdfViewer(PdfFile pdfFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          pdfFile: pdfFile,
          unitData: _unitData!,
        ),
      ),
    );
  }
} 