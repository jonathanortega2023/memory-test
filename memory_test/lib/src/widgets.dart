import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum EntryType { digit, upperLetter, alphaNumeric }

class SingleCharacterTextEntry extends StatefulWidget {
  const SingleCharacterTextEntry({
    Key? key,
    required this.numEntries,
    required this.entryType,
    required this.onChanged,
  }) : super(key: key);

  final int numEntries;
  final EntryType entryType;
  final ValueChanged<String> onChanged;

  @override
  SingleCharacterTextEntryState createState() =>
      SingleCharacterTextEntryState();
}

class SingleCharacterTextEntryState extends State<SingleCharacterTextEntry> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late String _hintText;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.numEntries, (index) => TextEditingController());
    _focusNodes = List.generate(widget.numEntries, (index) => FocusNode());
    _updateHintText();
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SingleCharacterTextEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entryType != oldWidget.entryType) {
      _updateHintText();
    }
  }

  void _updateHintText() {
    if (widget.entryType == EntryType.digit) {
      _hintText = '0';
    } else if (widget.entryType == EntryType.upperLetter ||
        widget.entryType == EntryType.alphaNumeric) {
      _hintText = 'A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.numEntries, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _hintText,
                hintStyle: const TextStyle(fontSize: 48),
              ),
              style: const TextStyle(fontSize: 48),
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.text,
              inputFormatters: _getInputFormatters(),
              textAlign: TextAlign.center,
              onChanged: (value) {
                if (widget.entryType == EntryType.upperLetter) {
                  setState(() {
                    _controllers[index].text = value.toUpperCase();
                  });
                }
                if (value.length == 1) {
                  _focusNodes[index].nextFocus();
                  _updateResult();
                  widget.onChanged(_controllers.map((e) => e.text).join());
                }
              },
            ),
          ),
        );
      }),
    );
  }

  List<TextInputFormatter> _getInputFormatters() {
    final inputFormatters = <TextInputFormatter>[
      LengthLimitingTextInputFormatter(1),
    ];

    if (widget.entryType == EntryType.digit) {
      inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (widget.entryType == EntryType.upperLetter) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')));
    } else if (widget.entryType == EntryType.alphaNumeric) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')));
    }

    return inputFormatters;
  }

  void _updateResult() {
    setState(() {});
  }
}
