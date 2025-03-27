import 'package:flutter/material.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.user.profilePicture != null
                      ? CachedNetworkImageProvider(post.user.profilePicture!)
                      : null,
                  child: post.user.profilePicture == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  post.user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Post image
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: post.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

          // Post actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : null,
                  ),
                  onPressed: onLike,
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Likes count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${post.likes.length} likes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: post.user.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),

          // Comments section
          if (post.comments.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  if (post.comments.isNotEmpty)
                    Column(
                      children: [
                        if (post.comments.length > 2)
                          GestureDetector(
                            onTap: () => _showAllComments(context, post),
                            child: Text(
                              'View all ${post.comments.length} comments',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ...post.comments.take(2).map(
                          (comment) => CommentWidget(comment: comment),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          
          // Comment input
          CommentInput(
            onCommentSubmitted: (text) async {
              final token = Provider.of<AuthService>(context, listen: false).token;
              if (token == null) return;
              
              try {
                final updatedComments = await Provider.of<PostService>(context, listen: false)
                    .addComment(post.id, text, token);
                // Update UI with new comments
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString())),
                );
              }
            },
          ),
          
          // Timestamp
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 16.0),
            child: Text(
              timeago.format(post.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}