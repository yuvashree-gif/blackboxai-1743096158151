import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/services/post_service.dart';
import 'package:instagram_clone/services/auth_service.dart';
import 'package:instagram_clone/services/socket_service.dart';
import 'package:instagram_clone/widgets/post_card.dart';
import 'package:instagram_clone/screens/home/create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    
    // Like listener
    socketService.listenForLikes((postId) {
      setState(() {
        _posts = _posts.map((post) {
          if (post.id == postId) {
            return post.copyWith(
              likes: [...post.likes, 'socket_like_user_id'],
            );
          }
          return post;
        }).toList();
      });
    });

    // Comment listener
    socketService.listenForComments((data) {
      final postId = data['postId'];
      final comment = Comment.fromJson(data['comment']);
      
      setState(() {
        _posts = _posts.map((post) {
          if (post.id == postId) {
            return post.copyWith(
              comments: [comment, ...post.comments],
            );
          }
          return post;
        }).toList();
      });
    });
  }

  Future<void> _loadPosts() async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;

    try {
      final posts = await Provider.of<PostService>(context, listen: false)
          .getPosts(token);
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Clone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return PostCard(
                    post: _posts[index],
                    onLike: () => _handleLike(_posts[index]),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _handleLike(Post post) async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;

    try {
      final updatedLikes = await Provider.of<PostService>(context, listen: false)
          .likePost(post.id, token);
      
      setState(() {
        _posts = _posts.map((p) {
          if (p.id == post.id) {
            return p.copyWith(likes: updatedLikes);
          }
          return p;
        }).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}