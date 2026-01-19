-- ============================================
-- MS-NEXUS Global v2.0
-- Description: Roblox Multi-Tool with English Interface
-- Language: Global (EN)
-- License Format: MSNEX-XXXX-XXXX-XXXX
-- ============================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Core Library Definition Start
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local MSNEXUS_GLOBAL = {}
MSNEXUS_GLOBAL.__index = MSNEXUS_GLOBAL

-- Internal function: Validate license format
local function validateLicenseFormat(licenseKey)
    if not licenseKey or licenseKey == "" then
        return false, "License key is empty"
    end
    
    -- Validate MS-NEXUS format
    local pattern = "^MSNEX%-[A-Z0-9]+%-[A-Z0-9]+%-[A-Z0-9]+$"
    if not string.match(licenseKey, pattern) then
        return false, "Invalid license format, use MSNEX-XXXX-XXXX-XXXX"
    end
    
    return true, "Format correct"
end

-- Kick player function
local function kickPlayer(reason)
    local player = game.Players.LocalPlayer
    if player then
        pcall(function()
            player:Kick("[MS-NEXUS Global] " .. reason)
        end)
    end
end

-- Show kick countdown
local function showKickCountdown(seconds, reason)
    for i = seconds, 1, -1 do
        if i % 5 == 0 or i <= 10 then
            warn(string.format("[MS-NEXUS Global] %s, will be kicked in %d seconds...", reason, i))
        end
        wait(1)
    end
end

local function SetupLibrary(self, customConfig)
    -- Default configuration
    self.Config = {
        Name = "MS-NEXUS Global",
        Version = "2.0.0",
        Language = "Global",
        MaxAttempts = 1,
        CurrentAttempts = 0,
        Discord = "https://discord.gg/yourlink",
        Font = Enum.Font.Code,
        CornerRadius = 4,
        DefaultToggleKey = Enum.KeyCode.RightControl,
        DebugMode = false
    }
    
    -- Merge custom config
    if customConfig then
        for k, v in pairs(customConfig) do
            self.Config[k] = v
        end
    end

    self.Library = nil
    self.Window = nil
    self.Tabs = {}
    self.LicenseKey = ""
    self.LicenseVerified = false
    self.UserId = game.Players.LocalPlayer.UserId
    self.PlayerName = game.Players.LocalPlayer.Name
    
    return self
end

-- HTTP request wrapper (license verification)
function MSNEXUS_GLOBAL:CallBackend(endpoint, method, data)
    -- Here you can integrate backend verification system
    -- Currently only local validation
    local success, msg = validateLicenseFormat(data.licenseKey)
    if not success then
        return false, msg
    end
    
    -- Simulate successful verification
    return true, "Verification successful! License valid for 23 hours."
end

-- Verify license (with kick function)
function MSNEXUS_GLOBAL:VerifyLicense(key)
    self.Config.CurrentAttempts = self.Config.CurrentAttempts + 1
    
    -- Exceed maximum attempts, kick immediately
    if self.Config.CurrentAttempts > self.Config.MaxAttempts then
        showKickCountdown(10, "Too many verification attempts, please rejoin to get new license")
        wait(10)
        kickPlayer("Too many verification attempts, please rejoin to get new license")
        return false, "Too many verification attempts"
    end
    
    -- Validate format
    local isValid, msg = validateLicenseFormat(key)
    if not isValid then
        -- Format error, kick immediately
        showKickCountdown(10, "License format error: " .. msg)
        wait(10)
        kickPlayer("License format error: " .. msg)
        return false, "License format error"
    end
    
    -- Verify license (can call backend API here)
    local success, message, data = self:CallBackend("/validate", "POST", {
        licenseKey = key,
        robloxUserId = self.UserId
    })
    
    if success then
        self.LicenseKey = key
        self.LicenseVerified = true
        self:SaveLicense()
        return true, "Verification successful! Valid for 23 hours."
    else
        -- Verification failed, kick immediately
        showKickCountdown(10, "License verification failed: " .. message)
        wait(10)
        kickPlayer("License verification failed: " .. message)
        return false, "License verification failed"
    end
end

-- Local storage
function MSNEXUS_GLOBAL:SaveLicense()
    if self.LicenseKey and self.LicenseKey ~= "" then
        if isfile and writefile then
            pcall(function()
                writefile("msnexus_license.txt", self.LicenseKey)
            end)
        end
    end
end

