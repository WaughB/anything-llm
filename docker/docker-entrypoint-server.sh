#!/bin/bash

# Backend-only entrypoint (no collector)

# Check if STORAGE_DIR is set
if [ -z "$STORAGE_DIR" ]; then
    echo "================================================================"
    echo "⚠️  ⚠️  ⚠️  WARNING: STORAGE_DIR environment variable is not set! ⚠️  ⚠️  ⚠️"
    echo ""
    echo "Not setting this will result in data loss on container restart since"
    echo "the application will not have a persistent storage location."
    echo "It can also result in weird errors in various parts of the application."
    echo ""
    echo "Please run the container with the official docker command at"
    echo "https://docs.anythingllm.com/installation-docker/quickstart"
    echo ""
    echo "⚠️  ⚠️  ⚠️  WARNING: STORAGE_DIR environment variable is not set! ⚠️  ⚠️  ⚠️"
    echo "================================================================"
fi

cd /app/server || exit 1

# Generate Prisma client and run migrations if Prisma is present
if [ -f "./prisma/schema.prisma" ]; then
  # Ensure SQLite directory exists
  mkdir -p /app/server/storage
  # Also ensure STORAGE_DIR exists if provided (used by uploads/assets)
  if [ -n "$STORAGE_DIR" ]; then
    mkdir -p "$STORAGE_DIR"
  fi
  npx prisma generate --schema=./prisma/schema.prisma || exit 1
  npx prisma migrate deploy --schema=./prisma/schema.prisma || exit 1
fi

exec node /app/server/index.js
