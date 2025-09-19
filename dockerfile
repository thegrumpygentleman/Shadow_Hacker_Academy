# Use official Node.js runtime
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Create public directory and copy game file
RUN mkdir -p public
COPY index.html public/

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S hacker -u 1001

# Change ownership of app directory
RUN chown -R hacker:nodejs /app
USER hacker

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/api/stats || exit 1

# Start the application
CMD ["npm", "start"]
