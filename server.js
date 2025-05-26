require('dotenv').config();
const express = require('express');
const path = require('path');
const session = require('express-session');
const passport = require('passport');
const DiscordStrategy = require('passport-discord').Strategy;
const MySQLStore = require('express-mysql-session')(session);
const bcrypt = require('bcrypt');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const port = 3001;

// إعدادات قاعدة البيانات
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'cfw_db'
};

// إنشاء اتصال قاعدة البيانات
const pool = mysql.createPool(dbConfig);

// إعدادات الجلسة
const sessionStore = new MySQLStore({
    ...dbConfig,
    createDatabaseTable: true
});

app.use(session({
    secret: process.env.SESSION_SECRET || 'your-secret-key',
    store: sessionStore,
    resave: false,
    saveUninitialized: false,
    cookie: {
        secure: process.env.NODE_ENV === 'production',
        maxAge: 24 * 60 * 60 * 1000 // 24 ساعة
    }
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors({
    origin: process.env.CLIENT_URL || 'http://localhost:3000',
    credentials: true
}));

// تسجيل مستخدم جديد
app.post('/api/register', async (req, res) => {
    try {
        const { username, email, password, packageType } = req.body;
        
        // التحقق من وجود المستخدم
        const [existingUsers] = await pool.execute(
            'SELECT * FROM users WHERE username = ? OR email = ?',
            [username, email]
        );

        if (existingUsers.length > 0) {
            return res.status(400).json({ error: 'اسم المستخدم أو البريد الإلكتروني مستخدم بالفعل' });
        }

        // تشفير كلمة المرور
        const hashedPassword = await bcrypt.hash(password, 10);

        // إنشاء المستخدم
        await pool.execute(
            'INSERT INTO users (username, email, password, package_type) VALUES (?, ?, ?, ?)',
            [username, email, hashedPassword, packageType]
        );

        res.status(201).json({ message: 'تم إنشاء الحساب بنجاح' });
    } catch (error) {
        console.error('خطأ في التسجيل:', error);
        res.status(500).json({ error: 'حدث خطأ أثناء التسجيل' });
    }
});

// تسجيل الدخول
app.post('/api/login', async (req, res) => {
    try {
        const { username, password } = req.body;

        // البحث عن المستخدم
        const [users] = await pool.execute(
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

        // تحديث آخر تسجيل دخول
        await pool.execute(
            'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?',
            [user.id]
        );

        // إنشاء جلسة
        req.session.user = {
            id: user.id,
            username: user.username,
            email: user.email,
            packageType: user.package_type
        };

        res.json({
            message: 'تم تسجيل الدخول بنجاح',
            user: req.session.user
        });
    } catch (error) {
        console.error('خطأ في تسجيل الدخول:', error);
        res.status(500).json({ error: 'حدث خطأ أثناء تسجيل الدخول' });
    }
});

// تسجيل الخروج
app.post('/api/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).json({ error: 'حدث خطأ أثناء تسجيل الخروج' });
        }
        res.json({ message: 'تم تسجيل الخروج بنجاح' });
    });
});

// التحقق من حالة الجلسة
app.get('/api/check-auth', (req, res) => {
    if (req.session.user) {
        res.json({ user: req.session.user });
    } else {
        res.status(401).json({ error: 'غير مصرح' });
    }
});

// تقديم الملفات الثابتة من مجلد website
app.use(express.static(path.join(__dirname)));

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
