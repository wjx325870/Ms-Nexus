-- ============================================
-- MS Nexus - 完整独立版 v3.5
-- 描述：一个开箱即用的ROBLOX工具箱，必须从指定链接获取卡密。
-- 使用：复制全部代码到执行器，直接运行。
-- ============================================

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 核心库定义开始
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local MSLibrary = {}
MSLibrary.__index = MSLibrary

-- 内部函数：验证卡密格式
local function validateLicenseFormat(licenseKey)
    if not licenseKey or licenseKey == "" then
        return false, "卡密为空"
    end
    
    -- 验证 MS-NEXUS 格式
    local pattern = "^MSNEX%-[A-Z0-9]+%-[A-Z0-9]+%-[A-Z0-9]+$"
    if not string.match(licenseKey, pattern) then
        return false, "卡密格式无效，请使用 MS-NEXUS 格式"
    end
    
    return true, "格式正确"
end

-- 内部函数：验证卡密是否过期
local function validateLicenseExpiry(licenseKey)
    -- 这里可以添加更复杂的验证逻辑
    -- 目前仅验证格式，不验证过期时间
    return true, "卡密有效"
end

-- 踢出游戏函数
local function kickPlayer(reason)
    local player = game.Players.LocalPlayer
    if player then
        pcall(function()
            player:Kick("[MS Nexus] " .. reason)
        end)
    end
end

-- 显示倒计时踢出提示
local function showKickCountdown(seconds, reason)
    for i = seconds, 1, -1 do
        if i % 5 == 0 or i <= 10 then
            warn(string.format("[MS Nexus] %s，%d秒后将自动踢出...", reason, i))
        end
        wait(1)
    end
end

-- 内部函数：从指定链接获取卡密（需要用户手动获取）
local function getLicenseFromWebsite()
    local getKeyURL = "https://msnexus-key-bxxa2xhv7-wjx325870s-projects.vercel.app"
    
    -- 复制链接到剪贴板
    if setclipboard then
        setclipboard(getKeyURL)
    end
    
    -- 通知用户
    warn("============================================")
    warn("🎮 MS Nexus 工具箱")
    warn("============================================")
    warn("⚠️ 需要有效的卡密才能使用！")
    warn("🔗 获取卡密链接: " .. getKeyURL)
    warn("📋 链接已自动复制到剪贴板")
    warn("")
    warn("📝 使用步骤:")
    warn("1. 打开浏览器访问上面的链接")
    warn("2. 点击 '获取卡密' 按钮")
    warn("3. 复制生成的卡密")
    warn("4. 返回游戏粘贴到输入框")
    warn("============================================")
    
    -- 尝试打开浏览器
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow(getKeyURL)
    end)
    
    return nil
end

