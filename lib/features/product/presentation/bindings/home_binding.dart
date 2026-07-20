import 'package:get/get.dart';
import 'package:dio_complete/features/product/presentation/controllers/home_controller.dart';
import 'package:dio_complete/features/cart/presentation/controllers/cart_controller.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
