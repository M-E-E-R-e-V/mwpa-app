import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';
import 'package:provider/provider.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// DateInput - date picked with the date picker (value.dateValue).
class DateInput extends StatefulWidget {
  final String? title;
  final DynInputValue value;
  final VoidCallback? onChange;

  const DateInput({super.key, this.title, required this.value, this.onChange});

  static final DateTime firstDate = DateTime(2015);
  static final DateTime lastDate = DateTime(2040);

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  Future<void> _pick() async {
    var initial = widget.value.dateValue;

    if (initial.isBefore(DateInput.firstDate) || initial.isAfter(DateInput.lastDate)) {
      initial = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateInput.firstDate,
      lastDate: DateInput.lastDate,
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
      child: TapField(
        text: DateFormat.yMd().format(widget.value.dateValue),
        icon: Icons.calendar_today_outlined,
        onTap: _pick,
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
      child: TapField(
        text: widget.value.timeValue?.format(context) ?? '',
        hint: '--:--',
        icon: Icons.schedule,
        onTap: _pick,
      ),
    );
  }
}

/// LocationInput - takes over the current GPS position (value.posValue)
/// with the button in the field; shows the accuracy of the stored position.
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
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(context.l10n.noGpsPositionYet)),
      );
      return;
    }

    setState(() => widget.value.posValue = position);
    widget.onChange?.call();
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.value.posValue;
    final scheme = Theme.of(context).colorScheme;

    return InputFrame(
      title: widget.title,
      child: InputDecorator(
        isEmpty: pos == null,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.place_outlined, color: inputAccentColor(context)),
          helperText: pos == null ? null : context.l10n.accuracyMeters(pos.accuracy.toInt()),
          suffixIcon: IconButton(
            icon: Icon(Icons.my_location, color: inputAccentColor(context)),
            tooltip: context.l10n.useCurrentPosition,
            onPressed: _takeCurrentPosition,
          ),
        ),
        child: Text(
          pos == null ? context.l10n.noPosition : UtilPosition.getStr(pos),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: pos == null ? scheme.onSurfaceVariant : null,
              ),
        ),
      ),
    );
  }
}
