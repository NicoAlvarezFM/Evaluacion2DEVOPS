#!/bin/bash

echo "🚀 Building Docker image..."
docker build -t bdget-microservicio:latest .

if [ $? -eq 0 ]; then
    echo "✅ Build successful"
    echo ""
    docker images bdget-microservicio:latest
    echo ""
    echo "Run: docker run -p 8080:8080 --env-file .env bdget-microservicio:latest"
else
    echo "❌ Build failed"
    exit 1
fi
