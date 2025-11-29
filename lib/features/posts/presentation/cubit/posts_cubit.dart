import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/models/post_model.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final PostRepository _postRepository;
  int _currentPage = 1;
  bool _hasMore = true;
  final List<PostModel> _posts = [];
  PostsCubit({required PostRepository postRepository})
    : _postRepository = postRepository,
      super(PostsInitial());

  // دالة واحدة فقط للتحميل (سواء أول مرة أو load more)
  Future<void> getPosts({bool loadMore = false}) async {
    // منع الطلبات المتزامنة
    if (state is PostsLoading || (loadMore && !_hasMore)) return;

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _posts.clear();
      emit(PostsLoading());
    } else {
      emit(PostsLoadMoreLoading(posts: List.from(_posts)));
    }

    final result = await _postRepository.getPosts(
      page: _currentPage,
      perPage: 10,
    );

    result.fold(
      (failure) {
        if (loadMore) {
          // emit(
          //   PostsLoadMoreError(
          //     message: failure.message,
          //     posts: List.from(_posts),
          //   ),
          // );
        } else {
          emit(PostsError(message: failure.message));
        }
      },
      (postsResponse) {
        final newPosts = postsResponse.data.posts;

        // إزالة التكرارات تلقائيًا (حسب الـ id)
        final seenIds = _posts.map((p) => p.id).toSet();
        final uniqueNewPosts = newPosts
            .where((p) => !seenIds.contains(p.id))
            .toList();

        _posts.addAll(uniqueNewPosts);
        _currentPage++;
        _hasMore = _currentPage <= postsResponse.data.pagination.lastPage;

        emit(
          PostsLoaded(
            posts: List.from(_posts), // نسخة آمنة
            hasMore: _hasMore,
          ),
        );
      },
    );
  }

  void retry() => getPosts();

  Future<void> refresh() => getPosts();

  @override
  void onChange(Change<PostsState> change) {
    super.onChange(change);
  }

  Future<void> createPost({
    required String title,
    required String content,
    required List<String> mediaPaths,
  }) async {
    emit(PostsActionLoading());

    final result = await _postRepository.createPost(
      CreatePostRequest(title: title, content: content, mediaPaths: mediaPaths),
    );

    result.fold(
      (failure) {
        emit(PostsActionError(message: failure.message));
        // إعادة تحميل المنشورات بعد الخطأ
        getPosts();
      },
      (newPost) {
        emit(PostsActionSuccess(message: 'Post created successfully'));
        // إعادة تحميل المنشورات بعد النجاح
        getPosts();
      },
    );
  }

  Future<void> updatePost({
    required int id,
    required String title,
    required String content,
    required List<String> mediaPaths,
    required List<int> removeMediaIds,
  }) async {
    emit(PostsActionLoading());

    final result = await _postRepository.updatePost(
      id,
      UpdatePostRequest(
        title: title,
        content: content,
        mediaPaths: mediaPaths,
        removeMediaIds: removeMediaIds,
      ),
    );

    result.fold(
      (failure) {
        emit(PostsActionError(message: failure.message));
        getPosts();
      },
      (updatedPost) {
        emit(PostsActionSuccess(message: 'Post updated successfully'));
        getPosts();
      },
    );
  }

  Future<void> deletePost(int id) async {
    emit(PostsActionLoading());

    final result = await _postRepository.deletePost(id);

    result.fold(
      (failure) {
        emit(PostsActionError(message: failure.message));
        getPosts();
      },
      (_) {
        emit(PostsActionSuccess(message: 'Post deleted successfully'));
        getPosts();
      },
    );
  }
}
