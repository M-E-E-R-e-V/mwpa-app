import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

/// TagInput - free text tags as Material chips with autocomplete.
///
/// A tag is added on Enter, on a separator (space or comma) or by picking a
/// suggestion from [suggestions]; the chip's delete icon removes it. Every
/// change is reported through [onChanged] with the full tag list.
class TagInput extends StatefulWidget {
  final List<String> initialTags;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;
  final String hintText;

  const TagInput({
    super.key,
    required this.initialTags,
    required this.onChanged,
    this.suggestions = const [],
    this.hintText = 'Enter ...',
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  static const _separators = [' ', ','];

  late final List<String> _tags = widget.initialTags
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  final TextEditingController _field = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _field.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final tag = raw.trim();
    _field.clear();

    if (tag.isEmpty || _tags.contains(tag)) {
      return;
    }

    setState(() => _tags.add(tag));
    widget.onChanged(List.unmodifiable(_tags));
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged(List.unmodifiable(_tags));
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && _separators.contains(text[text.length - 1])) {
      _addTag(text.substring(0, text.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      textEditingController: _field,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();

        if (query.isEmpty) {
          return const Iterable<String>.empty();
        }

        return widget.suggestions.where((option) =>
            option.toLowerCase().contains(query) && !_tags.contains(option));
      },
      fieldViewBuilder: (context, field, focusNode, onFieldSubmitted) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in _tags)
                InputChip(
                  label: Text(tag, style: const TextStyle(color: Colors.white)),
                  backgroundColor: kPrimaryColor,
                  deleteIconColor: Colors.white,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                  onDeleted: () => _removeTag(tag),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 80, maxWidth: 220),
                child: IntrinsicWidth(
                  child: TextField(
                    controller: field,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: _tags.isEmpty ? widget.hintText : '',
                    ),
                    onChanged: _onTextChanged,
                    onSubmitted: (text) {
                      _addTag(text);
                      focusNode.requestFocus();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      // Autocomplete has just written the option into the field; turn it
      // into a chip, which clears the field again.
      onSelected: _addTag,
    );
  }
}
