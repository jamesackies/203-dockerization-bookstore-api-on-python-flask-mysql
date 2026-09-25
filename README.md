# Project 203 - Dockerization of Bookstore Web API

A RESTful Bookstore Web API built with Python Flask and MySQL, fully containerized with Docker and Docker Compose, deployed on an AWS EC2 instance provisioned with Terraform.

---

## Architecture Overview

```
EC2 Instance (Amazon Linux 2, t2.micro)
  |
  Docker Engine
    |
    Docker Compose (custom bridge network: bookstore-net)
      |
      |---- bookstore-app (Flask API, port 80)
      |---- bookstore-db  (MySQL 8.0, port 3306)
```

---

## Project Structure

```
203-dockerization-bookstore-api-on-python-flask-mysql/
|---- README.md
|---- bookstore-api.py       # Python Flask REST API
|---- requirements.txt       # Python dependencies
|---- Dockerfile             # Flask app image definition
|---- docker-compose.yml     # Multi-container setup
|---- main.tf                # Terraform infrastructure config
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Welcome message |
| GET | `/books` | Get all books |
| GET | `/books/<book_id>` | Get a single book by ID |
| POST | `/books` | Add a new book |
| PUT | `/books/<book_id>` | Update an existing book |
| DELETE | `/books/<book_id>` | Delete a book |

---

## Technologies Used

| Layer | Technology |
|-------|-----------|
| Application | Python 3.9, Flask 2.3.3, flask-mysql |
| Database | MySQL 8.0 |
| Containerization | Docker, Docker Compose |
| Infrastructure | AWS EC2 (Amazon Linux 2, t2.micro) |
| IaC | Terraform |
| Version Control | Git / GitHub |

---

## Docker Setup

### Dockerfile
Builds the Flask app image from `python:3.9-slim`, installs dependencies from `requirements.txt`, and runs the app on port 80.

### Docker Compose Services

| Service | Image | Port | Role |
|---------|-------|------|------|
| `database` | mysql:8.0 | 3306 (internal) | MySQL database |
| `app` | built from Dockerfile | 80:80 | Flask REST API |

Both services run on a custom bridge network named `bookstore-net`. The app service waits for the database health check to pass before starting.

---

## AWS Resources Created by Terraform

- **Security Group** — allows HTTP (80) and SSH (22) from anywhere
- **EC2 Instance** — Amazon Linux 2, t2.micro, tagged "Web Server of Bookstore"
- **User Data Script** — installs Docker and Docker Compose, clones repo from GitHub, runs `docker-compose up`

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform installed (v1.0+)
- GitHub repository with the application code pushed

---

## Setup & Deployment

### 1. Update the GitHub repo URL in main.tf

Find the user data section and replace the placeholder:
```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git app
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Preview the plan
```bash
terraform plan
```

### 4. Deploy to AWS
```bash
terraform apply
```

Terraform outputs the API URL on completion:
```
Outputs:
bookstore_api_url    = "http://<ec2-public-dns>"
bookstore_public_ip  = "<ec2-public-ip>"
```

### 5. Destroy resources when done
```bash
terraform destroy
```

---

## Testing the API with curl

```bash
# Get all books
curl http://<ec2-hostname>/books

# Get a single book
curl http://<ec2-hostname>/books/1

# Add a new book
curl -H "Content-Type: application/json" -X POST -d '{"title":"The Alchemist","author":"Paulo Coelho"}' http://<ec2-hostname>/books

# Update a book
curl -H "Content-Type: application/json" -X PUT -d '{"title":"The Alchemist","author":"Paulo Coelho","is_sold":true}' http://<ec2-hostname>/books/1

# Delete a book
curl -X DELETE http://<ec2-hostname>/books/1
```

---

## Developer

Developed by **James Ackies** | Deployed with Docker & Terraform on AWS
