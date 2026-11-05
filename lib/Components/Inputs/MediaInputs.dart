import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Components/Inputs/TagChipField.dart';

/// ImageInput - photo from gallery or camera (value.imgPath).
class ImageInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;

  const ImageInput({super.key, this.title, required this.value});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);

    // user didn't take/choose an image
    if (file == null || !mounted) {
      return;
    }

    setState(() => widget.value.imgPath = file.path);
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.value.imgPath;

    return InputFrame(
      title: widget.title,
      child: InputBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: path != ""
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Image.file(File(path)),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text('No image selected'),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DefaultButton(
                  buttonIcon: Icons.image,
                  width: 44,
                  onTab: () => _pick(ImageSource.gallery),
                ),
                DefaultButton(
                  buttonIcon: Icons.camera,
                  width: 44,
                  onTab: () => _pick(ImageSource.camera),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

/// TagInput - free text tags (value.strValue = JSON list of strings; a
/// legacy space separated string is read as well).
class TagInput extends StatelessWidget {
  final String? title;
  final DynInputValue value;
  final List<String> suggestions;
  final VoidCallback? onChange;

  const TagInput({
    super.key,
    this.title,
    required this.value,
    this.suggestions = const [],
    this.onChange,
  });

  /// parseTags - tags stored in [raw] (JSON list or space separated).
  static List<String> parseTags(String raw) {
    if (raw == "") {
      return [];
    }

    try {
      return (jsonDecode(raw) as List<dynamic>).map((e) => "$e").toList();
    } catch (e) {
      if (kDebugMode) {
        print('TagInput::parseTags: $raw');
        print(e);
      }
    }

    return raw.split(" ");
  }

  @override
  Widget build(BuildContext context) {
    return InputFrame(
      title: title,
      child: InputBox(
        width: double.infinity,
        minHeight: kInputHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TagChipField(
          initialTags: parseTags(value.strValue),
          suggestions: suggestions,
          onChanged: (tags) {
            value.strValue = jsonEncode(tags);
            onChange?.call();
          },
        ),
      ),
    );
  }
}
