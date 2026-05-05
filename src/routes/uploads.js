const express = require('express');
const multer = require('multer');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// Multer stores the file in memory so we can pipe it straight to S3
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB max
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only image files are allowed'));
    }
    cb(null, true);
  },
});

const s3 = new S3Client({
  region: process.env.AWS_REGION,
  // On an EC2 instance with an IAM role attached, credentials are picked up
  // automatically — no access key or secret needed here.
});

// POST /api/uploads/cover — upload a book cover image
router.post('/cover', authenticate, upload.single('cover'), async (req, res, next) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No file uploaded' });

    const key = `covers/${Date.now()}-${req.file.originalname.replace(/\s+/g, '-')}`;

    await s3.send(new PutObjectCommand({
      Bucket: process.env.S3_BUCKET,
      Key: key,
      Body: req.file.buffer,
      ContentType: req.file.mimetype,
    }));

    const url = `https://${process.env.S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
    res.json({ url });
  } catch (err) {
    next(err);
  }
});

module.exports = router;