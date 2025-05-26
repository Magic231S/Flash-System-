local isPanelOpen = false
local currentPage = 1
local maxPages = 3

-- دالة فتح لوحة التحكم
function OpenAdminPanel()
    if not isPanelOpen then
        isPanelOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openAdminPanel",
            data = {
                users = GetAllUsers(),
                reports = GetPendingReports(),
                settings = GetSystemSettings(),
                logs = GetSystemLogs(),
                stats = GetSystemStats()
            }
        })
    end
end

-- دالة إغلاق لوحة التحكم
function CloseAdminPanel()
    if isPanelOpen then
        isPanelOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closeAdminPanel"
        })
    end
end

-- دالة التحقق من الصلاحيات
function HasAdminAccess()
    local userInfo = GetUserInfo()
    return userInfo and userInfo.package_type == "SUPER"
end

-- استدعاء لوحة التحكم
RegisterCommand("adminpanel", function()
    if HasAdminAccess() then
        OpenAdminPanel()
    else
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"النظام", "ليس لديك صلاحية للوصول إلى لوحة تحكم الإدارة"}
        })
    end
end)

-- استدعاء لوحة التحكم من خلال المفتاح
RegisterKeyMapping("adminpanel", "فتح لوحة تحكم الإدارة", "keyboard", "F6")

-- استقبال الأحداث من NUI
RegisterNUICallback("closePanel", function(data, cb)
    CloseAdminPanel()
    cb("ok")
end)

RegisterNUICallback("getUserDetails", function(data, cb)
    if data.userId then
        local userDetails = GetUserDetails(data.userId)
        cb({success = true, user = userDetails})
    else
        cb({success = false, error = "الرجاء تحديد رقم المستخدم"})
    end
end)

RegisterNUICallback("getReportDetails", function(data, cb)
    if data.reportId then
        local reportDetails = GetReportDetails(data.reportId)
        cb({success = true, report = reportDetails})
    else
        cb({success = false, error = "الرجاء تحديد رقم التقرير"})
    end
end)

RegisterNUICallback("addUser", function(data, cb)
    if data.username and data.packageType then
        local success = AddNewUser(data.username, data.packageType)
        if success then
            cb({success = true})
        else
            cb({success = false, error = "حدث خطأ أثناء إضافة المستخدم"})
        end
    else
        cb({success = false, error = "الرجاء إدخال جميع البيانات المطلوبة"})
    end
end)

RegisterNUICallback("updateSettings", function(data, cb)
    if data.serverName and data.maxUsers and data.maintenanceMode then
        local success = UpdateSystemSettings(data)
        if success then
            cb({success = true})
        else
            cb({success = false, error = "حدث خطأ أثناء تحديث الإعدادات"})
        end
    else
        cb({success = false, error = "الرجاء إدخال جميع البيانات المطلوبة"})
    end
end)

RegisterNUICallback("filterLogs", function(data, cb)
    if data.logType then
        local logs = GetFilteredLogs(data.logType)
        cb({success = true, logs = logs})
    else
        cb({success = false, error = "الرجاء تحديد نوع السجلات"})
    end
end)

-- دالة الحصول على معلومات المستخدم
function GetUserInfo()
    local userInfo = exports["fivem_panels"]:GetUserInfo()
    return userInfo
end

-- دالة الحصول على جميع المستخدمين
function GetAllUsers()
    local users = exports["fivem_panels"]:GetAllUsers()
    return users
end

-- دالة الحصول على التقارير المعلقة
function GetPendingReports()
    local reports = exports["fivem_panels"]:GetPendingReports()
    return reports
end

-- دالة الحصول على إعدادات النظام
function GetSystemSettings()
    local settings = exports["fivem_panels"]:GetSystemSettings()
    return settings
end

-- دالة الحصول على سجلات النظام
function GetSystemLogs()
    local logs = exports["fivem_panels"]:GetSystemLogs()
    return logs
end

-- دالة الحصول على إحصائيات النظام
function GetSystemStats()
    local stats = exports["fivem_panels"]:GetSystemStats()
    return stats
end

-- دالة الحصول على تفاصيل المستخدم
function GetUserDetails(userId)
    local userDetails = exports["fivem_panels"]:GetUserDetails(userId)
    return userDetails
end

-- دالة الحصول على تفاصيل التقرير
function GetReportDetails(reportId)
    local reportDetails = exports["fivem_panels"]:GetReportDetails(reportId)
    return reportDetails
end

-- دالة إضافة مستخدم جديد
function AddNewUser(username, packageType)
    local success = exports["fivem_panels"]:AddNewUser(username, packageType)
    return success
end

-- دالة تحديث إعدادات النظام
function UpdateSystemSettings(settings)
    local success = exports["fivem_panels"]:UpdateSystemSettings(settings)
    return success
end

-- دالة الحصول على السجلات المصفاة
function GetFilteredLogs(logType)
    local logs = exports["fivem_panels"]:GetFilteredLogs(logType)
    return logs
end 