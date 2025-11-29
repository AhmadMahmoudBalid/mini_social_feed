import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/register_response_model.dart';
import '../../../../core/error/failures.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _secureStorage;

  AuthCubit({
    required AuthRepository authRepository,
    required FlutterSecureStorage secureStorage,
  }) : _authRepository = authRepository,
       _secureStorage = secureStorage,
       super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        if (failure is CredentialsFailure) {
          emit(AuthError('Invalid email or password'));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (authResponse) async {
        // حفظ tokens في Secure Storage
        if (authResponse.data != null) {
          await _saveTokens(authResponse.data!.tokens);
        }
        emit(AuthSuccess(authResponse));
      },
    );
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());

    final result = await _authRepository.register(
      name: name,
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(AuthError(failure.message));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (registerResponse) async {
        // حفظ tokens في Secure Storage
        if (registerResponse.data != null) {
          await _saveTokens(registerResponse.data!.tokens);
        }
        emit(RegisterSuccess(registerResponse));
      },
    );
  }

  Future<void> _saveTokens(Tokens tokens) async {
    await _secureStorage.write(key: 'access_token', value: tokens.accessToken);
    await _secureStorage.write(
      key: 'refresh_token',
      value: tokens.refreshToken,
    );
  }

  void reset() {
    emit(AuthInitial());
  }
}
