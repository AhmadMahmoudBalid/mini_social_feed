import 'package:mini_social_feed/features/auth/data/models/user_model.dart';
import 'package:path/path.dart' as path;

class PostModel {
  final int id;
  final String title;
  final String content;
  final UserModel user;
  final List<Media> media;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.user,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      user: UserModel.fromJson(json['user']),
      media: json['media'] != null
          ? List<Media>.from(json['media'].map((x) => Media.fromJson(x)))
          : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user': user.toJson(),
      'media': List<dynamic>.from(media.map((x) => x.toJson())),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Media {
  final int id;
  final String mediaType;
  final String url;
  final String filePath;

  Media({
    required this.id,
    required this.mediaType,
    required this.url,
    required this.filePath,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      mediaType: json['media_type'],
      url: json['url'],
      filePath: json['file_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media_type': mediaType,
      'url': url,
      'file_path': filePath,
    };
  }

  String get extension => path.extension(filePath).toLowerCase();
}

class PostsResponse {
  final bool status;
  final String message;
  final PostsData data;

  PostsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    return PostsResponse(
      status: json['status'],
      message: json['message'],
      data: PostsData.fromJson(json['data']),
    );
  }
}

class PostsData {
  final List<PostModel> posts;
  final Pagination pagination;

  PostsData({required this.posts, required this.pagination});

  factory PostsData.fromJson(Map<String, dynamic> json) {
    return PostsData(
      posts: List<PostModel>.from(
        json['posts'].map((x) => PostModel.fromJson(x)),
      ),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      perPage: json['per_page'],
      total: json['total'],
      lastPage: json['last_page'],
    );
  }
}

class CreatePostRequest {
  final String title;
  final String content;
  final List<String> mediaPaths;

  CreatePostRequest({
    required this.title,
    required this.content,
    required this.mediaPaths,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content};
  }
}

class UpdatePostRequest {
  final String title;
  final String content;
  final List<String> mediaPaths;
  final List<int> removeMediaIds;

  UpdatePostRequest({
    required this.title,
    required this.content,
    required this.mediaPaths,
    required this.removeMediaIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'remove_media_ids': removeMediaIds,
    };
  }
}
