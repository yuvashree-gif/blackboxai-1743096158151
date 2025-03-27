const express = require('express');
const router = express.Router();
const multer = require('multer');
const { check } = require('express-validator');
const auth = require('../middleware/auth');
const postController = require('../controllers/post.controller');

const upload = multer({ dest: 'uploads/' });

// @route   POST api/posts/upload
// @desc    Upload post image
router.post('/upload', auth, upload.single('image'), postController.uploadImage);

// @route   POST api/posts
// @desc    Create a post
router.post(
  '/',
  [
    auth,
    [
      check('imageUrl', 'Image URL is required').not().isEmpty(),
      check('caption', 'Caption is required').not().isEmpty()
    ]
  ],
  postController.createPost
);

// @route   GET api/posts
// @desc    Get all posts
router.get('/', auth, postController.getPosts);

// @route   PUT api/posts/like/:id
// @desc    Like a post
router.put('/like/:id', auth, postController.likePost);

// @route   POST api/posts/comment/:id
// @desc    Add comment to post
router.post(
  '/comment/:id',
  [
    auth,
    [check('text', 'Text is required').not().isEmpty()]
  ],
  postController.addComment
);

// @route   DELETE api/posts/:id
// @desc    Delete a post
router.delete('/:id', auth, postController.deletePost);

module.exports = router;