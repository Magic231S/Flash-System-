require('dotenv').config();
const express = require('express');
const path = require('path');
const session = require('express-session');
const passport = require('passport');
const DiscordStrategy = require('passport-discord').Strategy;
const MySQLStore = require('express-mysql-session')(session);
const bcrypt = require('bcrypt');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const port = 3000;

// تكوين قاعدة البيانات
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'cfw_db'
});

// تكوين جلسة MySQL
const sessionStore = new MySQLStore({
    expiration: 86400000, // 24 ساعة
    createDatabaseTable: true
}, db);

// تكوين الجلسات
app.use(session({
    key: 'session_cookie_name',
    secret: 'session_cookie_secret',
    store: sessionStore,
    resave: false,
    saveUninitialized: false
}));

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname)));

// تسجيل مستخدم جديد
app.post('/api/register', async (req, res) => {
    try {
        const { username, email, password, packageType } = req.body;

        // التحقق من وجود المستخدم
        const [existingUsers] = await db.promise().query(
            'SELECT * FROM users WHERE username = ? OR email = ?',
            [username, email]
        );

        if (existingUsers.length > 0) {
            return res.status(400).json({ error: 'اسم المستخدم أو البريد الإلكتروني مستخدم بالفعل' });
        }

        // تشفير كلمة المرور
        const hashedPassword = await bcrypt.hash(password, 10);

        // إدخال المستخدم الجديد
        await db.promise().query(
            'INSERT INTO users (username, email, password, package_type) VALUES (?, ?, ?, ?)',
            [username, email, hashedPassword, packageType]
        );

        res.status(201).json({ message: 'تم إنشاء الحساب بنجاح' });
    } catch (error) {
        console.error('خطأ في التسجيل:', error);
        res.status(500).json({ error: 'حدث خطأ أثناء إنشاء الحساب' });
    }
});

// تسجيل الدخول
app.post('/api/login', async (req, res) => {
    try {
        const { username, password } = req.body;

        // البحث عن المستخدم
        const [users] = await db.promise().query(
            'SELECT * FROM users WHERE username = ?',
            [username]
        );

        if (users.length === 0) {
            return res.status(401).json({ error: 'اسم المستخدم أو كلمة المرور غير صحيحة' });
        }

        const user = users[0];

        // التحقق من كلمة المرور
        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) {
            return res.status(401).json({ error: 'اسم المستخدم أو كلمة المرور غير صحيحة' });
        }

        // إنشاء جلسة
        req.session.userId = user.id;
        req.session.username = user.username;
        req.session.packageType = user.package_type;

        res.json({ message: 'تم تسجيل الدخول بنجاح' });
    } catch (error) {
        console.error('خطأ في تسجيل الدخول:', error);
        res.status(500).json({ error: 'حدث خطأ أثناء تسجيل الدخول' });
    }
});

// التحقق من حالة تسجيل الدخول
app.get('/api/check-auth', (req, res) => {
    if (req.session.userId) {
        res.json({
            isAuthenticated: true,
            username: req.session.username,
            packageType: req.session.packageType
        });
    } else {
        res.json({ isAuthenticated: false });
    }
});

// تسجيل الخروج
app.post('/api/logout', (req, res) => {
    req.session.destroy();
    res.json({ message: 'تم تسجيل الخروج بنجاح' });
});

// توجيه جميع الطلبات إلى index.html
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// نقاط نهاية Discord
app.get('/auth/discord', passport.authenticate('discord'));
app.get('/auth/discord/callback', passport.authenticate('discord', {
    failureRedirect: '/login.html'
}), (req, res) => {
    // نجاح المصادقة
    res.send(`<script>window.opener.postMessage({type:'oauth', provider:'discord', user:${JSON.stringify(req.user)}}, '*');window.close();</script>`);
});

app.listen(port, () => {
    console.log(`الخادم يعمل على المنفذ ${port}`);
});
