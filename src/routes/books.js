const express = require('express');
const { pool } = require('../db/postgres');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// GET /api/books — list all books
router.get('/', async (req, res, next) => {
  try {
    const { rows } = await pool.query(
      'SELECT b.*, u.name AS added_by FROM books b LEFT JOIN users u ON b.created_by = u.id ORDER BY b.created_at DESC'
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /api/books/:id — single book
router.get('/:id', async (req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT * FROM books WHERE id = $1', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Book not found' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// POST /api/books — create a book (auth required)
router.post('/', authenticate, async (req, res, next) => {
  try {
    const { title, author, isbn, description, cover_url } = req.body;
    if (!title || !author) return res.status(400).json({ error: 'title and author are required' });

    const { rows } = await pool.query(
      'INSERT INTO books (title, author, isbn, description, cover_url, created_by) VALUES ($1,$2,$3,$4,$5,$6) RETURNING *',
      [title, author, isbn, description, cover_url, req.user.id]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    if (err.code === '23505') return res.status(409).json({ error: 'ISBN already exists' });
    next(err);
  }
});

// PUT /api/books/:id — update a book (auth required)
router.put('/:id', authenticate, async (req, res, next) => {
  try {
    const { title, author, isbn, description, cover_url } = req.body;
    const { rows } = await pool.query(
      `UPDATE books SET
        title       = COALESCE($1, title),
        author      = COALESCE($2, author),
        isbn        = COALESCE($3, isbn),
        description = COALESCE($4, description),
        cover_url   = COALESCE($5, cover_url)
       WHERE id = $6 RETURNING *`,
      [title, author, isbn, description, cover_url, req.params.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Book not found' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// DELETE /api/books/:id (auth required)
router.delete('/:id', authenticate, async (req, res, next) => {
  try {
    const { rowCount } = await pool.query('DELETE FROM books WHERE id = $1', [req.params.id]);
    if (!rowCount) return res.status(404).json({ error: 'Book not found' });
    res.json({ message: 'Book deleted' });
  } catch (err) {
    next(err);
  }
});

// POST /api/books/:id/order — place an order (auth required)
router.post('/:id/order', authenticate, async (req, res, next) => {
  try {
    const { rows } = await pool.query(
      'INSERT INTO orders (user_id, book_id) VALUES ($1, $2) RETURNING *',
      [req.user.id, req.params.id]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
});

module.exports = router;