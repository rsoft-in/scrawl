import 'package:flutter/material.dart';

class ScrawlOtpTextField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final ScrawlOtpFieldController? otpController;
  final int length;

  const ScrawlOtpTextField(
      {super.key,
      this.onChanged,
      this.onCompleted,
      this.length = 6,
      required this.otpController});

  @override
  State<ScrawlOtpTextField> createState() => ScrawlOtpTextFieldState();
}

class ScrawlOtpTextFieldState extends State<ScrawlOtpTextField> {
  late List<TextEditingController?> _textControllers;
  late List<String> _otp;
  late List<FocusNode?> _focusNodes;

  @override
  void initState() {
    super.initState();
    _textControllers = List<TextEditingController?>.filled(widget.length, null,
        growable: false);
    _otp = List.generate(widget.length, (int i) {
      return '';
    });
    _focusNodes = List<FocusNode?>.filled(widget.length, null, growable: false);
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in _textControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.length, (index) {
          return buildOtpField(context, index);
        }),
      ),
    );
  }

  Widget buildOtpField(BuildContext context, int index) {
    if (_focusNodes[index] == null) _focusNodes[index] = FocusNode();
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 5, left: 5),
        child: TextField(
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          maxLength: 1,
          decoration: const InputDecoration(
            counterText: '',
            filled: false,
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          onChanged: (String value) {
            if (value.isEmpty) {
              if (index == 0) return;
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
            if (value.length == 1) {
              if (index < widget.length - 1) {
                FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
              }
            }

            setState(() {
              _otp[index] = value;
            });
            String currentPin = _otp.join('');
            widget.onChanged!(currentPin);
            if (currentPin.length == widget.length) {
              widget.onCompleted!(currentPin);
            }
          },
        ),
      ),
    );
  }
}

class ScrawlOtpFieldController {
  late ScrawlOtpTextFieldState _scrawlOtpTextFieldState;

  void setOtpTextFieldState(ScrawlOtpTextFieldState state) {
    _scrawlOtpTextFieldState = state;
  }

  void clear() {
    final textFieldLength = _scrawlOtpTextFieldState.widget.length;
    _scrawlOtpTextFieldState._otp = List.generate(textFieldLength, (int i) {
      return '';
    });

    final textControllers = _scrawlOtpTextFieldState._textControllers;
    for (var textController in textControllers) {
      if (textController != null) {
        textController.text = '';
      }
    }

    final firstFocusNode = _scrawlOtpTextFieldState._focusNodes[0];
    if (firstFocusNode != null) {
      firstFocusNode.requestFocus();
    }
  }

  void set(List<String> pin) {
    final textFieldLength = _scrawlOtpTextFieldState.widget.length;
    if (pin.length < textFieldLength) {
      throw Exception(
          "Pin length must be same as field length. Expected: $textFieldLength, Found ${pin.length}");
    }

    _scrawlOtpTextFieldState._otp = pin;
    String newPin = '';

    final textControllers = _scrawlOtpTextFieldState._textControllers;
    for (int i = 0; i < textControllers.length; i++) {
      final textController = textControllers[i];
      final pinValue = pin[i];
      newPin += pinValue;

      if (textController != null) {
        textController.text = pinValue;
      }
    }

    final widget = _scrawlOtpTextFieldState.widget;

    widget.onChanged?.call(newPin);

    widget.onCompleted?.call(newPin);
  }

  void setValue(String value, int position) {
    final maxIndex = _scrawlOtpTextFieldState.widget.length - 1;
    if (position > maxIndex) {
      throw Exception(
          "Provided position is out of bounds for the OtpTextField");
    }

    final textControllers = _scrawlOtpTextFieldState._textControllers;
    final textController = textControllers[position];
    final currentPin = _scrawlOtpTextFieldState._otp;

    if (textController != null) {
      textController.text = value;
      currentPin[position] = value;
    }

    String newPin = "";
    for (var item in currentPin) {
      newPin += item;
    }

    final widget = _scrawlOtpTextFieldState.widget;
    if (widget.onChanged != null) {
      widget.onChanged!(newPin);
    }
  }

  void setFocus(int position) {
    final maxIndex = _scrawlOtpTextFieldState.widget.length - 1;
    if (position > maxIndex) {
      throw Exception(
          "Provided position is out of bounds for the OtpTextField");
    }

    final focusNodes = _scrawlOtpTextFieldState._focusNodes;
    final focusNode = focusNodes[position];

    if (focusNode != null) {
      focusNode.requestFocus();
    }
  }
}
