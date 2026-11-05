import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';
import 'package:provider/provider.dart';

/// DateInput - date picked with the date picker (value.dateValue).
class DateInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final VoidCallback? onChange;

  const DateInput({super.key, this.title, required this.value, this.onChange});

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2040),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() => widget.value.dateValue = picked);
    widget.onChange?.call();
  }

  @override
  Widget build(BuildContext context) {
    return InputFrame(
      title: widget.title,
      child: ValueBox(
        text: DateFormat.yMd().format(widget.value.dateValue),
        trailing: IconButton(
          icon: Icon(Icons.calendar_today_outlined, color: inputIconColor(context)),
          onPressed: _pick,
        ),
      ),
    );
  }
}

/// TimeInput - time of day picked with the time picker (value.timeValue).
class TimeInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final VoidCallback? onChange;

  const TimeInput({super.key, this.title, required this.value, this.onChange});

  @override
  State<TimeInput> createState() => _TimeInputState();
}

class _TimeInputState extends State<TimeInput> {
  Future<void> _pick() async {
    final picked = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: widget.value.timeValue ?? TimeOfDay.now(),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() => widget.value.timeValue = picked);
    widget.onChange?.call();
  }

  @override
  Widget build(BuildContext context) {
    return InputFrame(
      title: widget.title,
      child: ValueBox(
        text: widget.value.timeValue?.format(context) ?? '',
        trailing: IconButton(
          icon: Icon(Icons.access_time_rounded, color: inputIconColor(context)),
          onPressed: _pick,
        ),
      ),
    );
  }
}

/// LocationInput - takes over the current GPS position (value.posValue);
/// the title shows the accuracy of the stored position.
class LocationInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final VoidCallback? onChange;

  const LocationInput({super.key, this.title, required this.value, this.onChange});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  void _takeCurrentPosition() {
    final position = context.read<LocationController>().currentPosition;

    // no GPS fix yet - nothing to take over
    if (position == null) {
      return;
    }

    setState(() => widget.value.posValue = position);
    widget.onChange?.call();
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.value.posValue;
    var title = widget.title;

    if (title != null && pos != null) {
      title += " (accuracy: ${pos.accuracy.toInt()} m)";
    }

    return InputFrame(
      title: title,
      child: ValueBox(
        text: pos == null ? '' : UtilPosition.getStr(pos),
        trailing: IconButton(
          icon: Icon(Icons.edit_location, color: inputIconColor(context)),
          onPressed: _takeCurrentPosition,
        ),
      ),
    );
  }
}
