const express = require('express');
const WebSocket = require('ws');
const http = require('http');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 3000;

// In-memory storage for game sessions and leaderboard
let gameSessions = new Map();
let globalLeaderboard = [];
let activeUsers = new Set();

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

// API Routes
app.get('/api/leaderboard', (req, res) => {
    res.json(globalLeaderboard.slice(0, 10));
});

app.post('/api/score', (req, res) => {
    const { playerName, score, level } = req.body;
    
    if (!playerName || typeof score !== 'number') {
        return res.status(400).json({ error: 'Invalid data' });
    }
    
    // Update or add to leaderboard
    const existingIndex = globalLeaderboard.findIndex(entry => entry.name === playerName);
    const playerEntry = {
        name: playerName,
        score: score,
        level: level || 1,
        timestamp: new Date().toISOString()
    };
    
    if (existingIndex >= 0) {
        if (score > globalLeaderboard[existingIndex].score) {
            globalLeaderboard[existingIndex] = playerEntry;
        }
    } else {
        globalLeaderboard.push(playerEntry);
    }
    
    // Sort and keep top 100
    globalLeaderboard.sort((a, b) => b.score - a.score);
    globalLeaderboard = globalLeaderboard.slice(0, 100);
    
    // Broadcast leaderboard update
    broadcastToAll({
        type: 'leaderboardUpdate',
        leaderboard: globalLeaderboard.slice(0, 10)
    });
    
    res.json({ success: true, rank: getRank(score) });
});

app.get('/api/stats', (req, res) => {
    res.json({
        activeUsers: activeUsers.size,
        totalPlayers: globalLeaderboard.length,
        highScore: globalLeaderboard.length > 0 ? globalLeaderboard[0].score : 0,
        averageScore: globalLeaderboard.length > 0 ? 
            Math.round(globalLeaderboard.reduce((sum, entry) => sum + entry.score, 0) / globalLeaderboard.length) : 0
    });
});

// WebSocket connection handling
wss.on('connection', (ws, req) => {
    const sessionId = uuidv4();
    ws.sessionId = sessionId;
    
    console.log(`New connection: ${sessionId}`);
    activeUsers.add(sessionId);
    
    // Send initial data
    ws.send(JSON.stringify({
        type: 'connected',
        sessionId: sessionId,
        leaderboard: globalLeaderboard.slice(0, 10),
        stats: {
            activeUsers: activeUsers.size,
            totalPlayers: globalLeaderboard.length
        }
    }));
    
    // Broadcast user count update
    broadcastToAll({
        type: 'userCountUpdate',
        activeUsers: activeUsers.size
    });
    
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            handleWebSocketMessage(ws, data);
        } catch (error) {
            console.error('Invalid WebSocket message:', error);
        }
    });
    
    ws.on('close', () => {
        console.log(`Connection closed: ${sessionId}`);
        activeUsers.delete(sessionId);
        gameSessions.delete(sessionId);
        
        // Broadcast user count update
        broadcastToAll({
            type: 'userCountUpdate',
            activeUsers: activeUsers.size
        });
    });
});

function handleWebSocketMessage(ws, data) {
    switch (data.type) {
        case 'joinGame':
            gameSessions.set(ws.sessionId, {
                playerName: data.playerName,
                currentLevel: 1,
                score: 0,
                streak: 0,
                startTime: new Date()
            });
            
            ws.send(JSON.stringify({
                type: 'gameJoined',
                playerName: data.playerName
            }));
            break;
            
        case 'submitAnswer':
            handleAnswerSubmission(ws, data);
            break;
            
        case 'requestHint':
            sendHint(ws, data.level, data.question);
            break;
            
        default:
            console.log('Unknown message type:', data.type);
    }
}

function handleAnswerSubmission(ws, data) {
    const session = gameSessions.get(ws.sessionId);
    if (!session) return;
    
    const { level, question, answer, isCorrect, points } = data;
    
    if (isCorrect) {
        session.score += points;
        session.streak++;
    } else {
        session.streak = 0;
    }
    
    // Send feedback
    ws.send(JSON.stringify({
        type: 'answerFeedback',
        correct: isCorrect,
        newScore: session.score,
        streak: session.streak,
        bonusPoints: session.streak >= 3 ? 50 : 0
    }));
    
    // Check for achievements
    checkAchievements(ws, session);
}

function sendHint(ws, level, question) {
    // Predefined hints for each level/question
    const hints = {
        1: {
            0: "Think about what makes people act without thinking carefully...",
            1: "Consider which role gives you the most legitimate reason to enter...",
            2: "What makes you trust an email more - generic or personal details?"
        },
        2: {
            0: "What do most users choose for passwords?",
            1: "Look for patterns in character substitutions...",
            2: "Think efficiency - start with the easiest targets first..."
        }
        // Add more hints as needed
    };
    
    const hint = hints[level] && hints[level][question] ? 
        hints[level][question] : "Think like a hacker - what's the easiest path to success?";
    
    ws.send(JSON.stringify({
        type: 'hint',
        message: hint
    }));
}

function checkAchievements(ws, session) {
    const achievements = [];
    
    if (session.score >= 1000 && session.score - session.previousScore < 1000) {
        achievements.push("🏆 Elite Status - 1000+ points!");
    }
    
    if (session.streak >= 5) {
        achievements.push(`🔥 Hot Streak - ${session.streak} correct answers!`);
    }
    
    if (achievements.length > 0) {
        ws.send(JSON.stringify({
            type: 'achievements',
            achievements: achievements
        }));
    }
    
    session.previousScore = session.score;
}

function broadcastToAll(message) {
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(message));
        }
    });
}

function getRank(score) {
    if (score >= 2000) return 'Elite Hacker';
    if (score >= 1500) return 'Advanced Hacker';
    if (score >= 1000) return 'Intermediate Hacker';
    if (score >= 500) return 'Novice Hacker';
    if (score >= 200) return 'Script Kiddie';
    return 'Noob';
}

// Serve the main game file
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Error handling
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
});

// Start server
server.listen(PORT, () => {
    console.log(`🕵️  Shadow Hacker Academy server running on port ${PORT}`);
    console.log(`🌐 Access the game at: http://localhost:${PORT}`);
    console.log(`📊 Stats endpoint: http://localhost:${PORT}/api/stats`);
    
    // Create public directory if it doesn't exist
    const publicDir = path.join(__dirname, 'public');
    if (!fs.existsSync(publicDir)) {
        fs.mkdirSync(publicDir, { recursive: true });
        console.log('📁 Created public directory');
    }
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down Shadow Hacker Academy...');
    server.close(() => {
        console.log('✅ Server closed');
        process.exit(0);
    });
});

// Auto-save leaderboard periodically
setInterval(() => {
    // In a production environment, you'd want to save to a database
    console.log(`💾 Auto-save: ${globalLeaderboard.length} players, ${activeUsers.size} active`);
}, 300000); // Every 5 minutes
