🎮 Game Features:

5 Progressive Levels: Social Engineering → Password Cracking → Network Reconnaissance → Web Vulnerabilities → Advanced Persistent Threats
Interactive Learning: Players learn by thinking like ethical hackers
Real-time Multiplayer: Shared leaderboards and live statistics
Immersive Design: Cyberpunk aesthetic with matrix effects and hacker terminology
Educational Focus: Each level includes defense recommendations

📁 Complete File Package:

index.html - The main game interface with all interactive features
server.js - Node.js server with WebSocket support for multiplayer
package.json - Dependencies and scripts
Dockerfile - Container configuration
docker-compose.yml - Easy multi-container deployment
setup.sh - Automated deployment script
nginx.conf - Reverse proxy configuration (optional)
shadow-hacker-academy.service - Systemd service file
README.md - Comprehensive setup instructions

🚀 Quick Deployment:
Option 1: Docker (Recommended)
bash# Create directory and add files
mkdir shadow-hacker-academy && cd shadow-hacker-academy
# Copy all provided files
# Move index.html to public/index.html

# Deploy with one command
docker-compose up -d
Option 2: Automated Setup
bashchmod +x setup.sh
./setup.sh
Option 3: Manual Node.js
bashnpm install
mkdir public
# Copy index.html to public/
npm start
🎯 Game Learning Objectives:

Level 1: Social engineering psychology and human manipulation
Level 2: Password vulnerabilities and cracking techniques
Level 3: Network reconnaissance and scanning methodologies
Level 4: Web application security flaws and exploitation
Level 5: Advanced persistent threat tactics and stealth

🏆 Multiplayer Features:

Real-time leaderboards
Achievement system
Streak bonuses
Live player statistics
Competitive scoring

The game teaches cybersecurity from an attacker's perspective while emphasizing ethical use and providing defense recommendations. It's perfect for Cybersecurity Awareness Month as it makes learning engaging through gamification and hands-on scenarios.
