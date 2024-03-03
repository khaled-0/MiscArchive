import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neo_trickbd/api/get_categories.dart';
import 'package:neo_trickbd/api/get_posts.dart';
import 'package:neo_trickbd/models/category_model.dart';
import 'package:neo_trickbd/models/post_model.dart';
import 'package:neo_trickbd/views/browse_by_category_view.dart';
import 'package:skeletons/skeletons.dart';

import '../main.dart';
import '../views/post_view.dart';

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab>
    with AutomaticKeepAliveClientMixin<BrowseTab> {
  List<CategoryModel> categories = List.empty(growable: true);
  List<PostItemModel> hotPosts = List.empty(growable: true);

  Widget? nestedCategoryBrowserView;

  Future<void> _loadBrowseData() async {
    setState(() {
      hotPosts.clear();
      categories.clear();
    });

    var responses = await Future.wait([getCategories(), getHotPosts()]);
    for (var response in responses) {
      if (response is List<CategoryModel>) {
        categories.addAll(response);
      }
      if (response is List<PostItemModel>) {
        hotPosts.addAll(response);
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadBrowseData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (nestedCategoryBrowserView != null) {
      return WillPopScope(
        onWillPop: () async {
          setState(() => nestedCategoryBrowserView = null);
          return true;
        },
        child: nestedCategoryBrowserView!,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBrowseData,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hotPostsGrid(),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12, bottom: 8),
                  child: Text("Categories",
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                if (categories.isEmpty)
                  SkeletonParagraph(
                    style: const SkeletonParagraphStyle(
                      lines: 8,
                      lineStyle: SkeletonLineStyle(
                        randomLength: true,
                        height: 32,
                      ),
                    ),
                  ),
              ],
            );
          }

          return _categoryView(categories[index - 1]);
        },
      ),
    );
  }

  Widget _hotPostsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 12, bottom: 8),
          child: Text(
            "Hot Posts",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 180,
          child: Skeleton(
            isLoading: hotPosts.isEmpty,
            skeleton: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 180,
                    width: 280,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 8, right: 8),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: hotPosts.length,
              itemBuilder: (context, index) {
                PostItemModel postItemModel = hotPosts[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostView(postItemModel: postItemModel),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 280,
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: postItemModel.thumbnailUrl,
                              fit: BoxFit.cover,
                              width: 280,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Chip(
                                        avatar: const Icon(
                                            Icons.access_time_rounded),
                                        label: Text(
                                          postItemModel.creationTime ?? "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Chip(
                                        avatar:
                                            const Icon(Icons.comment_outlined),
                                        label: Text(
                                          "${postItemModel.commentCount}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: isDarkTheme(context)
                                                ? Colors.black38
                                                : Colors.white70),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        postItemModel.title,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryView(CategoryModel category) {
    return InkWell(
      onTap: () {
        if (getScreenWidth(context) > widthBreakpoint) {
          return setState(() =>
              nestedCategoryBrowserView = BrowseByCategoryView(category: category));
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrowseByCategoryView(category: category),
          ),
        );
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 12),
        child: Row(
          children: [
            const Icon(Icons.category),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name),
                  if (category.categoryDescription != null)
                    Text(
                      category.categoryDescription!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
