import 'package:flutter/material.dart';
import 'package:spoki_dart/core.dart';

void main() {
  runApp(const SpokiTestApp());
}

class SpokiTestApp extends StatelessWidget {
  const SpokiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spoki Dart Test',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF2F6B52)),
      home: const SpokiTestPage(),
    );
  }
}

class SpokiTestPage extends StatefulWidget {
  const SpokiTestPage({super.key});

  @override
  State<SpokiTestPage> createState() => _SpokiTestPageState();
}

class _SpokiTestPageState extends State<SpokiTestPage> {
  final _apiKeyController = TextEditingController();
  final _sendTemplateIdController = TextEditingController();
  final _sendPhoneController = TextEditingController();
  final _sendLanguageController = TextEditingController(text: 'IT');

  bool _loadingAccount = false;
  bool _loadingTemplates = false;
  bool _sendingTemplate = false;

  SpokiAccount? _account;
  List<SpokiTemplate> _templates = [];
  String? _errorMessage;
  String? _sendResultMessage;

  Future<void> _loadAccount() async {
    setState(() {
      _loadingAccount = true;
      _errorMessage = null;
    });

    ApiService.getInstance().setApiKey(_apiKeyController.text.trim());

    try {
      final account = await AccountRepository.getPrimary();
      setState(() => _account = account);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _loadingAccount = false);
    }
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _loadingTemplates = true;
      _errorMessage = null;
    });

    ApiService.getInstance().setApiKey(_apiKeyController.text.trim());

    try {
      final templates = await TemplateRepository.list();
      setState(() => _templates = templates);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _loadingTemplates = false);
    }
  }

  Future<void> _sendTemplate() async {
    setState(() {
      _sendingTemplate = true;
      _sendResultMessage = null;
      _errorMessage = null;
    });

    try {
      final templateId = int.parse(_sendTemplateIdController.text.trim());
      final result = await MessageRepository.sendWhatsappTemplate(
        apiKey: _apiKeyController.text.trim(),
        templateId: templateId,
        phone: _sendPhoneController.text.trim(),
        language: _sendLanguageController.text.trim(),
      );
      setState(() => _sendResultMessage = result.raw.toString());
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _sendingTemplate = false);
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _sendTemplateIdController.dispose();
    _sendPhoneController.dispose();
    _sendLanguageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spoki Dart — Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _loadingAccount ? null : _loadAccount,
                  child: _loadingAccount
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Carica account'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loadingTemplates ? null : _loadTemplates,
                  child: _loadingTemplates
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Carica template'),
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
          if (_account != null) ...[
            const SizedBox(height: 20),
            const Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Nome: ${_account!.name ?? "-"}'),
            Text('Credito: ${_account!.currentCreditEuros ?? "-"}€'),
            Text('Stato: ${_account!.status ?? "-"}'),
            Text('Credito basso: ${_account!.isLowCredit}'),
          ],
          if (_templates.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Template', style: TextStyle(fontWeight: FontWeight.bold)),
            for (final t in _templates)
              ListTile(
                dense: true,
                title: Text('${t.name} (id: ${t.id})'),
                subtitle: Text('${t.category.apiValue} — ${t.overallStatus.name}'),
              ),
          ],
          const Divider(height: 40),
          const Text('Invia template (scelto per id, nessuna automazione)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _sendTemplateIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Template ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _sendPhoneController,
            decoration: const InputDecoration(
              labelText: 'Telefono (es. +393331234567)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _sendLanguageController,
            decoration: const InputDecoration(
              labelText: 'Lingua (es. IT)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _sendingTemplate ? null : _sendTemplate,
            child: _sendingTemplate
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Invia'),
          ),
          if (_sendResultMessage != null) ...[
            const SizedBox(height: 12),
            Text(_sendResultMessage!),
          ],
        ],
      ),
    );
  }
}
