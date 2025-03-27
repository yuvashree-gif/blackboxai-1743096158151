import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/services/auth_service.dart';
import 'package:provider/provider.dart';

class PostService {
  static const String _baseUrl = 'http://localhost:5000/api/posts';

  Future<List<Post>> getPosts(String token) async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<String> uploadImage(File image, String token) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload'),
    );
    request.headers['x-auth-token'] = token;
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
    ));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return json.decode(responseData)['imageUrl'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<Post> createPost({
    required File imageFile,
    required String caption,
    required String token,
  }) async {
    final imageUrl = await uploadImage(imageFile, token);
    
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token
      },
      body: json.encode({
        'imageUrl': imageUrl,
        'caption': caption,
      }),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<List<String>> likePost(String postId, String token) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/like/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token
      },
    );

    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to like post');
    }
  }

  Future<List<Comment>> addComment(String postId, String text, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/comment/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token
      },
      body: json.encode({
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return List<Comment>.from(
        responseData.map((comment) => Comment.fromJson(comment)),
      );
    } else {
      throw Exception('Failed to add comment');
    }
  }

  Future<void> deletePost(String postId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}