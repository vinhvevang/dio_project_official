import 'package:dio_complete/features/login/data/datasources/auth_remote_datasource.dart';
import 'package:dio_complete/features/login/data/repositories/auth_repository_impl.dart';
import 'package:dio_complete/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:dio_complete/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:dio_complete/features/category/data/datasources/category_remote_datasource.dart';
import 'package:dio_complete/features/category/data/repositories/category_repository_impl.dart';
import 'package:dio_complete/features/product/data/datasources/product_remote_datasource.dart';
import 'package:dio_complete/features/product/data/repositories/product_repository_impl.dart';
import 'package:dio_complete/features/login/domain/repositories/auth_repository.dart';
import 'package:dio_complete/features/cart/domain/repositories/cart_repository.dart';
import 'package:dio_complete/features/category/domain/repositories/category_repository.dart';
import 'package:dio_complete/features/product/domain/repositories/product_repository.dart';
import 'package:dio_complete/features/login/domain/usecases/auth_usecase.dart';
import 'package:dio_complete/features/cart/domain/usecases/cart_usecase.dart';
import 'package:dio_complete/features/category/domain/usecases/category_usecase.dart';
import 'package:dio_complete/features/product/domain/usecases/product_usecase.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // DataSource - tầng thấp nhất, đăng ký trước vì Repository cần tới.
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(), fenix: true);
    Get.lazyPut<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(), fenix: true);
    Get.lazyPut<CategoryRemoteDataSource>(() => CategoryRemoteDataSourceImpl(), fenix: true);
    Get.lazyPut<CartLocalDataSource>(() => CartLocalDataSourceImpl(), fenix: true);

    // Repository - nhận DataSource tương ứng qua constructor.
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(Get.find<ProductRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepositoryImpl(Get.find<CategoryRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<CartRepository>(
      () => CartRepositoryImpl(Get.find<CartLocalDataSource>()),
      fenix: true,
    );

    // UseCase - không đổi, vẫn chỉ biết tới Repository (domain), không biết
    // gì về DataSource.
    Get.lazyPut(() => AuthUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => ProductUseCase(Get.find<ProductRepository>()), fenix: true);
    Get.lazyPut(() => CategoryUseCase(Get.find<CategoryRepository>()), fenix: true);
    Get.lazyPut(() => CartUseCase(Get.find<CartRepository>()), fenix: true);
  }
}
