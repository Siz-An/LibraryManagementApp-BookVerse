import 'package:book_Verse/common/network_check/network_manager.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

class GeneralBinding extends Bindings{
  @override
  void dependencies(){
    Get.put(NetworkManager());

  }
}