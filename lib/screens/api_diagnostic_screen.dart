// File: lib/screens/api_diagnostic_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/themes/theme_extensions.dart';

/// Diagnostic screen to test API endpoints
class ApiDiagnosticScreen extends StatefulWidget {
  const ApiDiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<ApiDiagnosticScreen> createState() => _ApiDiagnosticScreenState();
}

class _ApiDiagnosticScreenState extends State<ApiDiagnosticScreen> {
  final ApiClient _apiClient = ApiClient();
  final Map<String, dynamic> _results = {};
  bool _isTesting = false;
  String _rawResponse = '';

  final List<String> _endpoints = [
    '/vendor/availablevendors',
    '/vendor/available',
    '/vendors',
    '/vendor',
    '/restaurants',
    '/order/products',
    '/product/foods',
    '/products',
    '/foods',
    '/menu',
    '/auth/me',
    '/order/cart',
    '/wallet/balance',
  ];

  @override
  void initState() {
    super.initState();
    _apiClient.initialize();
  }

  Future<void> _testAllEndpoints() async {
    setState(() {
      _isTesting = true;
      _results.clear();
      _rawResponse = '';
    });

    for (final endpoint in _endpoints) {
      await _testEndpoint(endpoint);
    }

    setState(() => _isTesting = false);
  }

  Future<void> _testEndpoint(String endpoint) async {
    try {
      final response = await _apiClient.get(endpoint);
      
      setState(() {
        _results[endpoint] = {
          'success': response.isSuccess,
          'message': response.isSuccess 
              ? 'Available ✅' 
              : response.errorMessage ?? 'Failed ❌',
        };
      });
    } catch (e) {
      setState(() {
        _results[endpoint] = {
          'success': false,
          'message': 'Error: $e',
        };
      });
    }
  }

  Future<void> _getRawResponse(String endpoint) async {
    setState(() => _rawResponse = 'Loading...');

    try {
      final uri = Uri.parse('https://bezoni.onrender.com$endpoint');
      final response = await _apiClient.get(endpoint);
      
      setState(() {
        _rawResponse = '''
Endpoint: $endpoint
Success: ${response.isSuccess}
Data Type: ${response.data.runtimeType}
Raw Data: ${response.data}
Error: ${response.errorMessage ?? 'None'}
''';
      });
    } catch (e) {
      setState(() {
        _rawResponse = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        title: const Text('API Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isTesting ? null : _testAllEndpoints,
          ),
        ],
      ),
      body: Column(
        children: [
          // Test All Button
          Container(
            padding: const EdgeInsets.all(16),
            color: context.surfaceColor,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _testAllEndpoints,
                icon: _isTesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isTesting ? 'Testing...' : 'Test All Endpoints'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Results List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _endpoints.length,
              itemBuilder: (context, index) {
                final endpoint = _endpoints[index];
                final result = _results[endpoint];

                return Card(
                  color: context.surfaceColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      result == null
                          ? Icons.radio_button_unchecked
                          : result['success']
                              ? Icons.check_circle
                              : Icons.error,
                      color: result == null
                          ? context.subtitleColor
                          : result['success']
                              ? Colors.green
                              : Colors.red,
                    ),
                    title: Text(
                      endpoint,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: context.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: result != null
                        ? Text(
                            result['message'],
                            style: TextStyle(
                              fontSize: 12,
                              color: context.subtitleColor,
                            ),
                          )
                        : null,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.visibility,
                        color: context.primaryColor,
                      ),
                      onPressed: () => _getRawResponse(endpoint),
                    ),
                  ),
                );
              },
            ),
          ),

          // Raw Response Viewer
          if (_rawResponse.isNotEmpty)
            Container(
              height: 200,
              color: context.surfaceColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Raw Response',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.textColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _rawResponse),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() => _rawResponse = '');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _rawResponse,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: context.textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _CustomEndpointDialog(
              apiClient: _apiClient,
            ),
          );
        },
        label: const Text('Test Custom'),
        icon: const Icon(Icons.add),
        backgroundColor: context.primaryColor,
      ),
    );
  }
}

/// Dialog to test custom endpoint
class _CustomEndpointDialog extends StatefulWidget {
  final ApiClient apiClient;

  const _CustomEndpointDialog({required this.apiClient});

  @override
  State<_CustomEndpointDialog> createState() => _CustomEndpointDialogState();
}

class _CustomEndpointDialogState extends State<_CustomEndpointDialog> {
  final _controller = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  Future<void> _test() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final response = await widget.apiClient.get(_controller.text.trim());
      
      setState(() {
        _result = '''
Success: ${response.isSuccess}
Data: ${response.data}
Error: ${response.errorMessage ?? 'None'}
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardColor,
      title: Text('Test Custom Endpoint', style: TextStyle(color: context.textColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            style: TextStyle(color: context.textColor),
            decoration: InputDecoration(
              labelText: 'Endpoint',
              hintText: '/your/endpoint',
              prefixText: 'https://bezoni.onrender.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _result,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: context.textColor,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: context.subtitleColor)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _test,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Test'),
        ),
      ],
    );
  }
}