import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(8.0),
  borderSide: BorderSide(color: Colors.grey.shade400),
);

final inputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
  border: inputBorder,
  focusedBorder: inputBorder,
  enabledBorder: inputBorder,
);

class OTPFields extends StatefulWidget {
  final TextEditingController pin1;
  final TextEditingController pin2;
  final TextEditingController pin3;
  final TextEditingController pin4;
  final TextEditingController pin5;
  final TextEditingController pin6;

  OTPFields({
    Key? key,
    required this.pin1,
    required this.pin2,
    required this.pin3,
    required this.pin4,
    required this.pin5,
    required this.pin6,
  }) : super(key: key);

  @override
  _OTPFieldsState createState() => _OTPFieldsState();
}

class _OTPFieldsState extends State<OTPFields> {
  late FocusNode pin1FN;
  late FocusNode pin2FN;
  late FocusNode pin3FN;
  late FocusNode pin4FN;
  late FocusNode pin5FN;
  late FocusNode pin6FN;

  final pinStyle = TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    pin1FN = FocusNode();
    pin2FN = FocusNode();
    pin3FN = FocusNode();
    pin4FN = FocusNode();
    pin5FN = FocusNode();
    pin6FN = FocusNode();
  }

  @override
  void dispose() {
    pin1FN.dispose();
    pin2FN.dispose();
    pin3FN.dispose();
    pin4FN.dispose();
    pin5FN.dispose();
    pin6FN.dispose();
    super.dispose();
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOTPTextField(widget.pin1, pin1FN, pin2FN),
              _buildOTPTextField(widget.pin2, pin2FN, pin3FN),
              _buildOTPTextField(widget.pin3, pin3FN, pin4FN),
              _buildOTPTextField(widget.pin4, pin4FN, pin5FN),
              _buildOTPTextField(widget.pin5, pin5FN, pin6FN),
              _buildOTPTextField(widget.pin6, pin6FN, null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOTPTextField(TextEditingController controller, FocusNode currentFocus, FocusNode? nextFocus) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        controller: controller,
        focusNode: currentFocus,
        autofocus: currentFocus == pin1FN,
        style: pinStyle,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.center,
        decoration: inputDecoration,
        inputFormatters: [UpperCaseTextFormatter()],
        onChanged: (value) {
          if (nextFocus != null && value.length == 1) {
            nextField(value, nextFocus);
          } else if (nextFocus == null && value.length == 1) {
            currentFocus.unfocus();
          }
        },
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
