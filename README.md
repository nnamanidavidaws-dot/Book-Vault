# 📚 BookVault

A production-grade RESTful API for a book management platform, deployed on AWS with a full CI/CD pipeline.

---

## What It Does

BookVault lets users register, log in, manage books, write reviews, track reading history, and upload book cover images. It's a backend API — no frontend, just clean endpoints.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js 20 + Express |
| SQL Database | PostgreSQL (AWS RDS) |
| NoSQL Database | MongoDB (AWS DocumentDB) |
| File Storage | AWS S3 |
| Auth | JWT + bcrypt |
| Container | Docker |
| Infrastructure | Terraform |
| CI/CD | GitHub Actions + AWS ECR |

---

## Architecture

```
Internet
   ↓
Application Load Balancer (public subnet)
   ↓
App Server — EC2 (private subnet)
   ↓              ↓            ↓
 RDS         DocumentDB       S3
(PostgreSQL)  (MongoDB)    (covers)
```

The app server lives in a private subnet. The only way in is through the ALB (port 3000) or the Bastion Host (SSH). Nothing is publicly accessible except what needs to be.

---

## API Endpoints

### Auth
```
POST /api/auth/register
POST /api/auth/login
```

### Books
```
GET    /api/books
GET    /api/books/:id
POST   /api/books              (auth required)
PUT    /api/books/:id          (auth required)
DELETE /api/books/:id          (auth required)
POST   /api/books/:id/order    (auth required)
```

### Reviews
```
GET  /api/reviews/book/:bookId
POST /api/reviews              (auth required)
GET  /api/reviews/history      (auth required)
POST /api/reviews/history      (auth required)
```

### Uploads
```
POST /api/uploads/cover        (auth required, form-data)
```

### Health
```
GET /health
```

---

## Running Locally

**Prerequisites:** Docker and Docker Compose

**1. Clone the repo**
```bash
git clone https://github.com/yourusername/bookvault.git
cd bookvault
```

**2. Create your `.env` file**
```bash
cp .env.example .env
```

Fill in the values. For local development the defaults work out of the box with Docker Compose.

**3. Start everything**
```bash
docker compose up --build
```

This starts the app, a local PostgreSQL instance, and a local MongoDB instance. Tables are created automatically in development mode.

**4. Test it**
```
GET http://localhost:3000/health
```

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `PORT` | Server port (default 3000) |
| `NODE_ENV` | `development` or `production` |
| `JWT_SECRET` | Secret key for signing JWT tokens |
| `PG_HOST` | PostgreSQL host |
| `PG_PORT` | PostgreSQL port (default 5432) |
| `PG_DATABASE` | Database name |
| `PG_USER` | Database user |
| `PG_PASSWORD` | Database password |
| `MONGO_URI` | MongoDB/DocumentDB connection string |
| `AWS_REGION` | AWS region |
| `S3_BUCKET` | S3 bucket name for file uploads |

---

## CI/CD Pipeline

Every push to `main` triggers the pipeline:

1. Builds the Docker image
2. Pushes to AWS ECR tagged with the Git commit SHA
3. SSHes through the Bastion Host into the private App Server
4. Pulls the new image and restarts the container

**Required GitHub Secrets:**

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `BASTION_IP` | Bastion Host public IP |
| `APP_SERVER_IP` | App Server private IP |
| `SSH_PRIVATE_KEY` | Contents of your `.pem` key file |

---

## Infrastructure

Provisioned with Terraform, organised across multiple files:

| File | Contents |
|------|----------|
| `main.tf` | VPC, subnets, IGW, NAT Gateway, S3 endpoint |
| `ec2.tf` | Bastion Host, App Server |
| `db.tf` | RDS (PostgreSQL), DocumentDB |
| `sg.tf` | All 5 security groups and rules |
| `route.tf` | Route tables and associations |
| `variables.tf` | Input variables |
| `output.tf` | Outputs — endpoints, IPs, DNS names |

> **Never commit `terraform.tfvars` or `.env` to version control.**

---

## Project Structure

```
bookvault/
├── src/
│   ├── app.js
│   ├── db/
│   │   ├── postgres.js
│   │   └── mongo.js
│   ├── middleware/
│   │   └── auth.js
│   ├── models/
│   │   └── mongo.js
│   └── routes/
│       ├── auth.js
│       ├── books.js
│       ├── reviews.js
│       ├── uploads.js
│       └── health.js
├── .github/
│   └── workflows/
│       └── deploy.yml
├── Dockerfile
├── docker-compose.yml
├── package.json
└── .env.example
```

---

## Notes on DocumentDB

AWS DocumentDB is MongoDB-compatible but not identical. The connection string requires these additional parameters:

```
?tls=true&tlsAllowInvalidCertificates=true&authMechanism=SCRAM-SHA-1&retryWrites=false
```
