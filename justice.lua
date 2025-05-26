local isPanelOpen = false
local currentPage = 1
local maxPages = 3

-- دالة فتح لوحة التحكم
function OpenJusticePanel()
    if not isPanelOpen then
        isPanelOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openJusticePanel",
            data = {
                userInfo = GetUserInfo(),
                cases = GetActiveCases(),
                warrants = GetActiveWarrants(),
                stats = GetJusticeStats()
            }
        })
    end
end

-- دالة إغلاق لوحة التحكم
function CloseJusticePanel()
    if isPanelOpen then
        isPanelOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closeJusticePanel"
        })
    end
end

-- دالة التحقق من الصلاحيات
function HasJusticeAccess()
    local userInfo = GetUserInfo()
    return userInfo and (userInfo.package_type == "SUPER" or userInfo.package_type == "MEDIUM")
end

-- استدعاء لوحة التحكم
RegisterCommand("justicepanel", function()
    if HasJusticeAccess() then
        OpenJusticePanel()
    else
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"النظام", "ليس لديك صلاحية للوصول إلى لوحة تحكم وزارة العدل"}
        })
    end
end)

-- استدعاء لوحة التحكم من خلال المفتاح
RegisterKeyMapping("justicepanel", "فتح لوحة تحكم وزارة العدل", "keyboard", "F7")

-- استقبال الأحداث من NUI
RegisterNUICallback("closePanel", function(data, cb)
    CloseJusticePanel()
    cb("ok")
end)

RegisterNUICallback("getCaseDetails", function(data, cb)
    if data.caseId then
        local caseDetails = GetCaseDetails(data.caseId)
        cb({success = true, case = caseDetails})
    else
        cb({success = false, error = "الرجاء تحديد رقم القضية"})
    end
end)

RegisterNUICallback("getWarrantDetails", function(data, cb)
    if data.warrantId then
        local warrantDetails = GetWarrantDetails(data.warrantId)
        cb({success = true, warrant = warrantDetails})
    else
        cb({success = false, error = "الرجاء تحديد رقم مذكرة التوقيف"})
    end
end)

RegisterNUICallback("issueWarrant", function(data, cb)
    if data.suspectName and data.warrantReason then
        local success = IssueWarrant(data.suspectName, data.warrantReason)
        if success then
            cb({success = true})
        else
            cb({success = false, error = "حدث خطأ أثناء إصدار مذكرة التوقيف"})
        end
    else
        cb({success = false, error = "الرجاء إدخال جميع البيانات المطلوبة"})
    end
end)

-- دالة الحصول على معلومات المستخدم
function GetUserInfo()
    local userInfo = exports["fivem_panels"]:GetUserInfo()
    return userInfo
end

-- دالة الحصول على القضايا النشطة
function GetActiveCases()
    local cases = exports["fivem_panels"]:GetActiveCases()
    return cases
end

-- دالة الحصول على مذكرات التوقيف النشطة
function GetActiveWarrants()
    local warrants = exports["fivem_panels"]:GetActiveWarrants()
    return warrants
end

-- دالة الحصول على إحصائيات وزارة العدل
function GetJusticeStats()
    local stats = exports["fivem_panels"]:GetJusticeStats()
    return stats
end

-- دالة الحصول على تفاصيل قضية
function GetCaseDetails(caseId)
    local caseDetails = exports["fivem_panels"]:GetCaseDetails(caseId)
    return caseDetails
end

-- دالة الحصول على تفاصيل مذكرة توقيف
function GetWarrantDetails(warrantId)
    local warrantDetails = exports["fivem_panels"]:GetWarrantDetails(warrantId)
    return warrantDetails
end

-- دالة إصدار مذكرة توقيف جديدة
function IssueWarrant(suspectName, reason)
    local success = exports["fivem_panels"]:IssueWarrant(suspectName, reason)
    return success
end 