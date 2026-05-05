require('dotenv').config();
const express = require('express');
const cors = require('cors');

const { connectPostgres } = require('./db/postgres');
const { connectMongo } = require('./db/mongo');

const authRoutes = require('./routes/auth');
const bookRoutes = require('./routes/books');
const reviewRoutes = require('./routes/reviews');
const uploadRoutes = require('./routes/uploads');
const healthRoutes = require('./routes/health');

const app = express();

app.use(cors());
app.use(express.json());

// Routes
app.use('/health', healthRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/books', bookRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/uploads', uploadRoutes);

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ error: err.message || 'Internal server error' });
});

async function start() {
  await connectPostgres();
  await connectMongo();

  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`BookVault running on port ${PORT}`);
  });
}

start();