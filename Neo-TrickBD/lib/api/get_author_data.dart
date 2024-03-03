import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:neo_trickbd/models/author_model.dart';

import 'dio.dart';

Future<AuthorModel> getAuthorData({required String authorPageUrl}) async {
  final dioResponse = await dio.get(authorPageUrl);
  final response = parse(dioResponse.data);

  var authorBlockDiv = response.body?.querySelector(".author_block");

  var authorName = authorBlockDiv?.querySelector("h3")?.text.trim();
  var authorAvatar =
      authorBlockDiv?.querySelector(".avatar")?.attributes["src"];
  var authorRole = authorBlockDiv?.querySelector(".user_role")?.text.trim();
  authorRole =
      authorRole?.replaceFirst(authorRole[0], authorRole[0].toUpperCase());

  var authorDescription = authorBlockDiv?.querySelector("p")?.text.trim();
  final AuthorModel authorModel = AuthorModel(
    authorName: authorName ?? "",
    authorAvatar: authorAvatar ?? "",
    authorRole: authorRole ?? "",
    authorPageUrl: authorPageUrl,
    authorDescription: authorDescription,
  );

  var authorInfoExtrasDiv = authorBlockDiv?.querySelector(".author_info");
  authorInfoExtrasDiv?.querySelectorAll("p").forEach((element) {
    if (element.text.startsWith("Registered")) {
      authorModel.registerDate = element.nodes.last.text;
    }
    if (element.text.startsWith("Website")) {
      if (element.text.replaceFirst("Website:", "").trim().isNotEmpty) {
        authorModel.authorWebsite = element.nodes.last.text;
      }
    }
    if (element.text.startsWith("Point")) {
      authorModel.authorPoints = element.nodes.last.text;
    }
    if (element.text.startsWith("Total")) {
      authorModel.authorPostCount = element.nodes.last.text;
    }
  });

  return authorModel;
}

Future<String> getAuthorRedirectUrl(String url) async {
  var request = await dio.get(url,
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status == 200 || status == 301,
      ));
  var response = request.headers;
  return response.value(HttpHeaders.locationHeader) ?? url;
}
