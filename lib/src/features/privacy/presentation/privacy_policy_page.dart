import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/services/api_service.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String? _privacyContent;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await ApiService.getPrivacyPolicy();
      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            _privacyContent = response['data'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to load privacy policy');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadPrivacyPolicy,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: _privacyContent != null
                        ? Html(
                            data: _privacyContent!,
                            style: {
                              "body": Style(
                                fontSize: FontSize(14),
                                lineHeight: LineHeight(1.5),
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "h1": Style(
                                fontSize: FontSize(24),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(bottom: 16),
                              ),
                              "h2": Style(
                                fontSize: FontSize(20),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(top: 24, bottom: 12),
                              ),
                              "h3": Style(
                                fontSize: FontSize(18),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(top: 20, bottom: 10),
                              ),
                              "p": Style(
                                margin: Margins.only(bottom: 16),
                              ),
                              "ul": Style(
                                margin: Margins.only(bottom: 16),
                              ),
                              "li": Style(
                                margin: Margins.only(bottom: 8),
                              ),
                            },
                          )
                        : const Center(
                            child: Text('No privacy policy content available'),
                          ),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load privacy policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPrivacyPolicy,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
} 