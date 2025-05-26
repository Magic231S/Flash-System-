local isPanelOpen = false
local currentPage = 1
local maxPages = 3

-- دالة فتح لوحة التحكم
function OpenMilitaryPanel()
    if not isPanelOpen then
        isPanelOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openMilitaryPanel",
            data = {
                userInfo = GetUserInfo(),
                reports = GetReports(),
                points = GetInteractionPoints()
            }
        })
    end
end

-- دالة إغلاق لوحة التحكم
function CloseMilitaryPanel()
    if isPanelOpen then
        isPanelOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closeMilitaryPanel"
        })
    end
end

-- دالة التحقق من الصلاحيات
function HasMilitaryAccess()
    local userInfo = GetUserInfo()
    return userInfo and (userInfo.package_type == "SUPER" or userInfo.package_type == "MEDIUM")
end

-- استدعاء لوحة التحكم
RegisterCommand("militarypanel", function()
    if HasMilitaryAccess() then
        OpenMilitaryPanel()
    else
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"النظام", "ليس لديك صلاحية للوصول إلى لوحة التحكم العسكرية"}
        })
    end
end)

-- استدعاء لوحة التحكم من خلال المفتاح
RegisterKeyMapping("militarypanel", "فتح لوحة التحكم العسكرية", "keyboard", "F7")

-- استقبال الأحداث من NUI
RegisterNUICallback("closePanel", function(data, cb)
    CloseMilitaryPanel()
    cb("ok")
end)

RegisterNUICallback("submitReport", function(data, cb)
    if data.report then
        CreateReport(data.report)
        cb({success = true})
    else
        cb({success = false, error = "الرجاء إدخال التقرير"})
    end
end)

RegisterNUICallback("updatePoints", function(data, cb)
    if data.points then
        AddInteractionPoints(data.points)
        cb({success = true})
    else
        cb({success = false, error = "الرجاء إدخال النقاط"})
    end
end)

-- دالة الحصول على معلومات المستخدم
function GetUserInfo()
    local userInfo = exports["fivem_panels"]:GetUserInfo()
    return userInfo
end

-- دالة الحصول على التقارير
function GetReports()
    local reports = exports["fivem_panels"]:GetReports()
    return reports
end

-- دالة الحصول على نقاط التفاعل
function GetInteractionPoints()
    local points = exports["fivem_panels"]:GetInteractionPoints()
    return points
end 