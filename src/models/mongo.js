const mongoose = require('mongoose');

// Reviews — unstructured, flexible fields per book
const reviewSchema = new mongoose.Schema({
  bookId:    { type: Number, required: true }, // references books.id in Postgres
  userId:    { type: Number, required: true }, // references users.id in Postgres
  rating:    { type: Number, min: 1, max: 5, required: true },
  body:      { type: String, required: true },
  tags:      [String],
  createdAt: { type: Date, default: Date.now },
});

// Reading history — flexible per-user log
const readingHistorySchema = new mongoose.Schema({
  userId:       { type: Number, required: true },
  bookId:       { type: Number, required: true },
  status:       { type: String, enum: ['reading', 'finished', 'want-to-read'], default: 'want-to-read' },
  startedAt:    Date,
  finishedAt:   Date,
  notes:        String,
  updatedAt:    { type: Date, default: Date.now },
});

const Review = mongoose.model('Review', reviewSchema);
const ReadingHistory = mongoose.model('ReadingHistory', readingHistorySchema);

module.exports = { Review, ReadingHistory };