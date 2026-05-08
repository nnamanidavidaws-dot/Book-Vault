const express = require('express');
const { pool } = require('../db/postgres');
const mongoose = require('mongoose');

const router = express.Router();

router.get('/', async (req, res) => {
  const checks = {
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

  const statusColor = allHealthy ? '#22c55e' : '#ef4444';
  const statusText = allHealthy ? 'All Systems Operational' : 'Degraded';

  const badge = (status) => {
    const ok = status === 'ok' || status === true;
    const bg = ok ? '#22c55e' : status === 'unknown' ? '#f59e0b' : '#ef4444';
    const label = ok ? '✓ OK' : status === 'unknown' ? '? Unknown' : '✗ Error';
    return `<span style="background:${bg};color:#fff;padding:4px 12px;border-radius:999px;font-size:13px;font-weight:600;">${label}</span>`;
  };

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>BookVault — Health</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: #0f172a;
      color: #e2e8f0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .card {
      background: #1e293b;
      border-radius: 16px;
      padding: 40px;
      width: 100%;
      max-width: 480px;
      box-shadow: 0 25px 50px rgba(0,0,0,0.4);
      border: 1px solid #334155;
    }
    .logo {
      font-size: 28px;
      font-weight: 800;
      letter-spacing: -1px;
      margin-bottom: 4px;
    }
    .logo span { color: #6366f1; }
    .subtitle {
      font-size: 13px;
      color: #64748b;
      margin-bottom: 32px;
    }
    .overall {
      display: flex;
      align-items: center;
      gap: 10px;
      background: #0f172a;
      border-radius: 10px;
      padding: 16px 20px;
      margin-bottom: 24px;
      border-left: 4px solid ${statusColor};
    }
    .overall-dot {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      background: ${statusColor};
      animation: pulse 2s infinite;
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.4; }
    }
    .overall-text {
      font-weight: 600;
      font-size: 15px;
      color: ${statusColor};
    }
    .services { display: flex; flex-direction: column; gap: 12px; }
    .service {
      display: flex;
      align-items: center;
      justify-content: space-between;
      background: #0f172a;
      border-radius: 10px;
      padding: 14px 18px;
      border: 1px solid #1e293b;
    }
    .service-name {
      font-size: 14px;
      font-weight: 500;
      color: #cbd5e1;
    }
    .service-icon { margin-right: 10px; font-size: 16px; }
    .divider {
      border: none;
      border-top: 1px solid #1e293b;
      margin: 24px 0;
    }
    .timestamp {
      font-size: 12px;
      color: #475569;
      text-align: center;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">Book<span>Vault</span></div>
    <div class="subtitle">System Health Dashboard · built by yuuci, cause he's awesome </div>

    <div class="overall">
      <div class="overall-dot"></div>
      <div class="overall-text">${statusText}</div>
    </div>

    <div class="services">
      <div class="service">
        <div><span class="service-icon">🐘</span><span class="service-name">PostgreSQL (RDS)</span></div>
        ${badge(checks.postgres)}
      </div>
      <div class="service">
        <div><span class="service-icon">🍃</span><span class="service-name">MongoDB (DocumentDB)</span></div>
        ${badge(checks.mongo)}
      </div>
      <div class="service">
        <div><span class="service-icon">🪣</span><span class="service-name">S3 Bucket</span></div>
        ${badge(checks.s3_bucket_configured)}
      </div>
    </div>

    <hr class="divider"/>
    <div class="timestamp">Last checked: ${new Date().toUTCString()}</div>
  </div>
</body>
</html>`;

  res.status(allHealthy ? 200 : 503).send(html);
});

module.exports = router;