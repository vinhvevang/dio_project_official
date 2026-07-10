import 'package:dio_complete/data/repositories/auth_repository_impl.dart';
import 'package:dio_complete/data/repositories/cart_repository_impl.dart';
import 'package:dio_complete/data/repositories/category_repository_impl.dart';
import 'package:dio_complete/data/repositories/product_repository_impl.dart';
import 'package:dio_complete/domain/repositories/auth_repository.dart';
import 'package:dio_complete/domain/repositories/cart_repository.dart';
import 'package:dio_complete/domain/repositories/category_repository.dart';
import 'package:dio_complete/domain/repositories/product_repository.dart';
import 'package:dio_complete/domain/usecases/auth_usecase.dart';
import 'package:dio_complete/domain/usecases/cart_usecase.dart';
import 'package:dio_complete/domain/usecases/category_usecase.dart';
import 'package:dio_complete/domain/usecases/product_usecase.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(), fenix: true);
    Get.lazyPut<ProductRepository>(() => ProductRepositoryImpl(), fenix: true);
    Get.lazyPut<CategoryRepository>(() => CategoryRepositoryImpl(), fenix: true);
    Get.lazyPut<CartRepository>(() => CartRepositoryImpl(), fenix: true);

    Get.lazyPut(() => AuthUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => ProductUseCase(Get.find<ProductRepository>()), fenix: true);
    Get.lazyPut(() => CategoryUseCase(Get.find<CategoryRepository>()), fenix: true);
    Get.lazyPut(() => CartUseCase(Get.find<CartRepository>()), fenix: true);
  }
}