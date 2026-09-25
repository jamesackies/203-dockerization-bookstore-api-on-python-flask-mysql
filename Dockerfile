FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY bookstore-api.py .

# Expose port 80
EXPOSE 80

# Run the Flask application
CMD ["python", "bookstore-api.py"]
