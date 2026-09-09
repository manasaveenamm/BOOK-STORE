# Stage 1: Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package management files first to leverage Docker caching
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy full application code and build
COPY . .
RUN npm run build --if-present

# Stage 2: Production runtime stage
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Copy built application assets and production modules from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

EXPOSE 8080

CMD ["npm", "start"]
