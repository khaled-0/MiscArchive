import 'package:html/parser.dart';
import 'package:neo_trickbd/models/category_model.dart';

import 'dio.dart';

Future<List<CategoryModel>> getCategories() async {
  final response = parse((await dio.get("")).data);

  var categoriesUl =
      response.body?.querySelectorAll(".block_category > ul > li");

  List<CategoryModel> categories = List.empty(growable: true);

  categoriesUl?.forEach((element) {
    var categoryUrlFull =
        element.querySelector("a")?.attributes["href"]?.trim();
    var name = element.querySelector("a")?.text.trim() ?? "???";
    var categoryDescription =
        element.querySelector("a")?.attributes["title"]?.trim();
    var postsInCategoryCount =
        int.tryParse(element.children.last.text.trim()) ?? 0;

    var commentCount = element.querySelector("p > a")?.text.trim();
    commentCount = commentCount?.replaceAll(RegExp(r'[^0-9]'), '');
    if (categoryUrlFull != null) {
      categories.add(CategoryModel(
        name: name,
        categoryUrlFull: categoryUrlFull,
        postsInCategoryCount: postsInCategoryCount,
        categoryDescription: categoryDescription,
      ));
    }
  });

  return categories;
}
