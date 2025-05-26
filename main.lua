local isPanelOpen = false

-- فتح لوحة التحكم
RegisterCommand('panel', function()
    if not isPanelOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openPanel",
            data = {
                username = GetPlayerName(PlayerId()),
                rank = "مدير",
                serverName = "اسم السيرفر"
            }
        })
        isPanelOpen = true
    end
end)

-- إغلاق لوحة التحكم
RegisterNUICallback('closePanel', function(data, cb)
    SetNuiFocus(false, false)
    isPanelOpen = false
    cb('ok')
end)

-- معالجة الأوامر من لوحة التحكم
RegisterNUICallback('executeCommand', function(data, cb)
    ExecuteCommand(data.command)
    cb('ok')
end)

-- تحديث معلومات اللاعب
RegisterNUICallback('updatePlayerInfo', function(data, cb)
    -- هنا يمكنك إضافة كود لتحديث معلومات اللاعب في قاعدة البيانات
    cb('ok')
end)

RegisterCommand('login', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "showLogin" })
end)

RegisterCommand('register', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "showRegister" })
end)

RegisterNUICallback('login', function(data, cb)
    -- تحقق من البيانات (مثال فقط)
    if data.username == 'admin' and data.password == '1234' then
        cb({ success = true, message = 'تم تسجيل الدخول بنجاح!' })
        SendNUIMessage({ type = "openPanel", data = { username = data.username, rank = "مدير", serverName = "اسم السيرفر" } })
    else
        cb({ success = false, message = 'بيانات الدخول غير صحيحة!' })
    end
end)

RegisterNUICallback('register', function(data, cb)
    -- تحقق من البيانات (مثال فقط)
    if data.username ~= '' and data.password ~= '' and data.email ~= '' then
        cb({ success = true, message = 'تم إنشاء الحساب بنجاح! يمكنك تسجيل الدخول الآن.' })
        SendNUIMessage({ type = "showLogin" })
    else
        cb({ success = false, message = 'يرجى تعبئة جميع الحقول.' })
    end
end) 