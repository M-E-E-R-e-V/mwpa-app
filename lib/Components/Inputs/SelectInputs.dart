import 'package:flutter/material.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// SelectInput - one entry out of [items] (value.strValue = item value).
///
/// With [searchable] the list can be filtered by typing into the field;
/// by default only long lists (more than [searchThreshold] items, e.g.
/// species) are searchable.
class SelectInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final List<DynInputSelectItem> items;
  final VoidCallback? onChange;
  final bool? searchable;

  static const int searchThreshold = 15;

  const SelectInput({
    super.key,
    this.title,
    required this.value,
    required this.items,
    this.onChange,
    this.searchable,
  });

  @override
  State<SelectInput> createState() => _SelectInputState();
}

class _SelectInputState extends State<SelectInput> {
  @override
  Widget build(BuildContext context) {
    return InputFrame(
      title: widget.title,
      child: SelectField(
        value: widget.value,
        items: widget.items,
        searchable: widget.searchable,
        onChange: () {
          setState(() {});
          widget.onChange?.call();
        },
      ),
    );
  }
}

/// SelectField - the dropdown of a [SelectInput] without title and spacing.
class SelectField extends StatelessWidget {
  final DynInputValue value;
  final List<DynInputSelectItem> items;
  final VoidCallback? onChange;
  final bool? searchable;

  const SelectField({
    super.key,
    required this.value,
    required this.items,
    this.onChange,
    this.searchable,
  });

  String _hint(BuildContext context, DynInputSelectItem? selected) {
    if (items.isEmpty) {
      return context.l10n.selectEmptyList;
    }

    final current = value.strValue;

    if (selected == null && current != "" && current != "0") {
      return context.l10n.selectUnknownId(current);
    }

    return context.l10n.selectPlease;
  }

  @override
  Widget build(BuildContext context) {
    final current = value.strValue;
    DynInputSelectItem? selected;

    for (final item in items) {
      if (item.value == current) {
        selected = item;
        break;
      }
    }

    final searchable = this.searchable ?? items.length > SelectInput.searchThreshold;

    return DropdownMenu<String>(
      // the page may set the value from outside (e.g. tour defaults loaded
      // async) - a new key re-applies the initial selection
      key: ValueKey('$current/${items.length}'),
      initialSelection: selected?.value,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 360,
      hintText: _hint(context, selected),
      enabled: items.isNotEmpty,
      enableFilter: searchable,
      requestFocusOnTap: searchable,
      leadingIcon: searchable ? const Icon(Icons.search) : null,
      trailingIcon: const Icon(Icons.keyboard_arrow_down),
      selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up),
      menuStyle: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dropdownMenuEntries: [
        for (final item in items)
          DropdownMenuEntry<String>(value: item.value, label: item.label),
      ],
      onSelected: (String? selectedValue) {
        if (selectedValue == null) {
          return;
        }

        value.strValue = selectedValue;
        onChange?.call();
      },
    );
  }
}

/// MultiSelectInput - list of selects with add / remove buttons
/// (value.multiValue, one DynInputValue per select).
class MultiSelectInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final List<DynInputSelectItem> items;

  const MultiSelectInput({
    super.key,
    this.title,
    required this.value,
    required this.items,
  });

  @override
  State<MultiSelectInput> createState() => _MultiSelectInputState();
}

class _MultiSelectInputState extends State<MultiSelectInput> {
  @override
  Widget build(BuildContext context) {
    final values = widget.value.multiValue;

    if (values.isEmpty) {
      values.add(DynInputValue());
    }

    return InputFrame(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, entry) in values.indexed)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
              child: Row(
                children: [
                  Expanded(
                    child: SelectField(
                      key: ObjectKey(entry),
                      value: entry,
                      items: widget.items,
                      onChange: () => setState(() {}),
                    ),
                  ),
                  if (values.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: context.l10n.remove,
                      onPressed: () => setState(() => values.remove(entry)),
                    ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: Text(context.l10n.add),
                onPressed: () => setState(() => values.add(DynInputValue())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
