Config = {}

-- إعدادات الباقات
Config.Packages = {
    SUPER = {
        price = 20,
        features = {
            militaryPanel = true,
            ambulancePanel = true,
            justicePanel = true,
            adminPanel = true,
            itemDetector = true,
            interactionPoints = true,
            electronicTest = true,
            activationSystem = true,
            reportsSystem = true,
            queuePriority = true
        },
        websitePages = {
            home = true,
            rules = true,
            applications = true,
            contentCreators = true,
            broadcasts = true,
            interactors = true,
            customPage = true
        }
    },
    MEDIUM = {
        price = 15,
        features = {
            militaryPanel = true,
            ambulancePanel = true,
            justicePanel = true,
            adminPanel = true,
            itemDetector = true,
            interactionPoints = true,
            electronicTest = true
        },
        websitePages = {
            home = true,
            rules = true,
            applications = true,
            contentCreators = true,
            broadcasts = true,
            interactors = true
        }
    },
    NORMAL = {
        price = 10,
        features = {
            militaryPanel = true,
            adminPanel = true,
            interactionPoints = true
        },
        websitePages = {
            home = true,
            rules = true,
            contentCreators = true,
            broadcasts = true,
            interactors = true
        }
    }
}

-- إعدادات Discord
Config.Discord = {
    botToken = "YOUR_BOT_TOKEN",
    guildId = "YOUR_GUILD_ID",
    roles = {
        admin = "ADMIN_ROLE_ID",
        military = "MILITARY_ROLE_ID",
        ambulance = "AMBULANCE_ROLE_ID",
        justice = "JUSTICE_ROLE_ID"
    }
}

-- إعدادات قاعدة البيانات
Config.Database = {
    host = "localhost",
    user = "root",
    password = "",
    database = "fivem_panels"
}

-- إعدادات الموقع
Config.Website = {
    port = 3000,
    sessionSecret = "YOUR_SESSION_SECRET",
    apiKey = "YOUR_API_KEY"
} 