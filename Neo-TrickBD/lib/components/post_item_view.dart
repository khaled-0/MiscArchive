import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neo_trickbd/models/post_model.dart';
import 'package:skeletons/skeletons.dart';

class PostItemView extends StatelessWidget {
  const PostItemView({super.key, required this.post, this.onTap});

  final PostItemModel post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Hero(
            tag: post.url,
            child: CachedNetworkImage(
              imageUrl: post.thumbnailUrl,
              placeholder: (context, url) => const SkeletonAvatar(
                style: SkeletonAvatarStyle(height: 96, width: 96),
              ),
              height: 96,
              width: 96,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title),
                Text(
                  post.creationTime ?? "Unknown",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.color
                          ?.withAlpha(200)),
                ),
                Text(
                  "${post.commentCount} Comment",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.color
                            ?.withAlpha(200),
                      ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
