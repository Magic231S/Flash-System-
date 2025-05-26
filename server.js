require('dotenv').config();
const express = require('express');
const path = require('path');
const session = require('express-session');
const passport = require('passport');
const DiscordStrategy = require('passport-discord').Strategy;

const app = express();
const port = 3001;

app.use(session({
    secret: process.env.SESSION_SECRET || 'secret',
    resave: false,
    saveUninitialized: false
}));
app.use(passport.initialize());
app.use(passport.session());

passport.serializeUser((user, done) => {
    done(null, user);
});
passport.deserializeUser((obj, done) => {
    done(null, obj);
});

// Discord OAuth فقط
passport.use(new DiscordStrategy({
    clientID: process.env.DISCORD_CLIENT_ID,
    clientSecret: process.env.DISCORD_CLIENT_SECRET,
    callbackURL: process.env.DISCORD_CALLBACK_URL,
    scope: ['identify', 'email']
}, (accessToken, refreshToken, profile, done) => {
    return done(null, profile);
}));

// نقاط نهاية Discord
app.get('/auth/discord', passport.authenticate('discord'));
app.get('/auth/discord/callback', passport.authenticate('discord', {
    failureRedirect: '/login.html'
}), (req, res) => {
    // نجاح المصادقة
    res.send(`<script>window.opener.postMessage({type:'oauth', provider:'discord', user:${JSON.stringify(req.user)}}, '*');window.close();</script>`);
});

// تقديم الملفات الثابتة من مجلد website
app.use(express.static(path.join(__dirname)));

// توجيه جميع الطلبات إلى index.html
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(port, () => {
    console.log(`OAuth الموقع يعمل على العنوان: http://localhost:${port}`);
});