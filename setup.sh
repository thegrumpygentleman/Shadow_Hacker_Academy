#!/bin/bash

# Shadow Hacker Academy Setup Script
# This script automates the deployment process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${GREEN}"
cat << "EOF"
   _____ __              __               
  / ___// /_  ____ _____/ /___ _      __  
  \__ \/ __ \/ __ `/ __  / __ \ | /| / /  
 ___/ / / / / /_/ / /_/ / /_/ / |/ |/ /   
/____/_/ /_/\__,_/\__,_/\____/|__/|__/    
                                          
    Hacker Academy Setup Script
EOF
echo -e "${NC}"

echo -e "${CYAN}🕵️  Shadow Hacker Academy Deployment Script${NC}"
echo -e "${YELLOW}=========================================${NC}"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check for Docker
if command_exists docker; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    print_success "Docker found: $DOCKER_VERSION"
    USE_DOCKER=true
else
    print_warning "Docker not found"
    USE_DOCKER=false
fi

# Check for Docker Compose
if command_exists docker-compose; then
    COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
    print_success "Docker Compose found: $COMPOSE_VERSION"
    USE_COMPOSE=true
elif command_exists docker && docker compose version >/dev/null 2>&1; then
    print_success "Docker Compose (plugin) found"
    USE_COMPOSE=true
    COMPOSE_CMD="docker compose"
else
    print_warning "Docker Compose not found"
    USE_COMPOSE=false
    COMPOSE_CMD="docker-compose"
fi

# Check for Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    print_success "Node.js found: $NODE_VERSION"
    USE_NODE=true
else
    print_warning "Node.js not found"
    USE_NODE=false
fi

# Check for npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    print_success "npm found: $NPM_VERSION"
    USE_NPM=true
else
    print_warning "npm not found"
    USE_NPM=false
fi

echo

# Determine deployment method
if [ "$USE_DOCKER" = true ] && [ "$USE_COMPOSE" = true ]; then
    DEPLOY_METHOD="docker"
    print_status "Deployment method: Docker Compose (recommended)"
elif [ "$USE_NODE" = true ] && [ "$USE_NPM" = true ]; then
    DEPLOY_METHOD="node"
    print_status "Deployment method: Node.js"
else
    print_error "Neither Docker nor Node.js environment available!"
    print_error "Please install either:"
    print_error "  1. Docker and Docker Compose (recommended)"
    print_error "  2. Node.js and npm"
    exit 1
fi

echo

# Get user preferences
read -p "$(echo -e ${CYAN}'Enter port number (default: 3000): '${NC})" PORT
PORT=${PORT:-3000}

read -p "$(echo -e ${CYAN}'Run in background/daemon mode? (y/N): '${NC})" DAEMON_MODE
DAEMON_MODE=${DAEMON_MODE:-n}

echo

# Create project structure
print_status "Creating project structure..."

# Create directories
mkdir -p public logs data

# Copy HTML file to public directory if it doesn't exist
if [ ! -f "public/index.html" ]; then
    print_warning "index.html not found in public directory"
    print_status "Please ensure the game HTML file is placed at public/index.html"
fi

print_success "Project structure created"

# Deploy based on method
if [ "$DEPLOY_METHOD" = "docker" ]; then
    print_status "Deploying with Docker Compose..."
    
    # Update port in docker-compose.yml if needed
    if [ "$PORT" != "3000" ]; then
        print_status "Updating port configuration to $PORT..."
        sed -i.bak "s/3000:3000/$PORT:3000/" docker-compose.yml
    fi
    
    # Build and start services
    if [ "$DAEMON_MODE" = "y" ] || [ "$DAEMON_MODE" = "Y" ]; then
        print_status "Starting services in daemon mode..."
        $COMPOSE_CMD up -d --build
    else
        print_status "Starting services..."
        $COMPOSE_CMD up --build
    fi
    
elif [ "$DEPLOY_METHOD" = "node" ]; then
    print_status "Deploying with Node.js..."
    
    # Install dependencies
    if [ ! -d "node_modules" ]; then
        print_status "Installing dependencies..."
        npm install
    fi
    
    # Set port environment variable
    export PORT=$PORT
    
    # Start application
    if [ "$DAEMON_MODE" = "y" ] || [ "$DAEMON_MODE" = "Y" ]; then
        if command_exists pm2; then
            print_status "Starting with PM2..."
            pm2 start server.js --name "shadow-hacker-academy" --env PORT=$PORT
        else
            print_status "Starting in background (install PM2 for better process management)..."
            nohup npm start > logs/app.log 2>&1 &
            echo $! > logs/app.pid
        fi
    else
        print_status "Starting application..."
        npm start
    fi
fi

echo
print_success "Deployment complete!"

# Display access information
echo -e "${PURPLE}=========================================${NC}"
echo -e "${GREEN}🎮 Shadow Hacker Academy is ready!${NC}"
echo -e "${PURPLE}=========================================${NC}"
echo -e "${CYAN}🌐 Access URL: ${NC}http://localhost:$PORT"
echo -e "${CYAN}📊 Statistics: ${NC}http://localhost:$PORT/api/stats"
echo -e "${CYAN}🏆 Leaderboard: ${NC}http://localhost:$PORT/api/leaderboard"
echo

# Display management commands
echo -e "${YELLOW}Management Commands:${NC}"
if [ "$DEPLOY_METHOD" = "docker" ]; then
    echo -e "${BLUE}  View logs:${NC} $COMPOSE_CMD logs -f"
    echo -e "${BLUE}  Stop services:${NC} $COMPOSE_CMD down"
    echo -e "${BLUE}  Restart:${NC} $COMPOSE_CMD restart"
    echo -e "${BLUE}  Update:${NC} $COMPOSE_CMD pull && $COMPOSE_CMD up -d"
elif [ "$DEPLOY_METHOD" = "node" ]; then
    if command_exists pm2 && [ "$DAEMON_MODE" = "y" ] || [ "$DAEMON_MODE" = "Y" ]; then
        echo -e "${BLUE}  View logs:${NC} pm2 logs shadow-hacker-academy"
        echo -e "${BLUE}  Stop service:${NC} pm2 stop shadow-hacker-academy"
        echo -e "${BLUE}  Restart:${NC} pm2 restart shadow-hacker-academy"
        echo -e "${BLUE}  Status:${NC} pm2 status"
    else
        echo -e "${BLUE}  Stop service:${NC} kill \$(cat logs/app.pid) (if running in background)"
        echo -e "${BLUE}  View logs:${NC} tail -f logs/app.log"
    fi
fi

echo
echo -e "${GREEN}Happy Hacking! 🕵️${NC}"

# Health check
sleep 5
print_status "Performing health check..."

if curl -f http://localhost:$PORT/api/stats >/dev/null 2>&1; then
    print_success "Health check passed - server is responding"
else
    print_warning "Health check failed - server might still be starting up"
    print_status "Try accessing http://localhost:$PORT in a few moments"
fi
