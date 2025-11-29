import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:mini_social_feed/core/network/api_client.dart';

import '../../../../core/error/failures.dart';
import '../models/auth_response_model.dart';
import '../models/register_response_model.dart';

class AuthRepository {
  final Dio _dio = GetIt.I<ApiClient>().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Either<Failure, AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(response.data);
        await _storage.write(
          key: "token",
          value: authResponse.data!.tokens.refreshToken,
        );
        await _storage.write(
          key: "userId",
          value: authResponse.data!.user.id.toString(),
        );
        return Right(authResponse);
      } else {
        return Left(ServerFailure(response.data['message'] ?? 'Login failed'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Left(CredentialsFailure('Invalid credentials'));
      }
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  Future<Either<Failure, RegisterResponseModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final registerResponse = RegisterResponseModel.fromJson(response.data);
        await _storage.write(
          key: "token",
          value: registerResponse.data!.tokens.refreshToken,
        );
        await _storage.write(
          key: "userId",
          value: registerResponse.data!.user.id.toString(),
        );

        return Right(registerResponse);
      } else {
        return Left(
          ServerFailure(response.data['message'] ?? 'Registration failed'),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Validation errors (like email already taken)
        final errors = e.response?.data['errors'];
        if (errors != null && errors['email'] != null) {
          return Left(ValidationFailure(errors['email'][0]));
        }
        return Left(ValidationFailure('Validation failed'));
      }
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }
}
