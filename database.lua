local MySQL = exports['oxmysql']

-- دالة التحقق من وجود المستخدم
function CheckUserExists(discordId)
    local result = MySQL:executeSync('SELECT * FROM users WHERE discord_id = ?', {discordId})
    return result and #result > 0
end

-- دالة إنشاء مستخدم جديد
function CreateUser(discordId, username, packageType)
    MySQL:execute('INSERT INTO users (discord_id, username, package_type) VALUES (?, ?, ?)',
        {discordId, username, packageType})
end

-- دالة تحديث معلومات المستخدم
function UpdateUser(discordId, username, packageType)
    MySQL:execute('UPDATE users SET username = ?, package_type = ? WHERE discord_id = ?',
        {username, packageType, discordId})
end

-- دالة الحصول على معلومات المستخدم
function GetUserInfo(discordId)
    local result = MySQL:executeSync('SELECT * FROM users WHERE discord_id = ?', {discordId})
    return result and result[1]
end

-- دالة إنشاء كود تفعيل جديد
function CreateActivationCode(userId)
    local code = GenerateRandomCode()
    MySQL:execute('INSERT INTO activations (user_id, activation_code) VALUES (?, ?)',
        {userId, code})
    return code
end

-- دالة التحقق من كود التفعيل
function VerifyActivationCode(code)
    local result = MySQL:executeSync('SELECT * FROM activations WHERE activation_code = ? AND status = "pending"', {code})
    return result and result[1]
end

-- دالة تحديث حالة التفعيل
function UpdateActivationStatus(code, status)
    MySQL:execute('UPDATE activations SET status = ?, completed_at = CURRENT_TIMESTAMP WHERE activation_code = ?',
        {status, code})
end

-- دالة إضافة نقاط تفاعل
function AddInteractionPoints(userId, points)
    MySQL:execute('INSERT INTO interaction_points (user_id, points) VALUES (?, ?) ON DUPLICATE KEY UPDATE points = points + ?',
        {userId, points, points})
end

-- دالة الحصول على نقاط التفاعل
function GetInteractionPoints(userId)
    local result = MySQL:executeSync('SELECT points FROM interaction_points WHERE user_id = ?', {userId})
    return result and result[1] and result[1].points or 0
end

-- دالة إنشاء تقرير جديد
function CreateReport(reporterId, reportedId, reason)
    MySQL:execute('INSERT INTO reports (reporter_id, reported_id, reason) VALUES (?, ?, ?)',
        {reporterId, reportedId, reason})
end

-- دالة تحديث حالة التقرير
function UpdateReportStatus(reportId, status)
    MySQL:execute('UPDATE reports SET status = ?, resolved_at = CURRENT_TIMESTAMP WHERE id = ?',
        {status, reportId})
end

-- دالة مساعدة لإنشاء كود عشوائي
function GenerateRandomCode()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local code = ""
    for i = 1, 8 do
        local rand = math.random(1, #chars)
        code = code .. string.sub(chars, rand, rand)
    end
    return code
end

-- تصدير الدوال
exports('CheckUserExists', CheckUserExists)
exports('CreateUser', CreateUser)
exports('UpdateUser', UpdateUser)
exports('GetUserInfo', GetUserInfo)
exports('CreateActivationCode', CreateActivationCode)
exports('VerifyActivationCode', VerifyActivationCode)
exports('UpdateActivationStatus', UpdateActivationStatus)
exports('AddInteractionPoints', AddInteractionPoints)
exports('GetInteractionPoints', GetInteractionPoints)
exports('CreateReport', CreateReport)
exports('UpdateReportStatus', UpdateReportStatus) 