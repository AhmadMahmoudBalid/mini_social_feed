part of 'posts_cubit.dart';

abstract class PostsState {
  const PostsState();
}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoadMoreLoading extends PostsState {
  final List<PostModel> posts;

  const PostsLoadMoreLoading({required this.posts});
}

class PostsLoaded extends PostsState {
  final List<PostModel> posts;
  final bool hasMore;

  const PostsLoaded({required this.posts, required this.hasMore});
}

class PostsError extends PostsState {
  final String message;
  final List<PostModel>? posts;

  const PostsError({required this.message, this.posts});
}

class PostsActionLoading extends PostsState {}

class PostsActionSuccess extends PostsState {
  final String message;

  const PostsActionSuccess({required this.message});
}

class PostsActionError extends PostsState {
  final String message;

  const PostsActionError({required this.message});
}
