#!/bin/sh

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

# Run migrations if Prisma is present (client was generated at build time)
if [ -f "./prisma/schema.prisma" ]; then
  # Ensure SQLite directory exists for prisma sqlite url (../storage/anythingllm.db => /app/storage)
  mkdir -p /app/storage
  # Also create legacy/server storage path used by app code
  mkdir -p /app/server/storage
  # Also ensure STORAGE_DIR exists if provided (used by uploads/assets)
  if [ -n "$STORAGE_DIR" ]; then
    mkdir -p "$STORAGE_DIR"
  fi
  # Loosen perms to handle bind mounts from Windows hosts
  chmod -R 0777 /app/storage /app/server/storage "$STORAGE_DIR" 2>/dev/null || true
  npx prisma migrate deploy --schema=./prisma/schema.prisma || exit 1
fi

exec node /app/server/index.js
