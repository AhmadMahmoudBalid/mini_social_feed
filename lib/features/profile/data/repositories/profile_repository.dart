import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:mini_social_feed/core/network/api_client.dart';

import '../../../../core/error/failures.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final Dio _dio = GetIt.I<ApiClient>().dio;

  Future<Either<Failure, ProfileResponse>> getProfile() async {
    try {
      final response = await _dio.get('/me');

      if (response.statusCode == 200) {
        final profileResponse = ProfileResponse.fromJson(response.data);
        return Right(profileResponse);
      } else {
        return Left(ServerFailure('Failed to load profile'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }
}
