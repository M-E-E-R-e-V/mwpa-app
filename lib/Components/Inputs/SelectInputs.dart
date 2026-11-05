import 'package:flutter/material.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Constants.dart';

/// SelectInput - one entry out of [items] (value.strValue = item value).
class SelectInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final List<DynInputSelectItem> items;
  final VoidCallback? onChange;

  const SelectInput({
    super.key,
    this.title,
    required this.value,
    required this.items,
    this.onChange,
  });

  @override
  State<SelectInput> createState() => _SelectInputState();
}

class _SelectInputState extends State<SelectInput> {
  String _label() {
    if (widget.items.isEmpty) {
      return "<empty list>";
    }

    final current = widget.value.strValue;

    for (final item in widget.items) {
      if (item.value == current) {
        return item.label;
      }
    }

    if (current != "" && current != "0") {
      return "unknown by id: $current";
    }

    return "<please select>";
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode(context);

    final dropdown = DropdownButton<String>(
      icon: Icon(Icons.keyboard_arrow_down, color: inputIconColor(context)),
      iconSize: 32,
      elevation: 0,
      isExpanded: true,
      style: subTitleStyle(context),
      itemHeight: null,
      dropdownColor: kPrimaryHeaderColor,
      borderRadius: BorderRadius.circular(12),
      underline: const SizedBox.shrink(),
      items: widget.items.map((item) {
        return DropdownMenuItem<String>(
          value: item.value,
          child: IntrinsicWidth(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryColor, width: 1.0),
                borderRadius: BorderRadius.circular(12),
                color: dark ? kPrimaryDarkBackgroundColor : kPrimaryBackgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.label),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (String? selected) {
        if (selected != null) {
          setState(() => widget.value.strValue = selected);
        }

        widget.onChange?.call();
      },
    );

    return InputFrame(
      title: widget.title,
      child: ValueBox(text: _label(), trailing: dropdown),
    );
  }
}

/// MultiSelectInput - list of selects with an add button
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in values)
                  SelectInput(value: entry, items: widget.items),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: kInputHeight,
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.only(left: 14),
              child: DefaultButton(
                buttonIcon: Icons.add_circle,
                width: 50,
                onTab: () => setState(() => values.add(DynInputValue())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
