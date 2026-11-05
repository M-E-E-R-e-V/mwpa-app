import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';

/// BeaufortController - static select list for beaufort wind values
class BeaufortController {


  /// selectList - the values with an empty entry labelled [notSelected]
  /// (in the UI language)
  static List<DynInputSelectItem> selectList(String notSelected) =>
      [DynInputSelectItem(value: "", label: notSelected), ..._values];

  static final _values = <DynInputSelectItem>[
    DynInputSelectItem(value: "0", label: "0"),
    DynInputSelectItem(value: "0.5", label: "0.5"),
    DynInputSelectItem(value: "1", label: "1"),
    DynInputSelectItem(value: "1.5", label: "1.5"),
    DynInputSelectItem(value: "2", label: "2"),
    DynInputSelectItem(value: "2.5", label: "2.5"),
    DynInputSelectItem(value: "3", label: "3"),
    DynInputSelectItem(value: "3.5", label: "3.5"),
    DynInputSelectItem(value: "4", label: "4"),
    DynInputSelectItem(value: "4.5", label: "4.5"),
    DynInputSelectItem(value: "5", label: "5"),
    DynInputSelectItem(value: "5.5", label: "5.5"),
    DynInputSelectItem(value: "6", label: "6"),
    DynInputSelectItem(value: "6.5", label: "6.5"),
    DynInputSelectItem(value: "7", label: "7"),
    DynInputSelectItem(value: "7.5", label: "7.5"),
    DynInputSelectItem(value: "8", label: "8"),
    DynInputSelectItem(value: "8.5", label: "8.5"),
    DynInputSelectItem(value: "9", label: "9"),
    DynInputSelectItem(value: "9.5", label: "9.5"),
    DynInputSelectItem(value: "10", label: "10"),
    DynInputSelectItem(value: "10.5", label: "10.5"),
    DynInputSelectItem(value: "11", label: "11"),
    DynInputSelectItem(value: "11.5", label: "11.5"),
    DynInputSelectItem(value: "12", label: "12")
  ];
}