import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:neo_trickbd/components/comment_view.dart';
import 'package:neo_trickbd/models/post_model.dart';
import 'package:neo_trickbd/views/posts_by_author_view.dart';
import 'package:skeletons/skeletons.dart';

import '../api/dio.dart';
import '../api/get_post.dart';
import '../main.dart';

class PostView extends StatefulWidget {
  final PostItemModel postItemModel;

  const PostView({super.key, required this.postItemModel});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  late PostModel postModel;
  String? statusMessage;

  @override
  void initState() {
    super.initState();
    postModel = PostModel(postItemModel: widget.postItemModel);
    getPost(postItemModel: widget.postItemModel).then((value) {
      statusMessage = null;
      setState(() => postModel = value);
    }).onError((error, stackTrace) {
      setState(() => statusMessage = error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(postModel.title),
        actions: [
          IconButton(
            onPressed: () => launchUrlInBrowser(postModel.url),
            icon: const Icon(Icons.open_in_browser_rounded),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => Row(
          children: [
            Flexible(
              flex: 7,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: postModel.url,
                        child: CachedNetworkImage(
                          imageUrl: postModel.thumbnailUrl,
                          width: double.infinity,
                          fit: BoxFit.fill,
                          height: 148,
                        ),
                      ),
                      if (postModel.creationTime != null)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Chip(
                            label: Text(
                              postModel.creationTime!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      Positioned.fill(
                        bottom: 8,
                        left: 8,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.thumb_up_rounded),
                              label: Text("${postModel.likeCount ?? "..."}"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (constraints.maxWidth < widthBreakpoint) {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (context) => _commentSection(),
                                  );
                                }
                              },
                              icon: const Icon(Icons.comment_rounded),
                              label: Text("${postModel.commentCount ?? "..."}"),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(0)),
                              child: const Icon(Icons.share_rounded),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  //Post Content
                  Skeleton(
                    isLoading: postModel.body == null,
                    skeleton: SkeletonParagraph(
                      style: const SkeletonParagraphStyle(lines: 10),
                    ),
                    child: Html(
                      data: postModel.body ?? "",
                      shrinkWrap: true,
                      onLinkTap: (url, context, attributes) async {
                        launchUrlInBrowser(url);
                        //TODO: Handle images/links in a menu
                      },
                    ),
                  ),

                  //Mobile screen
                  if (constraints.maxWidth < widthBreakpoint) ...{
                    Divider(
                      color: isDarkTheme(context)
                          ? Colors.white10
                          : Colors.black12,
                      height: 8,
                      endIndent: 4,
                      indent: 4,
                    ),
                    _authorInfo(),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        child: Skeleton(
                          isLoading: (postModel.commentCount != 0 &&
                              postModel.comments == null),
                          skeleton: const SkeletonLine(
                            style: SkeletonLineStyle(
                              padding: EdgeInsets.all(12),
                              randomLength: true,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, right: 4, top: 8, bottom: 8),
                                  child: Text(
                                    "Comments (${postModel.commentCount})",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_right_rounded)
                            ],
                          ),
                        ),
                        onTap: () => showModalBottomSheet(
                          isScrollControlled: true,
                          showDragHandle: true,
                          useSafeArea: true,
                          context: context,
                          builder: (context) => _commentSection(),
                        ),
                      ),
                    ),
                    // _commentSection()
                  }
                ],
              ),
            ),

            //Split screen
            if (constraints.maxWidth > widthBreakpoint)
              Flexible(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _authorInfo(),
                    Divider(
                      color: isDarkTheme(context)
                          ? Colors.white10
                          : Colors.black12,
                      height: 8,
                      endIndent: 4,
                      indent: 4,
                    ),
                    Expanded(child: _commentSection()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _commentSection() {
    return Skeleton(
      isLoading: (postModel.commentCount != 0 && postModel.comments == null),
      skeleton: ListView(
        children: [
          const SkeletonLine(
            style: SkeletonLineStyle(
              padding: EdgeInsets.all(12),
              randomLength: true,
            ),
          ),
          ...List.filled(
            postModel.commentCount?.clamp(0, 12) ?? 8,
            SkeletonListTile(
              hasSubtitle: true,
              leadingStyle: const SkeletonAvatarStyle(
                height: 36,
                width: 36,
                shape: BoxShape.circle,
              ),
              subtitleStyle: const SkeletonLineStyle(randomLength: true),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
            child: Text(
              "Comments (${postModel.commentCount})",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: postModel.comments?.length ?? 0,
              shrinkWrap: true,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: CommentView(
                  comment: postModel.comments![index],
                  onAuthorClick:
                      (postModel.comments![index].author.authorPageUrl.isEmpty)
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostsByAuthorView(
                                    author: postModel.comments![index].author,
                                  ),
                                ),
                              ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _authorInfo() {
    return Skeleton(
      isLoading: postModel.author?.authorName == null,
      skeleton: SkeletonListTile(
        padding: const EdgeInsets.all(8),
        hasSubtitle: true,
        leadingStyle: const SkeletonAvatarStyle(height: 78, width: 78),
        titleStyle: const SkeletonLineStyle(randomLength: true),
        subtitleStyle: const SkeletonLineStyle(randomLength: true),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: (postModel.author == null ||
                  postModel.author!.authorPageUrl.isEmpty)
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PostsByAuthorView(author: postModel.author!),
                    ),
                  ),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: postModel.author?.authorAvatar ?? "",
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SkeletonAvatar(
                      style: SkeletonAvatarStyle(height: 78, width: 78),
                    ),
                    height: 78,
                    width: 78,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${postModel.author?.authorName}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text("${postModel.author?.authorRole.toString()}")
                  ],
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
