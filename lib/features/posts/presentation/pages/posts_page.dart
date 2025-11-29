import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_social_feed/features/posts/data/models/post_model.dart';
import 'package:mini_social_feed/features/posts/presentation/widgets/new_card.dart';
import '../cubit/posts_cubit.dart';
import '../widgets/post_card.dart';
import 'create_post_page.dart';
import '../../data/repositories/post_repository.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();
  String? userName;
  String? userId;
  late PostsCubit _postsCubit;

  // متغير لمنع الطلبات المكررة
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _postsCubit = PostsCubit(postRepository: PostRepository())..getPosts();
    _loadUserData();
    _scrollController.addListener(_onScroll);
    _loadUserId();
  }

  Future<void> _loadUserData() async {
    final name = await _secureStorage.read(key: 'user_name');
    setState(() {
      userName = name;
    });
  }

  Future<void> _loadUserId() async {
    final id = await _secureStorage.read(key: 'userId');
    setState(() {
      userId = id;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;

    _isLoadingMore = true;
    await _postsCubit.getPosts(loadMore: true);
    _isLoadingMore = false;
  }

  Future<void> _refreshPosts() async {
    await _postsCubit.getPosts();
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(postsCubit: _postsCubit),
      ),
    );
  }

  void _navigateToProfilePage() {
    Navigator.pushNamed(
      context,
      '/profile', // اسم الroute المحدد في main
    );
  }

  void _navigateToEditPost(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreatePostPage(post: post, postsCubit: _postsCubit),
      ),
    );
  }

  void _showDeleteConfirmation(PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _postsCubit.deletePost(post.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _postsCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Posts Feed'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_rounded),
              onPressed: _navigateToProfilePage,
              tooltip: 'Create Post',
            ),
          ],
        ),
        body: BlocConsumer<PostsCubit, PostsState>(
          listener: (context, state) {
            if (state is PostsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is PostsLoading)
              return const Center(child: CircularProgressIndicator());
            if (state is PostsError) return Center(child: Text(state.message));

            final posts = state is PostsLoaded ? state.posts : <PostModel>[];
            final hasMore = state is PostsLoaded ? state.hasMore : false;

            return ListView.builder(
              itemCount: posts.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  context.read<PostsCubit>().getPosts(loadMore: true);
                  return const Center(child: CircularProgressIndicator());
                }
                bool isSowdelet = false;
                try {
                  if (posts[index].user.id.toString() == userId) {
                    isSowdelet = true;
                  }
                } catch (e) {}
                return PostNewCard(
                  post: posts[index],
                  isSowdelet: isSowdelet,
                  onDeletePressed: () async {
                    // عرض نافذة تأكيد الحذف
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('تأكيد الحذف'),
                          content: const Text(
                            'هل أنت متأكد أنك تريد حذف هذا المنشور نهائيًا؟',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false), // لا
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true), // نعم
                              child: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    // إذا ضغط "حذف" → نفّذ عملية الحذف
                    if (confirm == true) {
                      _postsCubit.deletePost(posts[index].id);

                      // اختياري: رسالة نجح الحذف (لو الـ Cubit ما بيعمل emit للـ Success)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حذف المنشور بنجاح'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToCreatePost,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postsCubit.close();
    _scrollController.dispose();
    super.dispose();
  }
}
