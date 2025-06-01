import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/services/prompt_service.dart';

/// Test script to verify the updated system prompt is loaded correctly
/// Run with: flutter run test_prompt_update.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env.dev');
  } catch (e) {
    print('Warning: Could not load .env.dev file: $e');
  }

  runApp(PromptTestApp());
}

class PromptTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompt Update Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PromptTestScreen(),
    );
  }
}

class PromptTestScreen extends StatefulWidget {
  @override
  _PromptTestScreenState createState() => _PromptTestScreenState();
}

class _PromptTestScreenState extends State<PromptTestScreen> {
  String _promptContent = 'Loading...';
  bool _isValid = false;
  bool _isLoading = true;
  bool _hasRestrictiveContent = false;

  @override
  void initState() {
    super.initState();
    _loadAndAnalyzePrompt();
  }

  Future<void> _loadAndAnalyzePrompt() async {
    try {
      setState(() => _isLoading = true);

      // Clear cache to ensure we get the latest version
      PromptService.clearCache();

      final prompt = await PromptService.getSystemPrompt();
      final isValid = PromptService.validatePrompt(prompt);

      // Check if the prompt contains our new restrictive language
      final hasRestrictiveContent = prompt.contains('EXCLUSIVELY') &&
          prompt.contains('Politics, political parties, politicians') &&
          prompt.contains('OFF-TOPIC RESPONSE PROTOCOL');

      setState(() {
        _promptContent = prompt;
        _isValid = isValid;
        _hasRestrictiveContent = hasRestrictiveContent;
        _isLoading = false;
      });

      print('=== PROMPT UPDATE TEST RESULTS ===');
      print('Prompt loaded: ${prompt.isNotEmpty}');
      print('Prompt valid: $isValid');
      print('Has restrictive content: $hasRestrictiveContent');
      print('Prompt length: ${prompt.length} characters');
      print('===================================');
    } catch (e) {
      setState(() {
        _promptContent = 'Error loading prompt: $e';
        _isValid = false;
        _hasRestrictiveContent = false;
        _isLoading = false;
      });
      print('ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Update Test'),
        backgroundColor: _hasRestrictiveContent ? Colors.green : Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAndAnalyzePrompt,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: _isValid ? Colors.green[100] : Colors.red[100],
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  _isValid ? Icons.check_circle : Icons.error,
                                  color: _isValid ? Colors.green : Colors.red,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Prompt Valid',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(_isValid ? 'YES' : 'NO'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          color: _hasRestrictiveContent
                              ? Colors.green[100]
                              : Colors.red[100],
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  _hasRestrictiveContent
                                      ? Icons.security
                                      : Icons.warning,
                                  color: _hasRestrictiveContent
                                      ? Colors.green
                                      : Colors.red,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Restrictive Content',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(_hasRestrictiveContent
                                    ? 'FOUND'
                                    : 'MISSING'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Overall Status
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _hasRestrictiveContent && _isValid
                          ? Colors.green[50]
                          : Colors.orange[50],
                      border: Border.all(
                        color: _hasRestrictiveContent && _isValid
                            ? Colors.green
                            : Colors.orange,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _hasRestrictiveContent && _isValid
                          ? '✅ SUCCESS: Updated prompt is loaded with restrictions!'
                          : '⚠️  WARNING: Prompt may not have the latest restrictions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _hasRestrictiveContent && _isValid
                            ? Colors.green[800]
                            : Colors.orange[800],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Prompt Preview
                  Text(
                    'Prompt Content (first 500 chars):',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Text(
                            _promptContent.length > 500
                                ? '${_promptContent.substring(0, 500)}...\n\n[Total length: ${_promptContent.length} characters]'
                                : _promptContent,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
