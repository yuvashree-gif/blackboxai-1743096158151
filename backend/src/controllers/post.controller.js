const Post = require('../models/Post');
const User = require('../models/User');
const { validationResult } = require('express-validator');

// @route   POST api/posts
// @desc    Create a post
exports.createPost = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const user = await User.findById(req.user.id).select('-password');
    
    const newPost = new Post({
      user: req.user.id,
      imageUrl: req.body.imageUrl,
      caption: req.body.caption
    });

    const post = await newPost.save();
    res.json(post);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @route   GET api/posts
// @desc    Get all posts
exports.getPosts = async (req, res) => {
  try {
    const posts = await Post.find()
      .sort({ createdAt: -1 })
      .populate('user', ['username', 'profilePicture'])
      .populate('likes', ['username']);
    res.json(posts);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @route   PUT api/posts/like/:id
// @desc    Like a post
exports.likePost = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    // Check if already liked
    if (post.likes.some(like => like.toString() === req.user.id)) {
      return res.status(400).json({ msg: 'Post already liked' });
    }

    post.likes.unshift(req.user.id);
    await post.save();

    // Emit real-time like event
    req.io.emit('post_liked', { 
      postId: post._id,
      userId: req.user.id 
    });

    res.json(post.likes);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @route   DELETE api/posts/:id
// @desc    Delete a post
exports.deletePost = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ msg: 'Post not found' });
    }

    // Check user owns post
    if (post.user.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'User not authorized' });
    }

    await post.remove();
    res.json({ msg: 'Post removed' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};