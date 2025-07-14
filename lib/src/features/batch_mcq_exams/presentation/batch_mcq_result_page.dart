import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import '../../../core/models/batch_mcq_models.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/batch_mcq_service.dart';

class BatchMcqResultPage extends StatefulWidget {
  final String resultUrl;

  const BatchMcqResultPage({
    super.key,
    required this.resultUrl,
  });

  @override
  State<BatchMcqResultPage> createState() => _BatchMcqResultPageState();
}

class _BatchMcqResultPageState extends State<BatchMcqResultPage> {
  BatchMcqResultData? _resultData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showDetailedSolutions = false;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await BatchMcqService.getBatchMcqResult(widget.resultUrl);
      
      if (response.success) {
        setState(() {
          _resultData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  int _calculateMarksObtained() {
    if (_resultData == null) return 0;
    
    final marksPerQuestion = double.tryParse(_resultData!.exam.marksPerQuestion) ?? 0;
    final negativeMarks = double.tryParse(_resultData!.exam.negativeMarks) ?? 0;
    
    int totalMarks = 0;
    totalMarks += (_resultData!.correctQuestions * marksPerQuestion).toInt();
    totalMarks -= (_resultData!.wrongQuestions * negativeMarks).toInt();
    
    return totalMarks;
  }

  int _calculateFullMarks() {
    if (_resultData == null) return 0;
    final marksPerQuestion = double.tryParse(_resultData!.exam.marksPerQuestion) ?? 0;
    return (_resultData!.totalQuestions * marksPerQuestion).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_resultData?.exam.name ?? 'Exam Result'),
          backgroundColor: Colors.red,
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
              onPressed: _loadResult,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_resultData == null) {
      return const Center(
        child: Text('No result data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultCard(),
          const SizedBox(height: 16),
          _buildQuestionStatusGrid(),
          const SizedBox(height: 16),
          _buildSolutionsToggle(),
          if (_showDetailedSolutions) ...[
            const SizedBox(height: 16),
            _buildDetailedSolutions(),
          ],
        ],
      ),
    );
  }



  Widget _buildResultCard() {
    final marksObtained = _calculateMarksObtained();
    final fullMarks = _calculateFullMarks();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Result Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildResultRow('Total Questions:', '${_resultData!.totalQuestions}', Colors.black),
            _buildResultRow('Full Marks:', '$fullMarks', Colors.black),
            _buildResultRow('Correct Questions:', '${_resultData!.correctQuestions}', Colors.green),
            _buildResultRow('Wrong Questions:', '${_resultData!.wrongQuestions}', Colors.red),
            _buildResultRow('Leaved Questions:', '${_resultData!.leavedQuestions}', Colors.orange),
            _buildResultRow('Marks Obtained:', '$marksObtained', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStatusGrid() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solution Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.8,
              ),
              itemCount: _resultData!.totalQuestions,
              itemBuilder: (context, index) {
                final questionNumber = index + 1;
                final solution = _resultData!.solutions.firstWhere(
                  (s) => s.question.id == questionNumber,
                  orElse: () => _resultData!.solutions[index < _resultData!.solutions.length ? index : 0],
                );
                return _buildQuestionBox(questionNumber, solution);
              },
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBox(int questionNumber, BatchMcqResultSolution solution) {
    Color color;
    
    if (solution.yourAns.isEmpty) {
      color = Colors.orange;
    } else if (solution.yourAns.toUpperCase() == solution.correctAns.toUpperCase()) {
      color = Colors.green;
    } else {
      color = Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Q-$questionNumber',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Correct', Colors.green),
        _buildLegendItem('Wrong', Colors.red),
        _buildLegendItem('Not Attempted', Colors.orange),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSolutionsToggle() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () {
        setState(() {
          _showDetailedSolutions = !_showDetailedSolutions;
        });
      },
      child: Text(
        _showDetailedSolutions
            ? 'Hide Detailed Solutions'
            : 'Show Detailed Solutions',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildDetailedSolutions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Solutions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _resultData!.solutions.length,
          itemBuilder: (context, index) {
            final solution = _resultData!.solutions[index];
            return _buildSolutionCard(solution, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildSolutionCard(BatchMcqResultSolution solution, int questionNumber) {
    final isCorrect = solution.yourAns.toUpperCase() == solution.correctAns.toUpperCase();
    final isAttempted = solution.yourAns.isNotEmpty;
    
    Color statusColor;
    String statusText;
    
    if (!isAttempted) {
      statusColor = Colors.orange;
      statusText = 'Not Attempted';
    } else if (isCorrect) {
      statusColor = Colors.green;
      statusText = 'Correct';
    } else {
      statusColor = Colors.red;
      statusText = 'Wrong';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Q$questionNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Question text
            Html(
              data: solution.question.question.replaceAll(RegExp(r'style="[^"]*"'), ''),
              shrinkWrap: true,
              extensions: [
                const TableHtmlExtension(), // Enable table support
              ],
              style: {
                "body": Style(
                  fontSize: FontSize(14),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "p": Style(
                  margin: Margins.only(bottom: 8),
                ),
                "h1, h2, h3, h4, h5, h6": Style(
                  margin: Margins.only(bottom: 8),
                ),
                "ul, ol": Style(
                  margin: Margins.only(bottom: 8),
                  padding: HtmlPaddings.only(left: 20),
                ),
                "li": Style(
                  margin: Margins.only(bottom: 4),
                ),
                "strong, b": Style(
                  fontWeight: FontWeight.bold,
                ),
                "em, i": Style(
                  fontStyle: FontStyle.italic,
                ),
                "br": Style(
                  margin: Margins.only(bottom: 4),
                ),
                "img": Style(
                  margin: Margins.only(top: 8, bottom: 8),
                  display: Display.block,
                  textAlign: TextAlign.center,
                ),
                "table": Style(
                  textAlign: TextAlign.center,
                  margin: Margins.only(bottom: 4),
                ),
                "th": Style(
                  padding: HtmlPaddings.all(8),
                  backgroundColor: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey),
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                ),
                "td": Style(
                  padding: HtmlPaddings.all(8),
                  border: Border.all(color: Colors.grey),
                  textAlign: TextAlign.left,
                ),
              },
            ),
            const SizedBox(height: 12),
            
            // Options
            _buildOption('A', solution.question.optA, solution.correctAns, solution.yourAns),
            _buildOption('B', solution.question.optB, solution.correctAns, solution.yourAns),
            _buildOption('C', solution.question.optC, solution.correctAns, solution.yourAns),
            _buildOption('D', solution.question.optD, solution.correctAns, solution.yourAns),
            
            const SizedBox(height: 12),
            
            // Answer summary
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Correct Answer: ${solution.correctAns.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                const SizedBox(width: 16),
                if (isAttempted) ...[
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Your Answer: ${solution.yourAns.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ] else ...[
                  Icon(Icons.remove_circle, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Not Attempted',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String optionLetter, String optionText, String correctAns, String yourAns) {
    final isCorrect = optionLetter.toUpperCase() == correctAns.toUpperCase();
    final isSelected = optionLetter.toUpperCase() == yourAns.toUpperCase();
    
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    if (isCorrect) {
      backgroundColor = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green;
      borderColor = Colors.green;
    } else if (isSelected && !isCorrect) {
      backgroundColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red;
      borderColor = Colors.red;
    } else {
      backgroundColor = Colors.transparent;
      textColor = Colors.black87;
      borderColor = Colors.grey[300]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.transparent),
              border: Border.all(
                color: isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey),
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                optionLetter,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: (isCorrect || isSelected) ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Html(
              data: optionText.replaceAll(RegExp(r'style="[^"]*"'), ''),
              shrinkWrap: true,
              extensions: [
                const TableHtmlExtension(), // Enable table support
              ],
              style: {
                "body": Style(
                  color: textColor,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(13),
                ),
                "p": Style(
                  margin: Margins.zero,
                ),
                "strong, b": Style(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                "em, i": Style(
                  fontStyle: FontStyle.italic,
                  color: textColor,
                ),
                "ul, ol": Style(
                  margin: Margins.only(top: 4, bottom: 4),
                  padding: HtmlPaddings.only(left: 16),
                ),
                "li": Style(
                  margin: Margins.only(bottom: 2),
                  color: textColor,
                ),
                "br": Style(
                  margin: Margins.only(bottom: 2),
                ),
                "img": Style(
                  margin: Margins.only(top: 8, bottom: 8),
                  display: Display.block,
                  textAlign: TextAlign.center,
                ),
                "table": Style(
                  textAlign: TextAlign.center,
                  margin: Margins.only(bottom: 4),
                ),
                "th": Style(
                  padding: HtmlPaddings.all(8),
                  backgroundColor: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey),
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                ),
                "td": Style(
                  padding: HtmlPaddings.all(8),
                  border: Border.all(color: Colors.grey),
                  textAlign: TextAlign.left,
                ),
              },
            ),
          ),
          if (isCorrect)
            Icon(Icons.check_circle, color: Colors.green, size: 20)
          else if (isSelected)
            Icon(Icons.cancel, color: Colors.red, size: 20),
        ],
      ),
    );
  }
} 