import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/services/prompt_service.dart';

/// Demo script to show PromptService functionality
/// Run with: flutter run example/prompt_service_demo.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env.dev');

  runApp(PromptServiceDemo());
}

class PromptServiceDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompt Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PromptDemoScreen(),
    );
  }
}

class PromptDemoScreen extends StatefulWidget {
  @override
  _PromptDemoScreenState createState() => _PromptDemoScreenState();
}

class _PromptDemoScreenState extends State<PromptDemoScreen> {
  String _promptContent = 'Loading...';
  bool _isValid = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
  }

  Future<void> _loadPrompt() async {
    try {
      setState(() => _isLoading = true);

      final prompt = await PromptService.getSystemPrompt();
      final isValid = PromptService.validatePrompt(prompt);

      setState(() {
        _promptContent = prompt;
        _isValid = isValid;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _promptContent = 'Error loading prompt: $e';
        _isValid = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Service Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              PromptService.clearCache();
              _loadPrompt();
            },
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
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prompt Status',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _isValid ? Icons.check_circle : Icons.error,
                                color: _isValid ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _isValid ? 'Valid' : 'Invalid',
                                style: TextStyle(
                                  color: _isValid ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Length: ${_promptContent.length} characters',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Prompt Content:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Text(
                            _promptContent,
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