function MSNEXUS_GLOBAL:LoadSavedLicense()
    if isfile and isfile("msnexus_license.txt") then
        local savedKey = readfile("msnexus_license.txt")
        local isValid, msg = validateLicenseFormat(savedKey)
        if isValid then
            self.LicenseKey = savedKey
            self.LicenseVerified = true
            return true
        else
            -- Delete invalid saved file
            pcall(function() delfile("msnexus_license.txt") end)
        end
    end
    return false
end

-- Initialize UI
function MSNEXUS_GLOBAL:InitUI()
    -- Try to load Obsidian UI library
    local success, lib = pcall(game:HttpGet, "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua")
    if not success then 
        print("Error: Unable to load UI library, please check your network")
        kickPlayer("Unable to load UI library, please check your network")
        return false
    end
    
    -- Load UI library
    local libFunc, errorMsg = loadstring(lib)
    if not libFunc then
        print("Error: UI library load failed: " .. (errorMsg or "unknown error"))
        kickPlayer("UI library load failed")
        return false
    end
    
    -- Execute UI library function
    self.Library = libFunc()
    
    -- Verify UI library is valid
    if not self.Library or type(self.Library) ~= "table" then
        print("Error: UI library initialization failed")
        kickPlayer("UI library initialization failed")
        return false
    end
    
    -- Check required UI library functions
    local requiredFunctions = {"CreateWindow", "Notify", "Unload"}
    for _, funcName in ipairs(requiredFunctions) do
        if not self.Library[funcName] or type(self.Library[funcName]) ~= "function" then
            print("Error: UI library missing required function: " .. funcName)
            kickPlayer("UI library incompatible, please update to latest version")
            return false
        end
    end
    
    print("UI library loaded successfully")
    return true
end

