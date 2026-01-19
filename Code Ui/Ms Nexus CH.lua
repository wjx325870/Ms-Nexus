-- ============================================
-- MS-NEXUS 中文版 v2.0
-- 描述：ROBLOX多功能工具箱，中文界面
-- 语言：zh-CN
-- 卡密格式：MSNEX-XXXX-XXXX-XXXX
-- ============================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 核心库定义开始
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local MSNEXUS_CN = {}
MSNEXUS_CN.__index = MSNEXUS_CN

-- 内部函数：验证许可证格式
local function validateLicenseFormat(licenseKey)
    if not licenseKey or licenseKey == "" then
        return false, "许可证密钥为空"
    end
    
    -- 验证 MS-NEXUS 格式
    local pattern = "^MSNEX%-[A-Z0-9]+%-[A-Z0-9]+%-[A-Z0-9]+$"
    if not string.match(licenseKey, pattern) then
        return false, "许可证格式无效，请使用 MSNEX-XXXX-XXXX-XXXX 格式"
    end
    
    return true, "格式正确"
end

-- 踢出玩家函数
local function kickPlayer(reason)
    local player = game.Players.LocalPlayer
    if player then
        pcall(function()
            player:Kick("[MS-NEXUS] " .. reason)
        end)
    end
end

-- 显示踢出倒计时
local function showKickCountdown(seconds, reason)
    for i = seconds, 1, -1 do
        if i % 5 == 0 or i <= 10 then
            warn(string.format("[MS-NEXUS] %s，%d秒后将自动踢出...", reason, i))
        end
        wait(1)
    end
end

local function SetupLibrary(self, customConfig)
    -- 默认配置
    self.Config = {
        Name = "MS-NEXUS",
        Version = "2.0.0",
        Language = "zh-CN",
        MaxAttempts = 1,
        CurrentAttempts = 0,
        Discord = "https://discord.gg/yourlink",
        Font = Enum.Font.Code,
        CornerRadius = 4,
        DefaultToggleKey = Enum.KeyCode.RightControl,
        DebugMode = false
    }
    
    -- 合并自定义配置
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

-- HTTP请求封装 (许可证验证)
function MSNEXUS_CN:CallBackend(endpoint, method, data)
    -- 这里可以集成后端验证系统
    -- 目前仅做本地验证
    local success, msg = validateLicenseFormat(data.licenseKey)
    if not success then
        return false, msg
    end
    
    -- 模拟验证通过
    return true, "验证成功！许可证有效期为23小时。"
end

-- 验证许可证 (带踢出功能)
function MSNEXUS_CN:VerifyLicense(key)
    self.Config.CurrentAttempts = self.Config.CurrentAttempts + 1
    
    -- 超过最大尝试次数，立即踢出
    if self.Config.CurrentAttempts > self.Config.MaxAttempts then
        showKickCountdown(10, "验证尝试次数过多，请重新加入获取新许可证")
        wait(10)
        kickPlayer("验证尝试次数过多，请重新加入获取新许可证")
        return false, "验证尝试次数过多"
    end
    
    -- 验证格式
    local isValid, msg = validateLicenseFormat(key)
    if not isValid then
        -- 格式错误，立即踢出
        showKickCountdown(10, "许可证格式错误：" .. msg)
        wait(10)
        kickPlayer("许可证格式错误：" .. msg)
        return false, "许可证格式错误"
    end
    
    -- 验证许可证 (这里可以调用后端API)
    local success, message, data = self:CallBackend("/validate", "POST", {
        licenseKey = key,
        robloxUserId = self.UserId
    })
    
    if success then
        self.LicenseKey = key
        self.LicenseVerified = true
        self:SaveLicense()
        return true, "验证成功！有效期23小时。"
    else
        -- 验证失败，立即踢出
        showKickCountdown(10, "许可证验证失败：" .. message)
        wait(10)
        kickPlayer("许可证验证失败：" .. message)
        return false, "许可证验证失败"
    end
end

-- 本地存储
function MSNEXUS_CN:SaveLicense()
    if self.LicenseKey and self.LicenseKey ~= "" then
        if isfile and writefile then
            pcall(function()
                writefile("msnexus_license.txt", self.LicenseKey)
            end)
        end
    end
end

