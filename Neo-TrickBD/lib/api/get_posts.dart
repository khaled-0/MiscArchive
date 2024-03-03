import 'package:html/parser.dart';

import '../models/post_model.dart';
import 'dio.dart';

Future<List<PostItemModel>> getRecentPosts(
    {String? prefix, required int page}) async {
  //Parse the prefix
  if (prefix != null && !prefix.startsWith("/")) {
    prefix = "/$prefix";
    if (prefix.endsWith("/")) prefix = prefix.substring(0, prefix.length - 1);
  }

  final response = parse((await dio.get("${prefix ?? ""}/page/$page")).data);

  var recentPostsUl =
      (response.body?.querySelectorAll(".rpul").last)?.querySelectorAll("li");

  List<PostItemModel> recentPosts = List.empty(growable: true);

  recentPostsUl?.forEach((element) {
    var url = element.querySelector("a")?.attributes["href"]?.trim();
    var title = element.querySelector("a")?.text.trim();
    var thumbnailUrl = element.querySelector("img")?.attributes["src"]?.trim();
    var creationTime = element.querySelector("p")?.firstChild?.text?.trim();

    var commentCount = element.querySelector("p > a")?.text.trim();
    commentCount = commentCount?.replaceAll(RegExp(r'[^0-9]'), '');

    recentPosts.add(PostItemModel(
      url: url ?? "",
      title: title ?? "",
      thumbnailUrl: thumbnailUrl ?? "",
      creationTime: creationTime,
      commentCount: int.tryParse(commentCount ?? "") ?? 0,
    ));
  });

  return recentPosts;
}

Future<List<PostItemModel>> getHotPosts() async {
  final response = parse((await dio.get("")).data);

  var hotPostsUl =
      (response.body?.querySelectorAll(".rpul")[1])?.querySelectorAll("li");

  List<PostItemModel> hotPosts = List.empty(growable: true);

  hotPostsUl?.forEach((element) {
    var url = element.querySelector("a")?.attributes["href"]?.trim();
    var title = element.querySelector("a")?.text.trim();
    var thumbnailUrl = element.querySelector("img")?.attributes["src"]?.trim();
    var creationTime = element.querySelector("p")?.firstChild?.text?.trim();

    var commentCount = element.querySelector("p > a")?.text.trim();
    commentCount = commentCount?.replaceAll(RegExp(r'[^0-9]'), '');

    hotPosts.add(PostItemModel(
      url: url ?? "",
      title: title ?? "",
      thumbnailUrl: thumbnailUrl ?? "",
      creationTime: creationTime,
      commentCount: int.tryParse(commentCount ?? "") ?? 0,
    ));
  });

  return hotPosts;
}
