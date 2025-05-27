// محاولة تحميل متغيرات البيئة
try {
    require('dotenv').config();
} catch (error) {
    console.log('ملف .env غير موجود، سيتم استخدام القيم الافتراضية');
}

const express = require('express');
const path = require('path');
const session = require('express-session');
const MySQLStore = require('express-mysql-session')(session);
const bcrypt = require('bcrypt');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

// إعدادات الأمان
app.use((req, res, next) => {
    // منع الوصول من مصادر غير مصرح بها
    const allowedOrigins = ['https://flash-system-7f1c.onrender.com', 'http://localhost:3000'];
    const origin = req.headers.origin;
    if (allowedOrigins.includes(origin)) {
        res.setHeader('Access-Control-Allow-Origin', origin);
    }
    
    // منع هجمات XSS
    res.setHeader('X-XSS-Protection', '1; mode=block');
    
    // منع هجمات Clickjacking
    res.setHeader('X-Frame-Options', 'DENY');
    
    // منع هجمات MIME-type
    res.setHeader('X-Content-Type-Options', 'nosniff');
    
    // منع هجمات CSRF
    res.setHeader('X-CSRF-Protection', '1');
    
    next();
});

// تكوين قاعدة البيانات
const db = mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'cfw_db',
    port: process.env.DB_PORT || 3306,
    ssl: process.env.NODE_ENV === 'production' ? {
        rejectUnauthorized: true
    } : false
});

// التحقق من الاتصال بقاعدة البيانات
db.connect((err) => {
    if (err) {
        console.error('خطأ في الاتصال بقاعدة البيانات:', err);
        // لا نقوم بإيقاف التطبيق، بل نحاول إعادة الاتصال
        setTimeout(() => {
            console.log('محاولة إعادة الاتصال بقاعدة البيانات...');
            db.connect();
        }, 5000);
        return;
    }
    console.log('تم الاتصال بقاعدة البيانات بنجاح');
});

// معالجة أخطاء الاتصال
db.on('error', (err) => {
    console.error('خطأ في قاعدة البيانات:', err);
    if (err.code === 'PROTOCOL_CONNECTION_LOST' || err.code === 'ECONNREFUSED') {
        console.log('إعادة الاتصال بقاعدة البيانات...');
        db.connect();
    } else {
        throw err;
    }
});

// تكوين جلسة MySQL
const sessionStore = new MySQLStore({
    expiration: 86400000, // 24 ساعة
    createDatabaseTable: true,
    schema: {
        tableName: 'sessions',
        columnNames: {
            session_id: 'session_id',
            expires: 'expires',
            data: 'data'
        }
    }
}, db);

// تكوين الجلسات
app.use(session({
    key: 'session_cookie_name',
    secret: process.env.SESSION_SECRET || 'session_cookie_secret',
    store: sessionStore,
    resave: false,
    saveUninitialized: false,
    cookie: {
        secure: process.env.NODE_ENV === 'production',
        httpOnly: true,
        maxAge: 24 * 60 * 60 * 1000, // 24 ساعة
        sameSite: 'strict'
    }
}));

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname)));

// تسجيل مستخدم جديد
app.post('/api/register', async (req, res) => {
    try {
        console.log('بدء عملية التسجيل...');
        const { username, email, password, packageType } = req.body;
        console.log('البيانات المستلمة:', { username, email, packageType });

        if (!username || !email || !password || !packageType) {
            console.log('بيانات ناقصة');
            return res.status(400).json({ error: 'جميع الحقول مطلوبة' });
        }

        // التحقق من صحة البريد الإلكتروني
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            console.log('البريد الإلكتروني غير صالح');
            return res.status(400).json({ error: 'البريد الإلكتروني غير صالح' });
        }

        // التحقق من طول كلمة المرور
        if (password.length < 6) {
            console.log('كلمة المرور قصيرة جداً');
            return res.status(400).json({ error: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' });
        }

        console.log('التحقق من وجود المستخدم...');
        // التحقق من وجود المستخدم
        const [existingUsers] = await db.promise().query(
            'SELECT * FROM users WHERE username = ? OR email = ?',
            [username, email]
        );

        if (existingUsers.length > 0) {
            console.log('المستخدم موجود بالفعل');
            return res.status(400).json({ error: 'اسم المستخدم أو البريد الإلكتروني مستخدم بالفعل' });
        }

        console.log('تشفير كلمة المرور...');
        // تشفير كلمة المرور
        const hashedPassword = await bcrypt.hash(password, 10);

        console.log('إدخال المستخدم الجديد...');
        // إدخال المستخدم الجديد
        await db.promise().query(
            'INSERT INTO users (username, email, password, package_type) VALUES (?, ?, ?, ?)',
            [username, email, hashedPassword, packageType]
        );

        console.log('تم إنشاء الحساب بنجاح');
        res.status(201).json({ message: 'تم إنشاء الحساب بنجاح' });
    } catch (error) {
        console.error('خطأ في التسجيل:', error);
        res.status(500).json({ 
            error: 'حدث خطأ أثناء إنشاء الحساب',
            details: error.message 
        });
    }
});

// تسجيل الدخول
app.post('/api/login', async (req, res) => {
    try {
        console.log('بدء عملية تسجيل الدخول...');
        const { username, password } = req.body;
        console.log('محاولة تسجيل دخول:', username);

        if (!username || !password) {
            console.log('بيانات تسجيل الدخول ناقصة');
            return res.status(400).json({ error: 'اسم المستخدم وكلمة المرور مطلوبان' });
        }

        console.log('البحث عن المستخدم...');
        // البحث عن المستخدم
        const [users] = await db.promise().query(
            'SELECT * FROM users WHERE username = ?',
            [username]
        );

        if (users.length === 0) {
            console.log('المستخدم غير موجود');
            return res.status(401).json({ error: 'اسم المستخدم أو كلمة المرور غير صحيحة' });
        }

        const user = users[0];
        console.log('التحقق من كلمة المرور...');

        // التحقق من كلمة المرور
        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) {
            console.log('كلمة المرور غير صحيحة');
            return res.status(401).json({ error: 'اسم المستخدم أو كلمة المرور غير صحيحة' });
        }

        console.log('إنشاء الجلسة...');
        // إنشاء جلسة
        req.session.userId = user.id;
        req.session.username = user.username;
        req.session.packageType = user.package_type;

        console.log('تم تسجيل الدخول بنجاح');
        res.json({ 
            message: 'تم تسجيل الدخول بنجاح',
            user: {
                username: user.username,
                packageType: user.package_type
            }
        });
    } catch (error) {
        console.error('خطأ في تسجيل الدخول:', error);
        res.status(500).json({ 
            error: 'حدث خطأ أثناء تسجيل الدخول',
            details: error.message 
        });
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

app.listen(port, () => {
    console.log(`الخادم يعمل على المنفذ ${port}`);
});
