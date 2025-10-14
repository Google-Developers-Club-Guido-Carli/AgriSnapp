import 'package:flutter/material.dart';
import 'translation_service.dart';

class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  
  const TranslatedText(
    this.text, {
    this.style,
    this.textAlign,
    Key? key,
  }) : super(key: key);
  
  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String translatedText = '';
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _translate();
  }
  
  @override
  void didUpdateWidget(TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translate();
    }
  }
  
  Future<void> _translate() async {
    setState(() => isLoading = true);
    String result = await TranslationService.translate(widget.text);
    setState(() {
      translatedText = result;
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Text(widget.text, style: widget.style, textAlign: widget.textAlign);
    }
    return Text(translatedText, style: widget.style, textAlign: widget.textAlign);
  }
}
