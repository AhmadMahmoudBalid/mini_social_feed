import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_social_feed/features/splash/presentation/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final FlutterSecureStorage storage;

  SplashCubit(this.storage) : super(SplashInitial());

  Future<void> checkToken() async {
    emit(SplashLoading());

    final token = await storage.read(key: "token");

    if (token == null) {
      emit(SplashGoToLogin());
      return;
    } else {
      emit(SplashGoToHome());
      return;
    }
  }
}
