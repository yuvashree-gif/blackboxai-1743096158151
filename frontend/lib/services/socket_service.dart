import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;
  static const String serverUrl = 'http://localhost:5000';

  SocketService() {
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  void connect() {
    _socket.connect();
    _socket.onConnect((_) {
      print('Connected to socket server');
    });
  }

  void disconnect() {
    _socket.disconnect();
  }

  void likePost(String postId, String userId) {
    _socket.emit('like_post', {
      'postId': postId,
      'userId': userId,
    });
  }

  void listenForLikes(Function(String) callback) {
    _socket.on('post_liked', (data) {
      callback(data['postId']);
    });
  }

  void listenForComments(Function(Map<String, dynamic>) callback) {
    _socket.on('new_comment', (data) {
      callback(data);
    });
  }
}