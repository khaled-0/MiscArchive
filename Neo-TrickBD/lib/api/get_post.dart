import 'package:html/parser.dart';
import 'package:neo_trickbd/models/author_model.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import 'dio.dart';

Future<PostModel> getPost({required PostItemModel postItemModel}) async {
  final response = parse((await dio.get(postItemModel.url)).data);
  var postParagraphDiv =
      response.body?.querySelector(".post_paragraph")?.innerHtml;

  var likeButton = response.body?.querySelector(".trickbd-like-count");
  var likeCount = likeButton?.querySelector("span")?.text;

  var authorAvatarUrl =
      response.body?.querySelector(".avatar")?.attributes["src"];
  var authorName = response.body?.querySelector(".author-link")?.text;
  var authorRole = response.body?.querySelector(".user_role")?.text.trim();
  var authorPageUrl =
      response.body?.querySelector(".author-link")?.attributes["href"];

  PostModel postModel = PostModel(postItemModel: postItemModel);
  postModel.body = postParagraphDiv;
  postModel.likeCount = int.tryParse(likeCount ?? "0");

  postModel.author = AuthorModel(
    authorPageUrl: authorPageUrl ?? "",
    authorName: authorName?.trim(),
    authorAvatar: authorAvatarUrl,
    authorRole:
        authorRole?.replaceFirst(authorRole[0], authorRole[0].toUpperCase()),
  );

  List<CommentModel> comments = List.empty(growable: true);

  var commentsListOl = response.body?.querySelector(".commentlist");
  // ignore: avoid_function_literals_in_foreach_calls
  commentsListOl?.children.forEach((element) {
    var comment = CommentModel.parseComment(element);

    List<CommentModel> replies = List.empty(growable: true);
    var repliesUl = element.querySelector(".children");
    // ignore: avoid_function_literals_in_foreach_calls
    repliesUl?.children.forEach((element) {
      replies.add(CommentModel.parseComment(element));
    });

    if (replies.isNotEmpty) comment.replies = replies;
    comments.add(comment);
  });

  if (comments.isNotEmpty) postModel.comments = comments;

  return postModel;
}
