# 🕵️ Shadow Hacker Academy

An interactive cybersecurity awareness game designed for **Cybersecurity Awareness Month**. Players learn essential cybersecurity concepts by thinking like ethical hackers, making it engaging and educational.

## 🎮 Game Features

- **5 Progressive Levels**: From Social Engineering to Advanced Persistent Threats
- **Interactive Scenarios**: Real-world hacking scenarios with educational context
- **Multiplayer Support**: Compete with colleagues on a shared leaderboard
- **Real-time Feedback**: Learn from mistakes with detailed explanations
- **Achievement System**: Unlock achievements and maintain streaks
- **Hacker Aesthetic**: Immersive terminal-style interface with matrix effects

## 🚀 Quick Start

### Option 1: Docker (Recommended)

```bash
# Clone or create the project directory
mkdir shadow-hacker-academy
cd shadow-hacker-academy

# Copy all the provided files into this directory
# (package.json, server.js, Dockerfile, docker-compose.yml, and index.html in public/)

# Start the game
docker-compose up -d

# Access at http://localhost:3000
```

### Option 2: Manual Setup

1. **Prerequisites**:
   - Node.js 16+ and npm
   - Git (optional)

2. **Installation**:
```bash
# Create project directory
mkdir shadow-hacker-academy
cd shadow-hacker-academy

# Initialize and install dependencies
npm install express ws uuid

# Create public directory and add game files
mkdir public
# Copy index.html to public/index.html
# Copy server.js to root directory

# Start the server
npm start
```

## 📁 Project Structure

```
shadow-hacker-academy/
├── public/
│   └── index.html          # Main game interface
├── server.js               # Node.js server with WebSocket support
├── package.json            # Project dependencies
├── Dockerfile              # Container configuration
├── docker-compose.yml      # Multi-container setup
└── README.md              # This file
```

## 🔧 Configuration

### Environment Variables

- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment (development/production)

### Server Features

- **Real-time Multiplayer**: WebSocket support for live leaderboards
- **RESTful API**: Score submission and statistics endpoints
- **Session Management**: Track individual player progress
- **Auto-save**: Periodic leaderboard persistence

## 🎯 Game Levels

1. **Social Engineering Basics** - Learn psychological manipulation techniques
2. **Password Cracking** - Understand credential attack methods
3. **Network Reconnaissance** - Master network scanning and enumeration
4. **Web Application Vulnerabilities** - Exploit common web security flaws
5. **Advanced Persistent Threats** - Long-term stealth attack campaigns

## 🏆 Scoring System

- **Correct Answers**: 100-250 points based on difficulty
- **Streak Bonuses**: Extra points for consecutive correct answers
- **Achievements**: Special recognition for milestones
- **Rank Progression**: From "Noob" to "Elite Hacker"

## 🔒 Security & Privacy

- No personal information collected beyond chosen usernames
- All data stored in memory (resets on server restart)
- Educational content only - promotes ethical hacking practices
- Includes defense recommendations for each attack type

## 🎨 Customization

### Adding New Levels

Edit the `levels` object in `index.html` to add new scenarios:

```javascript
levels[6] = {
    title: "Your New Level",
    description: "Description of the level",
    questions: [
        {
            scenario: "Your scenario description",
            prompt: "🎯 YOUR PROMPT: Choose your approach...",
            options: ["Option 1", "Option 2", "Option 3", "Option 4"],
            correct: 0,
            explanation: "Why this answer is correct",
            points: 150
        }
    ]
};
```

### Styling Customization

The game uses a cyberpunk/hacker aesthetic with:
- Matrix-style background effects
- Terminal-inspired UI elements
- Green/orange color scheme
- Responsive design for mobile devices

## 📊 Monitoring & Analytics

Access real-time statistics at:
- `GET /api/stats` - Player statistics and server metrics
- `GET /api/leaderboard` - Top 10 players
- WebSocket events for real-time updates

## 🛠️ Deployment Options

### Internal Server Deployment

1. **Basic Setup**:
```bash
npm start
# Access at http://your-server-ip:3000
```

2. **With Process Manager**:
```bash
npm install -g pm2
pm2 start server.js --name "hacker-academy"
pm2 startup
pm2 save
```

3. **With Reverse Proxy** (nginx):
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Docker Production Deployment

```bash
# Build and run
docker-compose up -d

# Scale for high usage
docker-compose up -d --scale shadow-hacker-academy=3

# View logs
docker-compose logs -f

# Update
docker-compose pull && docker-compose up -d
```

## 🤝 Contributing

This game is designed for educational purposes during Cybersecurity Awareness Month. Contributions should focus on:

- Adding new educational scenarios
- Improving accessibility
- Enhancing the learning experience
- Bug fixes and performance improvements

## 📜 License

MIT License - Feel free to use and modify for educational purposes.

## ⚠️ Disclaimer

This game is for educational purposes only. All techniques described should only be used for legitimate security testing and defense. Always obtain proper authorization before testing security controls.

---

**🎯 Ready to think like a hacker and defend like a pro?**

Start your journey: `docker-compose up -d` and visit `http://localhost:3000`
