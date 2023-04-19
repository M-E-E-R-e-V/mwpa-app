import 'package:get/get.dart';
import 'package:mwpaapp/Components/DynInput.dart';

class BeaufortController extends GetxController {

  @override
  void onReady() {
    super.onReady();
  }

  static var beaufortSelectList = <DynInputSelectItem>[
    DynInputSelectItem(value: "", label: "none select"),
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
  ].obs;
}