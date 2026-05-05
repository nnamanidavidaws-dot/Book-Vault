const express = require('express');
const { Review, ReadingHistory } = require('../models/mongo');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// GET /api/reviews/book/:bookId — all reviews for a book
router.get('/book/:bookId', async (req, res, next) => {
  try {
    const reviews = await Review.find({ bookId: req.params.bookId }).sort({ createdAt: -1 });
    res.json(reviews);
  } catch (err) {
    next(err);
  }
});

// POST /api/reviews — create a review (auth required)
router.post('/', authenticate, async (req, res, next) => {
  try {
    const { bookId, rating, body, tags } = req.body;
    if (!bookId || !rating || !body) {
      return res.status(400).json({ error: 'bookId, rating, and body are required' });
    }

    const review = await Review.create({
      bookId,
      userId: req.user.id,
      rating,
      body,
      tags,
    });
    res.status(201).json(review);
  } catch (err) {
    next(err);
  }
});

// DELETE /api/reviews/:id (auth required, own reviews only)
router.delete('/:id', authenticate, async (req, res, next) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) return res.status(404).json({ error: 'Review not found' });
    if (review.userId !== req.user.id) return res.status(403).json({ error: 'Not your review' });

    await review.deleteOne();
    res.json({ message: 'Review deleted' });
  } catch (err) {
    next(err);
  }
});

// GET /api/reviews/history — reading history for logged-in user
router.get('/history', authenticate, async (req, res, next) => {
  try {
    const history = await ReadingHistory.find({ userId: req.user.id }).sort({ updatedAt: -1 });
    res.json(history);
  } catch (err) {
    next(err);
  }
});

// POST /api/reviews/history — add or update reading history
router.post('/history', authenticate, async (req, res, next) => {
  try {
    const { bookId, status, notes, startedAt, finishedAt } = req.body;
    if (!bookId) return res.status(400).json({ error: 'bookId is required' });

    const entry = await ReadingHistory.findOneAndUpdate(
      { userId: req.user.id, bookId },
      { status, notes, startedAt, finishedAt, updatedAt: new Date() },
      { upsert: true, new: true }
    );
    res.status(201).json(entry);
  } catch (err) {
    next(err);
  }
});

module.exports = router;