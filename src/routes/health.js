const express = require('express');
const { pool } = require('../db/postgres');
const mongoose = require('mongoose');

const router = express.Router();

// GET /health — used by load balancers, CI/CD smoke tests, and monitoring
router.get('/', async (req, res) => {
  const checks = {
    app: 'ok',
    postgres: 'unknown',
    mongo: 'unknown',
    s3_bucket_configured: !!process.env.S3_BUCKET,
  };

  try {
    await pool.query('SELECT 1');
    checks.postgres = 'ok';
  } catch {
    checks.postgres = 'error';
  }

  checks.mongo = mongoose.connection.readyState === 1 ? 'ok' : 'error';

  const allHealthy = checks.postgres === 'ok' && checks.mongo === 'ok';
  res.status(allHealthy ? 200 : 503).json(checks);
});

module.exports = router;