import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/styles/input.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  static const String routeName = "/feedback";

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  GlobalKey<FormState> _form = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _textController = TextEditingController();

  _resetInputs() {
    _nameController.text = "";
    _phoneController.text = "";
    _textController.text = "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavigationalAppBar(
        context,
        Locales.string(context, "feedback"),
      ),
      floatingActionButton: Container(
        width: 100.w - 1.8 * defaultPadding,
        child: FluidBigButton(
          text: Locales.string(context, "send"),
          onPress: () {
            if (!_form.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Locales.string(context, "fill_in_all_fields")),
                ),
              );
            } else {
              Provider.of<AuthProvider>(context, listen: false)
                  .sendFeedback(_phoneController.text, _nameController.text,
                      _textController.text)
                  .then((value) {
                if (value) {
                  _resetInputs();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Locales.string(context, "feedback_has_been_sent"),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Locales.string(context, "something_went_wrong"),
                      ),
                    ),
                  );
                }
              });
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Locales.string(context, "phone"),
                  style: TextStyles.display2().copyWith(letterSpacing: 0.3),
                ),
                const SizedBox(height: defaultPadding * 3 / 4),
                CustomInput(
                  controller: _phoneController,
                  hintText: "+998 (__) ___ __ __",
                  inputFormatters: [
                    MaskTextInputFormatter(mask: "+998 (##) ### ## ##")
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.length == 0) {
                      return Locales.string(context, "phone_must_be_provided");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 1.5 * defaultPadding),
                Text(
                  Locales.string(context, "first_name"),
                  style: TextStyles.display2().copyWith(letterSpacing: 0.3),
                ),
                const SizedBox(height: defaultPadding * 3 / 4),
                CustomInput(
                  controller: _nameController,
                  hintText: Locales.string(context, "first_name"),
                  validator: (value) {
                    if (value?.length == 0) {
                      return Locales.string(context, "name_must_be_provided");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: defaultPadding * 3 / 4),
                CustomInput(
                  controller: _textController,
                  hintText: Locales.string(context, "write_feedback"),
                  maxLines: 5,
                  validator: (value) {
                    if (value?.length == 0) {
                      return Locales.string(
                          context, "feedback_must_be_provided");
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomInput extends StatelessWidget {
  const CustomInput({
    Key? key,
    this.controller,
    this.hintText,
    this.inputFormatters,
    this.validator,
    this.maxLines,
    this.keyboardType,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        border: InputStyles.inputBorder(),
        enabledBorder: InputStyles.enabledBorder(),
        focusedBorder: InputStyles.focusBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: defaultPadding / 2,
          vertical: (maxLines != null) ? 10 : 0,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 13,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
          color: greyishLight,
        ),
      ),
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}