function MSNEXUS_CN:LoadSavedLicense()
    if isfile and isfile("msnexus_license.txt") then
        local savedKey = readfile("msnexus_license.txt")
        local isValid, msg = validateLicenseFormat(savedKey)
        if isValid then
            self.LicenseKey = savedKey
            self.LicenseVerified = true
            return true
        else
            -- 删除无效的保存文件
            pcall(function() delfile("msnexus_license.txt") end)
        end
    end
    return false
end

-- 初始化UI
function MSNEXUS_CN:InitUI()
    -- 尝试加载Obsidian UI库
    local success, lib = pcall(game:HttpGet, "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua")
    if not success then 
        print("错误：无法加载UI库，请检查网络连接")
        kickPlayer("无法加载UI库，请检查网络连接")
        return false
    end
    
    -- 加载UI库
    local libFunc, errorMsg = loadstring(lib)
    if not libFunc then
        print("错误：UI库加载失败：" .. (errorMsg or "未知错误"))
        kickPlayer("UI库加载失败")
        return false
    end
    
    -- 执行UI库函数
    self.Library = libFunc()
    
    -- 验证UI库是否有效
    if not self.Library or type(self.Library) ~= "table" then
        print("错误：UI库初始化失败")
        kickPlayer("UI库初始化失败")
        return false
    end
    
    -- 检查必需的UI库函数
    local requiredFunctions = {"CreateWindow", "Notify", "Unload"}
    for _, funcName in ipairs(requiredFunctions) do
        if not self.Library[funcName] or type(self.Library[funcName]) ~= "function" then
            print("错误：UI库缺少必需函数：" .. funcName)
            kickPlayer("UI库不兼容，请更新到最新版本")
            return false
        end
    end
    
    print("UI库加载成功")
    return true
end

