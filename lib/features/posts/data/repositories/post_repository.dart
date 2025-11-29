import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:mini_social_feed/core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../models/post_model.dart';

class PostRepository {
  final Dio _dio = GetIt.I<ApiClient>().dio;

  Future<Either<Failure, PostsResponse>> getPosts({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        final postsResponse = PostsResponse.fromJson(response.data);
        return Right(postsResponse);
      } else {
        return Left(ServerFailure('Failed to load posts'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  Future<Either<Failure, PostModel>> getPostById(int id) async {
    try {
      final response = await _dio.get('/posts/$id');

      if (response.statusCode == 200) {
        final post = PostModel.fromJson(response.data['data']);
        return Right(post);
      } else {
        return Left(ServerFailure('Failed to load post'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  Future<Either<Failure, PostModel>> createPost(
    CreatePostRequest request,
  ) async {
    try {
      final formData = FormData.fromMap({
        'title': request.title,
        'content': request.content,
      });

      // إضافة الملفات إذا وجدت
      for (int i = 0; i < request.mediaPaths.length; i++) {
        formData.files.add(
          MapEntry(
            'media[]',
            await MultipartFile.fromFile(request.mediaPaths[i]),
          ),
        );
      }

      final response = await _dio.post('/posts', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final post = PostModel.fromJson(response.data['data']);
        return Right(post);
      } else {
        return Left(ServerFailure('Failed to create post'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  Future<Either<Failure, PostModel>> updatePost(
    int id,
    UpdatePostRequest request,
  ) async {
    try {
      final formData = FormData.fromMap({
        'title': request.title,
        'content': request.content,
        'remove_media_ids[]': request.removeMediaIds,
      });

      // إضافة الملفات الجديدة إذا وجدت
      for (int i = 0; i < request.mediaPaths.length; i++) {
        formData.files.add(
          MapEntry(
            'media[]',
            await MultipartFile.fromFile(request.mediaPaths[i]),
          ),
        );
      }

      final response = await _dio.put('/posts/$id', data: formData);

      if (response.statusCode == 200) {
        final post = PostModel.fromJson(response.data['data']);
        return Right(post);
      } else {
        return Left(ServerFailure('Failed to update post'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  Future<Either<Failure, void>> deletePost(int id) async {
    try {
      final response = await _dio.delete('/posts/$id');

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure('Failed to delete post'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  // الدالة المحسنة لجلب منشورات مستخدم معين
  Future<Either<Failure, PostsResponse>> getUserPosts({
    int page = 1,
    int perPage = 200,
    required int userId,
  }) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        final postsResponse = PostsResponse.fromJson(response.data);

        // تصفية المنشورات حسب user_id
        final userPosts = _filterPostsByUserId(
          postsResponse.data.posts,
          userId,
        );

        // تحديث الـ pagination للمنشورات المصفاة
        final updatedResponse = _updateResponseWithFilteredPosts(
          postsResponse,
          userPosts,
          page,
          perPage,
        );

        return Right(updatedResponse);
      } else {
        return Left(ServerFailure('Failed to load posts'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  // دالة مساعدة لتصفية المنشورات حسب user_id
  List<PostModel> _filterPostsByUserId(List<PostModel> posts, int userId) {
    return posts.where((post) => post.user.id == userId).toList();
  }

  // دالة مساعدة لتحديث الـ response بالمنشورات المصفاة
  PostsResponse _updateResponseWithFilteredPosts(
    PostsResponse originalResponse,
    List<PostModel> filteredPosts,
    int page,
    int perPage,
  ) {
    final filteredPagination = Pagination(
      currentPage: page,
      perPage: perPage,
      total: filteredPosts.length,
      lastPage: (filteredPosts.length / perPage).ceil().clamp(
        1,
        double.maxFinite.toInt(),
      ),
    );

    final filteredData = PostsData(
      posts: filteredPosts,
      pagination: filteredPagination,
    );

    return PostsResponse(
      status: originalResponse.status,
      message: originalResponse.message,
      data: filteredData,
    );
  }

  // دالة لجلب جميع منشورات المستخدم (بدون pagination)
  Future<Either<Failure, List<PostModel>>> getAllUserPosts(int userId) async {
    try {
      List<PostModel> allPosts = [];
      int currentPage = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await _dio.get(
          '/posts',
          queryParameters: {
            'page': currentPage,
            'per_page': 100, // جلب 100 منشور في كل صفحة
          },
        );

        if (response.statusCode == 200) {
          final postsResponse = PostsResponse.fromJson(response.data);
          final userPosts = _filterPostsByUserId(
            postsResponse.data.posts,
            userId,
          );
          allPosts.addAll(userPosts);

          hasMore = currentPage < postsResponse.data.pagination.lastPage;
          currentPage++;
        } else {
          return Left(
            ServerFailure('Failed to load posts on page $currentPage'),
          );
        }
      }

      return Right(allPosts);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  // ... باقي الدوال (getPosts, createPost, updatePost, deletePost, getPostById)
}
