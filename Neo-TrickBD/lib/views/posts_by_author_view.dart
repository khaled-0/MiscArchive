import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neo_trickbd/api/get_author_data.dart';
import 'package:neo_trickbd/components/post_item_view.dart';
import 'package:neo_trickbd/views/post_view.dart';
import 'package:skeletons/skeletons.dart';

import '../api/get_posts.dart';
import '../main.dart';
import '../models/author_model.dart';
import '../models/post_model.dart';

class PostsByAuthorView extends StatefulWidget {
  final AuthorModel author;

  const PostsByAuthorView({super.key, required this.author});

  @override
  State<PostsByAuthorView> createState() => _PostsByAuthorViewState();
}

class _PostsByAuthorViewState extends State<PostsByAuthorView> {
  AuthorModel? author;
  final List<PostItemModel> posts = List.empty(growable: true);
  int page = 0;
  String? statusMessage;

  void fetchAuthorPage() {
    getAuthorData(authorPageUrl: widget.author.authorPageUrl).then((value) {
      setState(() => author = value);
    });
  }

  void fetchMorePosts() async {
    page++;
    setState(() => statusMessage = null);
    final url = (await getAuthorRedirectUrl(widget.author.authorPageUrl))
        .replaceFirst("https://trickbd.com", "");
    getRecentPosts(prefix: url, page: page).then((value) {
      for (var element in value) {
        if (!posts.contains(element)) posts.add(element);
      }

      setState(() => statusMessage = null);
    }).onError((error, stackTrace) {
      page--;
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => statusMessage = error.toString());
      });
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.extentAfter < 1500) {
        if (statusMessage == null) fetchMorePosts();
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    fetchMorePosts();
    fetchAuthorPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts by ${widget.author.authorName}"),
        scrolledUnderElevation: 0,
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: RefreshIndicator(
          onRefresh: () async => setState(() {
            page = 0;
            posts.clear();
            author = null;
            fetchMorePosts();
            fetchAuthorPage();
          }),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: posts.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _authorDetails();
              }

              if (index - 1 == posts.length) {
                if (statusMessage == null) {
                  //Skeleton Loader
                  return Column(
                    children: List.filled(
                      posts.isEmpty ? 8 : 2,
                      SkeletonListTile(
                        hasSubtitle: true,
                        leadingStyle:
                            const SkeletonAvatarStyle(height: 96, width: 96),
                        subtitleStyle:
                            const SkeletonLineStyle(randomLength: true),
                        padding: const EdgeInsets.all(2),
                      ),
                    ),
                  );
                }

                //TODO Prettify this error box
                return Row(
                  children: [
                    Expanded(child: Text(statusMessage ?? "Null")),
                    TextButton(
                        onPressed: fetchMorePosts, child: const Text("RETRY"))
                  ],
                );
              }

              PostItemModel post = posts[index - 1];
              return Padding(
                padding: const EdgeInsets.only(top: 1.75, bottom: 1.75),
                child: PostItemView(
                  post: post,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostView(postItemModel: post),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _authorDetails() {
    if (author == null) {
      return Column(
        children: [
          SkeletonListTile(
            leadingStyle: const SkeletonAvatarStyle(height: 128, width: 128),
            hasSubtitle: true,
          ),
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: SkeletonLine(style: SkeletonLineStyle()),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: author?.authorAvatar ?? "",
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SkeletonAvatar(
                    style: SkeletonAvatarStyle(height: 128, width: 128),
                  ),
                  height: 128,
                  width: 128,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${author?.authorName}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text("${author?.authorRole}"),
                    Text("${author?.authorPostCount} Posts",
                        style: Theme.of(context).textTheme.bodySmall),
                    Text("${author?.authorPoints} Points",
                        style: Theme.of(context).textTheme.bodySmall)
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("${author?.authorDescription}"),
          ),
          if ((author?.authorWebsite ?? "").isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Chip(
                label: Text("${author?.authorWebsite}"),
                avatar: const Icon(Icons.language_rounded),
              ),
            ),
          Divider(
            color: isDarkTheme(context) ? Colors.white10 : Colors.black12,
            height: 8,
          ),
        ],
      ),
    );
  }
}