-- 创建中文用户界面
function MSNEXUS_CN:CreateFullUI()
    if not self.Library then
        local success = self:InitUI()
        if not success then
            return false
        end
    end

    local footer = "版本 " .. self.Config.Version .. " | 中文版"
    if self.LicenseVerified then
        footer = footer .. " | 已验证"
    else
        footer = footer .. " | 未验证"
    end

    -- 创建窗口 - 中文主题颜色
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
        Color = Color3.fromRGB(0, 100, 200), -- 蓝色主题
        AccentColor = Color3.fromRGB(255, 215, 0) -- 金色强调色
    }
    
    local success, window = pcall(function()
        return self.Library:CreateWindow(windowConfig)
    end)
    
    if not success or not window then
        print("错误：创建窗口失败")
        kickPlayer("创建UI窗口失败")
        return false
    end
    
    self.Window = window

    -- 1. 主标签页 - 许可证系统
    local mainTab = self.Window:AddTab("主菜单", "home")
    local authGroup = mainTab:AddLeftGroupbox("许可证系统 (23小时有效期)")

    -- 欢迎消息
    authGroup:AddLabel("欢迎来到 MS-NEXUS，" .. self.PlayerName .. "！")
    authGroup:AddDivider()

    -- 显示许可证获取步骤
    authGroup:AddLabel("手动获取许可证步骤：")
    authGroup:AddLabel("1. 手动访问下方链接获取许可证")
    authGroup:AddLabel("2. 点击生成密钥按钮")
    authGroup:AddLabel("3. 复制生成的许可证密钥")
    authGroup:AddLabel("4. 粘贴到下方输入框并验证")
    authGroup:AddLabel("")
    authGroup:AddLabel("许可证获取链接：")
    authGroup:AddLabel("https://msnexus-key.vercel.app")
    authGroup:AddDivider()

    -- 许可证密钥输入
    local keyInput = authGroup:AddInput("KeyInput", {
        Text = "粘贴许可证密钥",
        Default = self.LicenseKey,
        Placeholder = "在此粘贴从网站获取的许可证...",
        Callback = function(v) self.LicenseKey = v end
    })

    -- 验证按钮
    authGroup:AddButton({
        Text = "验证许可证密钥",
        Func = function()
            local key = keyInput.Value
            if key == "" then
                self.Library:Notify({
                    Title = "错误", 
                    Text = "请输入许可证密钥", 
                    Duration = 3
                })
                return
            end
            
            -- 验证许可证 (错误会触发踢出)
            local success, msg = self:VerifyLicense(key)
            if success then
                self.Library:Notify({
                    Title = "成功", 
                    Text = msg, 
                    Duration = 5
                })
                self.Window._footerText.Text = "版本 " .. self.Config.Version .. " | 中文版 | 已验证"
                
                -- 验证成功后显示欢迎消息
                self.Library:Notify({
                    Title = "欢迎来到 MS-NEXUS",
                    Text = "享受你的体验，" .. self.PlayerName .. "！",
                    Duration = 5
                })
            else
                -- 验证失败时会自动踢出
                self.Library:Notify({
                    Title = "验证失败",
                    Text = msg .. "，10秒后将被踢出游戏",
                    Duration = 10
                })
            end
        end
    })

    -- 2. 设置标签页
    local settingsTab = self.Window:AddTab("设置", "settings")
    local infoGroup = settingsTab:AddLeftGroupbox("信息与支持")
    infoGroup:AddLabel("版本：" .. self.Config.Version)
    infoGroup:AddLabel("语言：中文版")
    infoGroup:AddLabel("玩家：" .. self.PlayerName)
    infoGroup:AddLabel("状态：" .. (self.LicenseVerified and "已验证" or "未验证"))
    infoGroup:AddLabel("用户ID：" .. tostring(self.UserId))
    
    infoGroup:AddButton({
        Text = "复制许可证链接",
        Func = function()
            local link = "https://msnexus-key.vercel.app"
            if setclipboard then
                setclipboard(link)
                self.Library:Notify({
                    Title = "已复制", 
                    Text = "许可证链接已复制到剪贴板", 
                    Duration = 2
                })
            end
        end
    })
    
    infoGroup:AddButton({
        Text = "清除许可证缓存",
        Func = function()
            self.LicenseKey = ""
            self.LicenseVerified = false
            if isfile and isfile("msnexus_license.txt") then
                delfile("msnexus_license.txt")
            end
            keyInput:SetValue("")
            self.Library:Notify({
                Title = "已清除", 
                Text = "许可证缓存已清除，请重新获取许可证", 
                Duration = 3
            })
            self.Window._footerText.Text = "版本 " .. self.Config.Version .. " | 中文版 | 未验证"
        end
    })
    
    infoGroup:AddButton({
        Text = "卸载界面",
        Risky = true,
        DoubleClick = true,
        Func = function() 
            self.Library:Unload()
            self.Library:Notify({
                Title = "已卸载",
                Text = "MS-NEXUS 已卸载",
                Duration = 3
            })
        end
    })

    -- 显示欢迎消息
    if not self.LicenseVerified then
        self.Library:Notify({
            Title = "欢迎来到 MS-NEXUS",
            Text = "你好 " .. self.PlayerName .. "！请获取并验证许可证以继续。",
            Duration = 8
        })
        
        -- 启动时显示手动获取步骤
        warn("============================================")
        warn("MS-NEXUS 中文版 - 版本 " .. self.Config.Version)
        warn("============================================")
        warn("欢迎，" .. self.PlayerName .. "！")
        warn("")
        warn("手动获取许可证步骤：")
        warn("1. 手动访问：https://msnexus-key.vercel.app")
        warn("2. 点击生成密钥按钮")
        warn("3. 复制生成的许可证密钥")
        warn("4. 返回游戏并粘贴到输入框")
        warn("")
        warn("注意：许可证格式为 MSNEX-XXXX-XXXX-XXXX")
        warn("每个许可证有效期为23小时")
        warn("无效许可证将导致自动踢出游戏！")
        warn("============================================")
    else
        self.Library:Notify({
            Title = self.Config.Name .. " 已加载",
            Text = "按 RightControl 键切换界面，" .. self.PlayerName .. "！",
            Duration = 5
        })
    end
    
    return true
end

-- 主启动函数
function MSNEXUS_CN:QuickStart()
    -- 检查是否有保存的已验证许可证
    local hasValidLicense = self:LoadSavedLicense()
    
    if hasValidLicense then
        print("使用已保存的验证许可证")
        self:CreateFullUI()
    else
        print("需要手动获取许可证")
        self:CreateFullUI()
    end
    
    return {Window = self.Window, Library = self.Library}
end

-- 构造函数
function MSNEXUS_CN.new(customConfig)
    return SetupLibrary(setmetatable({}, MSNEXUS_CN), customConfig)
end
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 核心库定义结束
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- ============================================
-- 【脚本自动启动部分】
-- ============================================

-- 创建并启动MS-NEXUS中文版
local NexusApp = MSNEXUS_CN.new()
NexusApp:QuickStart()

-- ============================================
-- 代码结束
-- ============================================
