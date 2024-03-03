import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neo_trickbd/models/comment_model.dart';
import 'package:skeletons/skeletons.dart';

import '../views/posts_by_author_view.dart';

class CommentView extends StatelessWidget {
  final VoidCallback? onAuthorClick;

  const CommentView({super.key, required this.comment, this.onAuthorClick});

  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: InkWell(
                  onTap: onAuthorClick,
                  borderRadius: BorderRadius.circular(36),
                  child: CachedNetworkImage(
                    imageUrl: comment.author.authorAvatar ?? "",
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SkeletonAvatar(
                      style: SkeletonAvatarStyle(height: 36, width: 36),
                    ),
                    height: 36,
                    width: 36,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: onAuthorClick,
                          child: Text(
                            comment.author.authorName.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(comment.author.authorRole.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor)),
                      ],
                    ),
                    Text(comment.commentDate.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor)),
                    Text(comment.commentBody.toString(),
                        style: Theme.of(context).textTheme.bodyMedium)
                  ],
                ),
              ),
            ],
          ),
        ),
        if (comment.replies != null)
          ...?comment.replies
              ?.map((reply) => Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: CommentView(
                      comment: reply,
                      onAuthorClick: reply.author.authorPageUrl.isEmpty
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostsByAuthorView(
                                    author: reply.author,
                                  ),
                                ),
                              ),
                    ),
                  ))
              .toList()
      ],
    );
  }
}
