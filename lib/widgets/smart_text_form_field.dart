import 'package:flutter/material.dart';
import '../services/smart_input_service.dart';
import '../utils/app_localizations.dart';

class SmartTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputType? keyboardType;
  final String inputType; // 'name', 'email', 'department', 'phone', 'subject'
  final bool enableTranslation;
  final bool enableAutoCorrect;
  final VoidCallback? onChanged;

  const SmartTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    this.keyboardType,
    required this.inputType,
    this.enableTranslation = true,
    this.enableAutoCorrect = true,
    this.onChanged,
  });

  @override
  State<SmartTextFormField> createState() => _SmartTextFormFieldState();
}

class _SmartTextFormFieldState extends State<SmartTextFormField> {
  ValidationResult? _validationResult;
  bool _showSuggestions = false;
  String _lastValidatedText = '';
  TranslationResult? _translationResult;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text != _lastValidatedText && text.isNotEmpty) {
      _validateInput(text);
      if (widget.enableTranslation && text.length > 2) {
        _translateInput(text);
      }
    }
    _lastValidatedText = text;

    if (widget.onChanged != null) {
      widget.onChanged!();
    }
  }

  void _validateInput(String text) {
    if (!widget.enableAutoCorrect) return;

    ValidationResult result;
    switch (widget.inputType) {
      case 'name':
        result = SmartInputService.validateName(text);
        break;
      case 'email':
        result = SmartInputService.validateEmail(text);
        break;
      case 'department':
        result = SmartInputService.validateDepartment(text);
        break;
      case 'phone':
        result = SmartInputService.validatePhoneNumber(text);
        break;
      default:
        result = SmartInputService.validateName(text); // Default validation
    }

    setState(() {
      _validationResult = result;
      _showSuggestions =
          result.suggestions.isNotEmpty || result.errorMessage != null;
    });
  }

  Future<void> _translateInput(String text) async {
    if (!widget.enableTranslation) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      // Detect current language and translate to opposite
      String targetLanguage = _detectLanguage(text) == 'hi' ? 'en' : 'hi';
      TranslationResult result = await SmartInputService.translateText(
        text,
        targetLanguage,
      );

      setState(() {
        _translationResult = result;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  String _detectLanguage(String text) {
    // Simple language detection based on character patterns
    final hindiPattern = RegExp(r'[\u0900-\u097F]');
    return hindiPattern.hasMatch(text) ? 'hi' : 'en';
  }

  void _applySuggestion(String suggestion) {
    widget.controller.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    _onTextChanged();
  }

  void _applyTranslation() {
    if (_translationResult != null && _translationResult!.confidence > 0.5) {
      widget.controller.text = _translationResult!.translatedText;
      setState(() {
        _translationResult = null;
        _showSuggestions = false;
      });
      _onTextChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon!,
                    color: widget.enabled
                        ? (isDarkMode
                              ? Colors.white70
                              : theme.colorScheme.primary)
                        : Colors.grey[400],
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            border: const OutlineInputBorder(),
            filled: !widget.enabled,
            fillColor: !widget.enabled
                ? (isDarkMode ? Colors.grey[850] : Colors.grey[50])
                : null,
            labelStyle: TextStyle(
              color: widget.enabled
                  ? (isDarkMode ? Colors.white : theme.colorScheme.onSurface)
                  : Colors.grey[500],
            ),
            errorText: _validationResult?.errorMessage,
            errorStyle: const TextStyle(fontSize: 12),
          ),
          style: TextStyle(
            color: widget.enabled
                ? (isDarkMode ? Colors.white : theme.colorScheme.onSurface)
                : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),

        // Smart suggestions panel
        if (_showSuggestions && widget.enabled) _buildSuggestionsPanel(),

        // Translation suggestion
        if (_translationResult != null &&
            _translationResult!.confidence > 0.5 &&
            widget.enabled)
          _buildTranslationPanel(),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (!widget.enabled) {
      return const Tooltip(
        message: 'Tap the edit button to modify this field',
        child: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
      );
    }

    if (_isTranslating) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_validationResult != null) {
      if (_validationResult!.isValid &&
          _validationResult!.suggestions.isEmpty) {
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      } else if (!_validationResult!.isValid) {
        return const Icon(Icons.error, color: Colors.red, size: 20);
      } else if (_validationResult!.suggestions.isNotEmpty) {
        return const Icon(Icons.lightbulb, color: Colors.orange, size: 20);
      }
    }

    return null;
  }

  Widget _buildSuggestionsPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_validationResult?.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationResult!.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          if (_validationResult?.suggestions.isNotEmpty == true) ...[
            if (_validationResult?.errorMessage != null)
              const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.orange[700],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).translate('suggestions'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _validationResult!.suggestions.map((suggestion) {
                      return InkWell(
                        onTap: () => _applySuggestion(suggestion),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            suggestion,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTranslationPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.translate, color: Colors.purple[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).translate('translation_suggestion'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.purple[700],
                  ),
                ),
                Text(
                  _translationResult!.translatedText,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _applyTranslation,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppLocalizations.of(context).translate('apply'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
