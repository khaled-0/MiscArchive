import 'package:html/dom.dart';
import 'package:neo_trickbd/models/author_model.dart';

class CommentModel {
  AuthorModel author;

  String commentBody;
  String commentDate;

  List<CommentModel>? replies;

  CommentModel({
    required this.author,
    required this.commentBody,
    required this.commentDate,
    this.replies,
  });

  factory CommentModel.parseComment(Element node) {
    var authorName =
        node.querySelector(".comment-author > .fn > .url")?.text.trim() ?? "";
    var authorProfileLink =
        node.querySelector(".comment-author > .fn > .url")?.attributes["href"];
    var authorAvatarUrl =
        node.querySelector(".comment-author > .avatar")?.attributes["src"] ??
            "";

    var authorRole = node
            .querySelector(".comment-author > .fn > .user-badge")
            ?.text
            .trim() ??
        "";
    var commentBody = node.querySelector("p")?.text.trim() ?? "";
    var commentDate =
        node.querySelector(".comment-meta > a")?.text.trim() ?? "Unknown Date";
    AuthorModel author = AuthorModel(
      authorPageUrl: authorProfileLink ?? "",
      authorName: authorName,
      authorAvatar: authorAvatarUrl,
      authorRole: authorRole,
    );

    return CommentModel(
      author: author,
      commentBody: commentBody,
      commentDate: commentDate,
    );
  }
}
