import 'package:neo_trickbd/models/author_model.dart';

import 'comment_model.dart';

class PostItemModel {
  String thumbnailUrl;
  String title;
  String url;
  String? creationTime;
  int? commentCount;

  PostItemModel({
    required this.thumbnailUrl,
    required this.title,
    required this.url,
    this.creationTime,
    this.commentCount,
  });

  @override
  bool operator ==(Object other) {
    return (other is PostItemModel && other.url == url);
  }

  @override
  int get hashCode => url.hashCode;
}

class PostModel extends PostItemModel {
  String? body;

  int? likeCount;
  AuthorModel? author;

  List<CommentModel>? comments;

  PostModel({
    required PostItemModel postItemModel,
    this.body,
    this.author,
    this.likeCount,
    this.comments,
  }) : super(
          title: postItemModel.title,
          url: postItemModel.url,
          thumbnailUrl: postItemModel.thumbnailUrl,
          creationTime: postItemModel.creationTime,
          commentCount: postItemModel.commentCount,
        );
}
