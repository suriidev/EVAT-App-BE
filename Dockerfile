# ---- Stage 1: Build ----
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies, needed for tsc + @types/*)
RUN npm install

# Copy source code and TypeScript config
COPY . .

# Build TypeScript code
RUN npm run build

# ---- Stage 2: Production runtime ----
FROM node:18-alpine

WORKDIR /app

ENV NODE_ENV=production

# Copy package files and install ONLY production dependencies
COPY package*.json ./
RUN npm install --production

# Copy compiled JS output from the builder stage
COPY --from=builder /app/src ./src
COPY --from=builder /app/server.js ./server.js

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["node", "server.js"]