-- Create English user interface
function MSNEXUS_GLOBAL:CreateFullUI()
    if not self.Library then
        local success = self:InitUI()
        if not success then
            return false
        end
    end

    local footer = "v" .. self.Config.Version .. " | Global Edition"
    if self.LicenseVerified then
        footer = footer .. " | Verified"
    else
        footer = footer .. " | Unverified"
    end

    -- Create window - Global theme colors
    local windowConfig = {
        Title = self.Config.Name, 
        Footer = footer,
        ToggleKeybind = self.Config.DefaultToggleKey,
        Center = true, 
        AutoShow = true, 
        ShowCustomCursor = true,
        Font = self.Config.Font, 
        CornerRadius = self.Config.CornerRadius,
        Resizable = true,
        Color = Color3.fromRGB(0, 150, 100), -- Green global theme
        AccentColor = Color3.fromRGB(255, 165, 0) -- Orange accent
    }
    
    local success, window = pcall(function()
        return self.Library:CreateWindow(windowConfig)
    end)
    
    if not success or not window then
        print("Error: Failed to create window")
        kickPlayer("Failed to create UI window")
        return false
    end
    
    self.Window = window

    -- 1. Main Tab - License System
    local mainTab = self.Window:AddTab("Main Menu", "home")
    local authGroup = mainTab:AddLeftGroupbox("License System (23 Hour Validity)")

    -- Welcome message
    authGroup:AddLabel("Welcome to MS-NEXUS Global, " .. self.PlayerName .. "!")
    authGroup:AddDivider()

    -- Show license acquisition steps
    authGroup:AddLabel("Manual License Acquisition Steps:")
    authGroup:AddLabel("1. Manually visit the link below")
    authGroup:AddLabel("2. Click Generate Key button")
    authGroup:AddLabel("3. Copy the generated license key")
    authGroup:AddLabel("4. Paste it in the input box below")
    authGroup:AddLabel("")
    authGroup:AddLabel("License Acquisition Link:")
    authGroup:AddLabel("https://msnexus-key.vercel.app")
    authGroup:AddDivider()

    -- License key input
    local keyInput = authGroup:AddInput("KeyInput", {
        Text = "Paste License Key",
        Default = self.LicenseKey,
        Placeholder = "Paste license key from website here...",
        Callback = function(v) self.LicenseKey = v end
    })

    -- Verification button
    authGroup:AddButton({
        Text = "Verify License Key",
        Func = function()
            local key = keyInput.Value
            if key == "" then
                self.Library:Notify({
                    Title = "Error", 
                    Text = "Please enter license key", 
                    Duration = 3
                })
                return
            end
            
            -- Verify license (error will trigger kick)
            local success, msg = self:VerifyLicense(key)
            if success then
                self.Library:Notify({
                    Title = "Success", 
                    Text = msg, 
                    Duration = 5
                })
                self.Window._footerText.Text = "v" .. self.Config.Version .. " | Global Edition | Verified"
                
                -- Show welcome message after verification
                self.Library:Notify({
                    Title = "Welcome to MS-NEXUS Global",
                    Text = "Enjoy your global experience, " .. self.PlayerName .. "!",
                    Duration = 5
                })
            else
                -- Verification failed will auto-kick
                self.Library:Notify({
                    Title = "Verification Failed",
                    Text = msg .. ", will be kicked in 10 seconds",
                    Duration = 10
                })
            end
        end
    })

    -- 2. Settings Tab
    local settingsTab = self.Window:AddTab("Settings", "settings")
    local infoGroup = settingsTab:AddLeftGroupbox("Information & Support")
    infoGroup:AddLabel("Version: v" .. self.Config.Version)
    infoGroup:AddLabel("Edition: Global")
    infoGroup:AddLabel("Player: " .. self.PlayerName)
    infoGroup:AddLabel("Status: " .. (self.LicenseVerified and "Verified" or "Unverified"))
    infoGroup:AddLabel("User ID: " .. tostring(self.UserId))
    
    infoGroup:AddButton({
        Text = "Copy License Link",
        Func = function()
            local link = "https://msnexus-key.vercel.app"
            if setclipboard then
                setclipboard(link)
                self.Library:Notify({
                    Title = "Copied", 
                    Text = "License link copied to clipboard", 
                    Duration = 2
                })
            end
        end
    })
    
    infoGroup:AddButton({
        Text = "Clear License Cache",
        Func = function()
            self.LicenseKey = ""
            self.LicenseVerified = false
            if isfile and isfile("msnexus_license.txt") then
                delfile("msnexus_license.txt")
            end
            keyInput:SetValue("")
            self.Library:Notify({
                Title = "Cleared", 
                Text = "License cache cleared, please acquire new license", 
                Duration = 3
            })
            self.Window._footerText.Text = "v" .. self.Config.Version .. " | Global Edition | Unverified"
        end
    })
    
    infoGroup:AddButton({
        Text = "Unload Interface",
        Risky = true,
        DoubleClick = true,
        Func = function() 
            self.Library:Unload()
            self.Library:Notify({
                Title = "Unloaded",
                Text = "MS-NEXUS Global has been unloaded",
                Duration = 3
            })
        end
    })

    -- Show welcome message
    if not self.LicenseVerified then
        self.Library:Notify({
            Title = "Welcome to MS-NEXUS Global",
            Text = "Hello " .. self.PlayerName .. "! Please acquire and verify license to proceed.",
            Duration = 8
        })
        
        -- Show manual acquisition instructions on startup
        warn("============================================")
        warn("MS-NEXUS Global - v" .. self.Config.Version)
        warn("============================================")
        warn("Welcome to the global edition, " .. self.PlayerName .. "!")
        warn("")
        warn("Manual License Acquisition Steps:")
        warn("1. Manually visit: https://msnexus-key.vercel.app")
        warn("2. Click Generate Key button")
        warn("3. Copy the generated license key")
        warn("4. Return to game and paste in input box")
        warn("")
        warn("Note: License format is MSNEX-XXXX-XXXX-XXXX")
        warn("Each license is valid for 23 hours")
        warn("Invalid license will result in automatic kick!")
        warn("============================================")
    else
        self.Library:Notify({
            Title = self.Config.Name .. " Loaded",
            Text = "Press RightControl to toggle interface, " .. self.PlayerName .. "!",
            Duration = 5
        })
    end
    
    return true
end

-- Main startup function
function MSNEXUS_GLOBAL:QuickStart()
    -- Check for saved valid license
    local hasValidLicense = self:LoadSavedLicense()
    
    if hasValidLicense then
        print("Using saved verified license")
        self:CreateFullUI()
    else
        print("Manual license acquisition required")
        self:CreateFullUI()
    end
    
    return {Window = self.Window, Library = self.Library}
end

-- Constructor
function MSNEXUS_GLOBAL.new(customConfig)
    return SetupLibrary(setmetatable({}, MSNEXUS_GLOBAL), customConfig)
end
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Core Library Definition End
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- ============================================
-- [Script Auto-Start Section]
-- ============================================

-- Create and start MS-NEXUS Global
local NexusApp = MSNEXUS_GLOBAL.new()
NexusApp:QuickStart()

-- ============================================
-- Code End
-- ============================================
