# Build stage
FROM node:23-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Production stage
FROM node:23-alpine

# Create app directory and non-root user
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only necessary files from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/src ./src
COPY --from=builder /app/node_modules ./node_modules

# Set ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Command to run the application
CMD ["node", "src/index.js"]
