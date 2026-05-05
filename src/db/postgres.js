const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.PG_HOST,
  port: process.env.PG_PORT || 5432,
  database: process.env.PG_DATABASE,
  user: process.env.PG_USER,
  password: process.env.PG_PASSWORD,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

async function connectPostgres() {
  try {
    await pool.connect();
    console.log('PostgreSQL connected');
    if (process.env.NODE_ENV === 'development') {
      await runMigrations();
    }
  } catch (err) {
    console.error('PostgreSQL connection failed:', err.message);
    process.exit(1);
  }
}

async function runMigrations() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id         SERIAL PRIMARY KEY,
      email      VARCHAR(255) UNIQUE NOT NULL,
      password   VARCHAR(255) NOT NULL,
      name       VARCHAR(255) NOT NULL,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS books (
      id          SERIAL PRIMARY KEY,
      title       VARCHAR(255) NOT NULL,
      author      VARCHAR(255) NOT NULL,
      isbn        VARCHAR(20) UNIQUE,
      description TEXT,
      cover_url   TEXT,
      created_by  INTEGER REFERENCES users(id),
      created_at  TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS orders (
      id         SERIAL PRIMARY KEY,
      user_id    INTEGER REFERENCES users(id),
      book_id    INTEGER REFERENCES books(id),
      status     VARCHAR(50) DEFAULT 'pending',
      ordered_at TIMESTAMPTZ DEFAULT NOW()
    );
  `);
  console.log('PostgreSQL migrations done');
}

module.exports = { pool, connectPostgres };