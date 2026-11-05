import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Components/Inputs/TagChipField.dart';
import 'package:mwpaapp/Util/UtilImage.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// ImageInput - photo from gallery or camera (value.imgPath); the picked
/// file is copied to app storage (see [UtilImage.persist]).
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
    if (file == null) {
      return;
    }

    final path = await UtilImage.persist(file.path);

    if (!mounted) {
      return;
    }

    setState(() => widget.value.imgPath = path);
  }

  Widget _placeholder(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.value.imgPath;

    return InputFrame(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (path == "")
            _placeholder(context, Icons.add_photo_alternate_outlined, 'No image selected')
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(path),
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) =>
                    _placeholder(context, Icons.broken_image_outlined, 'Image not found'),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                  onPressed: () => _pick(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                  onPressed: () => _pick(ImageSource.camera),
                ),
              ),
              if (path != "") ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove image',
                  onPressed: () => setState(() => widget.value.imgPath = ""),
                ),
              ],
            ],
          ),
        ],
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
      AppLog.w('Input', 'parseTags: $raw', e);
    }

    return raw.split(" ");
  }

  @override
  Widget build(BuildContext context) {
    return InputFrame(
      title: title,
      child: InputDecorator(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        child: TagChipField(
          hintText: 'Add tag ...',
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
