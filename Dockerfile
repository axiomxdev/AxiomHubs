# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install all dependencies (including devDependencies for build)
RUN npm ci

# Copy source code
COPY src ./src

# Build the application
RUN npm run build

# Stage 2: Production
FROM node:20-alpine

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --only=production

# Copy built application from builder stage
COPY --from=builder /app/dist ./dist

# Create directories for runtime data
RUN mkdir -p /app/dist/db

# Set environment to production
ENV NODE_ENV=production

# Expose port (adjust if needed)
EXPOSE 3000

# Start the application
CMD ["node", "dist/server.js"]
