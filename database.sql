CREATE DATABASE IF NOT EXISTS fivem_panels;
USE fivem_panels;

-- جدول المستخدمين
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    package_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- جدول التفعيلات
CREATE TABLE IF NOT EXISTS activations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    activation_code VARCHAR(255) NOT NULL,
    status ENUM('pending', 'completed', 'expired') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- جدول التقارير
CREATE TABLE IF NOT EXISTS reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reporter_id INT NOT NULL,
    reported_id INT NOT NULL,
    reason TEXT NOT NULL,
    status ENUM('pending', 'resolved', 'rejected') DEFAULT 'pending',
    admin_id INT,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    FOREIGN KEY (reporter_id) REFERENCES users(id),
    FOREIGN KEY (reported_id) REFERENCES users(id),
    FOREIGN KEY (admin_id) REFERENCES users(id)
);

-- جدول نقاط التفاعل
CREATE TABLE IF NOT EXISTS interaction_points (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    points INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- جدول الاختبارات الإلكترونية
CREATE TABLE IF NOT EXISTS electronic_tests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    score INT NOT NULL,
    passed BOOLEAN DEFAULT FALSE,
    taken_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- جدول سجل التفعيل
CREATE TABLE IF NOT EXISTS activation_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action_type ENUM('activation', 'deactivation', 'renewal') NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- جدول مكالمات الطوارئ
CREATE TABLE IF NOT EXISTS emergency_calls (
    id INT AUTO_INCREMENT PRIMARY KEY,
    caller_id INT NOT NULL,
    location VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    responder_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (caller_id) REFERENCES users(id),
    FOREIGN KEY (responder_id) REFERENCES users(id)
);

-- جدول إحصائيات الإسعاف
CREATE TABLE IF NOT EXISTS ambulance_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    date DATE NOT NULL,
    calls_responded INT DEFAULT 0,
    response_time INT DEFAULT 0,
    patients_treated INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY unique_user_date (user_id, date)
);

-- جدول سجل المرضى
CREATE TABLE IF NOT EXISTS patient_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    ambulance_id INT NOT NULL,
    treatment_type VARCHAR(255) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES users(id),
    FOREIGN KEY (ambulance_id) REFERENCES users(id)
);

-- جدول القضايا
CREATE TABLE IF NOT EXISTS cases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    defendant_id INT NOT NULL,
    prosecutor_id INT NOT NULL,
    charge TEXT NOT NULL,
    status ENUM('pending', 'in_progress', 'closed', 'dismissed') DEFAULT 'pending',
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP NULL,
    verdict TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (defendant_id) REFERENCES users(id),
    FOREIGN KEY (prosecutor_id) REFERENCES users(id)
);

-- جدول مذكرات التوقيف
CREATE TABLE IF NOT EXISTS warrants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    suspect_id INT NOT NULL,
    issuer_id INT NOT NULL,
    reason TEXT NOT NULL,
    status ENUM('active', 'executed', 'expired', 'cancelled') DEFAULT 'active',
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    execution_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (suspect_id) REFERENCES users(id),
    FOREIGN KEY (issuer_id) REFERENCES users(id)
);

-- جدول إحصائيات وزارة العدل
CREATE TABLE IF NOT EXISTS justice_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    date DATE NOT NULL,
    cases_handled INT DEFAULT 0,
    warrants_issued INT DEFAULT 0,
    cases_closed INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY unique_user_date (user_id, date)
);

-- جدول سجل القضايا
CREATE TABLE IF NOT EXISTS case_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT NOT NULL,
    user_id INT NOT NULL,
    action_type ENUM('create', 'update', 'close', 'dismiss') NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- جدول إعدادات النظام
CREATE TABLE IF NOT EXISTS system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(50) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    updated_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- جدول سجلات النظام
CREATE TABLE IF NOT EXISTS system_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action_type VARCHAR(50) NOT NULL,
    action_details TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- جدول إحصائيات النظام
CREATE TABLE IF NOT EXISTS system_stats (
    id INT PRIMARY KEY AUTO_INCREMENT,
    stat_date DATE NOT NULL,
    total_users INT DEFAULT 0,
    active_users INT DEFAULT 0,
    total_reports INT DEFAULT 0,
    resolved_reports INT DEFAULT 0,
    total_cases INT DEFAULT 0,
    total_warrants INT DEFAULT 0,
    total_emergency_calls INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_date (stat_date)
); 