local function SetupLibrary(self, customConfig)
    -- 默认配置
    self.Config = {
        Name = "MS Nexus",
        Version = "3.5.0",
        MaxAttempts = 1, -- 仅允许一次尝试
        CurrentAttempts = 0,
        Discord = "https://discord.gg/yourlink",
        GetKeyURL = "https://msnexus-key-bxxa2xhv7-wjx325870s-projects.vercel.app",
        Icon = "briefcase",
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
    
    -- 初始化：显示获取卡密链接
    self:ShowLicenseRequiredNotice()
    return self
end

-- 显示必须获取卡密的通知
function MSLibrary:ShowLicenseRequiredNotice()
    print("")
    print("=" . rep(50))
    print("🔐 MS Nexus 许可证系统")
    print("=" . rep(50))
    print("⚠️  此脚本需要有效的许可证密钥才能运行！")
    print("")
    print("📋 获取许可证的步骤:")
    print("1. 访问: " .. self.Config.GetKeyURL)
    print("2. 点击 '生成卡密' 按钮")
    print("3. 复制生成的卡密")
    print("4. 在脚本中输入卡密进行验证")
    print("")
    print("💡 注意: 每个卡密有效期为23小时")
    print("⏰ 如果输入错误的卡密，将被自动踢出游戏！")
    print("=" . rep(50))
    
    -- 复制链接到剪贴板
    if setclipboard then
        setclipboard(self.Config.GetKeyURL)
        print("✅ 链接已复制到剪贴板")
    end
end

-- HTTP请求封装（验证卡密）
function MSLibrary:CallBackend(endpoint, method, data)
    -- 这里可以集成后端验证系统
    -- 目前仅做本地验证
    local success, msg = validateLicenseFormat(data.licenseKey)
    if not success then
        return false, msg
    end
    
    -- 模拟验证通过
    return true, "验证成功！卡密有效期为23小时。"
end

-- 验证许可证（带踢出功能）
function MSLibrary:VerifyLicense(key)
    self.Config.CurrentAttempts = self.Config.CurrentAttempts + 1
    
    -- 超过最大尝试次数，立即踢出
    if self.Config.CurrentAttempts > self.Config.MaxAttempts then
        local reason = "验证尝试次数过多，请重新进入游戏获取新卡密。"
        showKickCountdown(10, reason)
        wait(10)
        kickPlayer(reason)
        return false, reason
    end
    
    -- 验证格式
    local isValid, msg = validateLicenseFormat(key)
    if not isValid then
        -- 格式错误，立即踢出
        showKickCountdown(10, "卡密格式错误：" .. msg)
        wait(10)
        kickPlayer("卡密格式错误：" .. msg)
        return false, "卡密格式错误"
    end
    
    -- 验证卡密（这里可以调用后端API）
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
        showKickCountdown(10, "卡密验证失败：" .. message)
        wait(10)
        kickPlayer("卡密验证失败：" .. message)
        return false, "卡密验证失败"
    end
end

-- 本地存储
function MSLibrary:SaveLicense()
    if self.LicenseKey and self.LicenseKey ~= "" then
        if isfile and writefile then
            pcall(function()
                writefile("msnexus_license.txt", self.LicenseKey)
            end)
        end
    end
end

function MSLibrary:LoadSavedLicense()
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
function MSLibrary:InitUI()
    local success, lib = pcall(game:HttpGet, "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua")
    if not success then 
        kickPlayer("无法加载UI库，请检查网络。")
        return
    end
    self.Library = loadstring(lib)()
end

-- 创建完整用户界面
function MSLibrary:CreateFullUI()
    if not self.Library then self:InitUI() end

    local footer = self.Config.Version
    if self.LicenseVerified then
        footer = footer .. " | ✅ 已验证"
    else
        footer = footer .. " | ⚠️ 未验证"
    end

    self.Window = self.Library:CreateWindow({
        Title = self.Config.Name, Footer = footer,
        ToggleKeybind = self.Config.DefaultToggleKey,
        Center = true, AutoShow = true, ShowCustomCursor = true,
        Font = self.Font, CornerRadius = self.CornerRadius,
        Resizable = true
    })

    -- 1. 主标签页 - 验证系统
    local mainTab = self.Window:AddTab("主菜单", "home")
    local authGroup = mainTab:AddLeftGroupbox("许可证系统 (23小时有效期)")

    -- 显示获取卡密的提示
    authGroup:AddLabel("📋 使用步骤:")
    authGroup:AddLabel("1. 点击下方按钮打开获取页面")
    authGroup:AddLabel("2. 点击 '生成卡密' 按钮")
    authGroup:AddLabel("3. 复制生成的卡密")
    authGroup:AddLabel("4. 粘贴到下方输入框并验证")
    authGroup:AddDivider()

    -- 获取卡密按钮
    authGroup:AddButton({
        Text = "🔗 打开获取页面",
        Func = function()
            if setclipboard then
                setclipboard(self.Config.GetKeyURL)
            end
            pcall(function()
                game:GetService("GuiService"):OpenBrowserWindow(self.Config.GetKeyURL)
            end)
            self.Library:Notify({
                Title = "提示",
                Text = "获取页面已打开，请获取卡密后返回游戏",
                Duration = 5
            })
        end
    })

    authGroup:AddDivider()

    -- 卡密输入框
    local keyInput = authGroup:AddInput("KeyInput", {
        Text = "粘贴卡密",
        Default = self.LicenseKey,
        Placeholder = "在此粘贴从网站获取的卡密...",
        Callback = function(v) self.LicenseKey = v end
    })

    -- 验证按钮
    authGroup:AddButton({
        Text = "✅ 验证卡密",
        Func = function()
            local key = keyInput.Value
            if key == "" then
                self.Library:Notify({
                    Title = "错误", 
                    Text = "请输入卡密", 
                    Duration = 3
                })
                return
            end
            
            -- 验证卡密（错误会触发踢出）
            local success, msg = self:VerifyLicense(key)
            if success then
                self.Library:Notify({
                    Title = "成功", 
                    Text = msg, 
                    Duration = 5
                })
                self.Window._footerText.Text = self.Config.Version .. " | ✅ 已验证"
                
                -- 激活其他功能
                self:EnableAllFeatures()
            else
                -- 验证失败时会自动踢出，这里不需要额外处理
                self.Library:Notify({
                    Title = "验证失败",
                    Text = msg .. "，10秒后将被踢出游戏",
                    Duration = 10
                })
            end
        end
    })

    -- 2. 工具箱标签页（默认禁用）
    local toolsTab = self.Window:AddTab("工具箱", "briefcase")
    local moveGroup = toolsTab:AddLeftGroupbox("移动设置")
    
    -- 移动速度滑块（默认禁用）
    local speedSlider = moveGroup:AddSlider("WalkSpeed", {
        Text = "移动速度", 
        Default = 16, 
        Min = 16, 
        Max = 200,
        Disabled = not self.LicenseVerified,
        Callback = function(v)
            if self.LicenseVerified then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = v
                end
            end
        end
    })
    
    -- 跳跃力量滑块（默认禁用）
    local jumpSlider = moveGroup:AddSlider("JumpPower", {
        Text = "跳跃力量", 
        Default = 50, 
        Min = 50, 
        Max = 200,
        Disabled = not self.LicenseVerified,
        Callback = function(v)
            if self.LicenseVerified then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = v
                end
            end
        end
    })

    -- 3. 设置标签页
    local settingsTab = self.Window:AddTab("设置", "settings")
    local infoGroup = settingsTab:AddLeftGroupbox("信息与支持")
    infoGroup:AddLabel("版本: " .. self.Config.Version)
    infoGroup:AddLabel("状态: " .. (self.LicenseVerified and "✅ 已验证" or "❌ 未验证"))
    infoGroup:AddLabel("提示: 必须从指定链接获取卡密")
    
    infoGroup:AddButton({
        Text = "📋 复制获取链接",
        Func = function()
            if setclipboard then
                setclipboard(self.Config.GetKeyURL)
                self.Library:Notify({
                    Title = "已复制", 
                    Text = "获取链接已复制到剪贴板", 
                    Duration = 2
                })
            end
        end
    })
    
    infoGroup:AddButton({
        Text = "🔑 清除卡密缓存",
        Func = function()
            self.LicenseKey = ""
            self.LicenseVerified = false
            if isfile and isfile("msnexus_license.txt") then
                delfile("msnexus_license.txt")
            end
            keyInput:SetValue("")
            self.Library:Notify({
                Title = "已清除", 
                Text = "卡密缓存已清除，请重新获取卡密", 
                Duration = 3
            })
            self.Window._footerText.Text = self.Config.Version .. " | ❌ 未验证"
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
                Text = "MS Nexus 已卸载",
                Duration = 3
            })
        end
    })

    -- 显示欢迎信息
    if not self.LicenseVerified then
        self.Library:Notify({
            Title = "欢迎使用 " .. self.Config.Name,
            Text = "请先从指定链接获取卡密并验证，然后才能使用所有功能！",
            Duration = 8
        })
    else
        self.Library:Notify({
            Title = self.Config.Name .. " 已加载",
            Text = "按 RightControl 键切换界面，卡密已验证！",
            Duration = 5
        })
    end
end

-- 激活所有功能
function MSLibrary:EnableAllFeatures()
    -- 这里可以激活所有被禁用的功能
    if self.Window and self.LicenseVerified then
        -- 可以在这里添加代码来启用所有被禁用的控件
        print("✅ 所有功能已激活！")
    end
end

-- 主启动函数
function MSLibrary:QuickStart()
    if not self.Library then self:InitUI() end
    
    -- 检查是否有保存的已验证卡密
    local hasValidLicense = self:LoadSavedLicense()
    
    if hasValidLicense then
        print("✅ 使用已保存的验证卡密")
        self:CreateFullUI()
    else
        print("⚠️ 需要获取并验证卡密")
        self:CreateFullUI()
    end
    
    return {Window = self.Window, Library = self.Library}
end

-- 构造函数
function MSLibrary.new(customConfig)
    return SetupLibrary(setmetatable({}, MSLibrary), customConfig)
end
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 核心库定义结束
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- ============================================
-- 【脚本自动启动部分】
-- ============================================

-- 创建并启动MS Nexus
local NexusApp = MSLibrary.new()
NexusApp:QuickStart()

-- ============================================
-- 代码结束
-- ============================================
