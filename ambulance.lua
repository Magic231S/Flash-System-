local isPanelOpen = false
local currentPage = 1
local maxPages = 3

-- دالة فتح لوحة التحكم
function OpenAmbulancePanel()
    if not isPanelOpen then
        isPanelOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openAmbulancePanel",
            data = {
                userInfo = GetUserInfo(),
                calls = GetEmergencyCalls(),
                stats = GetAmbulanceStats()
            }
        })
    end
end

-- دالة إغلاق لوحة التحكم
function CloseAmbulancePanel()
    if isPanelOpen then
        isPanelOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closeAmbulancePanel"
        })
    end
end

-- دالة التحقق من الصلاحيات
function HasAmbulanceAccess()
    local userInfo = GetUserInfo()
    return userInfo and (userInfo.package_type == "SUPER" or userInfo.package_type == "MEDIUM")
end

-- استدعاء لوحة التحكم
RegisterCommand("ambulancepanel", function()
    if HasAmbulanceAccess() then
        OpenAmbulancePanel()
    else
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"النظام", "ليس لديك صلاحية للوصول إلى لوحة تحكم الإسعاف"}
        })
    end
end)

-- استدعاء لوحة التحكم من خلال المفتاح
RegisterKeyMapping("ambulancepanel", "فتح لوحة تحكم الإسعاف", "keyboard", "F8")

-- استقبال الأحداث من NUI
RegisterNUICallback("closePanel", function(data, cb)
    CloseAmbulancePanel()
    cb("ok")
end)

RegisterNUICallback("respondToCall", function(data, cb)
    if data.callId then
        RespondToEmergencyCall(data.callId)
        cb({success = true})
    else
        cb({success = false, error = "الرجاء تحديد رقم الطوارئ"})
    end
end)

RegisterNUICallback("updateStats", function(data, cb)
    if data.stats then
        UpdateAmbulanceStats(data.stats)
        cb({success = true})
    else
        cb({success = false, error = "الرجاء إدخال الإحصائيات"})
    end
end)

-- دالة الحصول على معلومات المستخدم
function GetUserInfo()
    local userInfo = exports["fivem_panels"]:GetUserInfo()
    return userInfo
end

-- دالة الحصول على مكالمات الطوارئ
function GetEmergencyCalls()
    local calls = exports["fivem_panels"]:GetEmergencyCalls()
    return calls
end

-- دالة الحصول على إحصائيات الإسعاف
function GetAmbulanceStats()
    local stats = exports["fivem_panels"]:GetAmbulanceStats()
    return stats
end

-- دالة الرد على مكالمة طوارئ
function RespondToEmergencyCall(callId)
    exports["fivem_panels"]:RespondToEmergencyCall(callId)
end

-- دالة تحديث إحصائيات الإسعاف
function UpdateAmbulanceStats(stats)
    exports["fivem_panels"]:UpdateAmbulanceStats(stats)
end 