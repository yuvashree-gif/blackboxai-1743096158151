import 'package:flutter/material.dart';

class CommentInput extends StatefulWidget {
  final Function(String) onCommentSubmitted;

  const CommentInput({
    super.key,
    required this.onCommentSubmitted,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  void _submitComment() async {
    if (_textController.text.isEmpty) return;
    
    setState(() => _isSubmitting = true);
    try {
      await widget.onCommentSubmitted(_textController.text);
      _textController.clear();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          IconButton(
            icon: _isSubmitting
                ? const CircularProgressIndicator()
                : const Icon(Icons.send),
            onPressed: _isSubmitting ? null : _submitComment,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}