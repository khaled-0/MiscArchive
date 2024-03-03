class CategoryModel {
  String name;
  String categoryUrlFull;
  late String categoryUrlPrefix;

  int postsInCategoryCount;
  String? categoryDescription;

  CategoryModel({
    required this.name,
    required this.categoryUrlFull,
    required this.postsInCategoryCount,
    this.categoryDescription,
  }) {
    categoryUrlPrefix = categoryUrlFull.replaceFirst("https://trickbd.com", "");
  }
}
