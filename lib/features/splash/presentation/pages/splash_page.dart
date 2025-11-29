import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_social_feed/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:mini_social_feed/features/splash/presentation/cubit/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SplashCubit(const FlutterSecureStorage())..checkToken(),
      child: BlocConsumer<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashGoToLogin) {
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state is SplashGoToHome) {
            Navigator.pushReplacementNamed(context, '/postes');
          }
        },
        builder: (context, state) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
