-- ============================================
-- MADARA ZEN LIBRARY v4.0 (patched)
-- Modular feature library for Roblox scripts
-- Improvements: safer checks, remove unsupported calls, more robust feature handling
-- ============================================

local MadaraZen = {}
MadaraZen.__index = MadaraZen

-- ========== CONSTANTS ==========
MadaraZen.VERSION = "4.0"
MadaraZen.NAME = "MADARA ZEN"

-- ========== STRENGTH ITEMS ==========
MadaraZen.STRENGTH_ITEMS = {
    "Protein Egg", "Tropical Shake", "Energy Bar", "Protein Shake",
    "Energy Shake", "Protein Bar", "TOUGH Bar", "Ultra Shake", "Muscle Juice"
}

-- ========== FARM LOCATIONS ==========
MadaraZen.FARM_LOCATIONS = {
    Vector3.new(0, 10, 0),
    Vector3.new(50, 10, 0),
    Vector3.new(-50, 10, 0),
    Vector3.new(0, 10, 50),
    Vector3.new(0, 10, -50),
}

-- ========== CONSTRUCTOR ==========
function MadaraZen.new()
    local self = setmetatable({}, MadaraZen)

    -- Services
    self.Players = game:GetService("Players")
    self.RunService = game:GetService("RunService")

    -- Player references
    self.LocalPlayer = self.Players.LocalPlayer
    -- Guard: LocalPlayer may not be available in non-local contexts
    if not self.LocalPlayer then
        error("MadaraZen must be required from a LocalScript")
    end

    self.Character = self.LocalPlayer.Character or self.LocalPlayer.CharacterAdded:Wait()
    self.Humanoid = self.Character:WaitForChild("Humanoid")
    self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")

    -- Keep original walk speed so we can restore it
    self._originalWalkSpeed = (self.Humanoid and self.Humanoid.WalkSpeed) or 16

    -- Feature flags
    self.Features = {
        Strength = false,
        Farm = false,
        Rebirth = false,
        GodMode = false,
        Speed = false,
        AutoClicker = false,
        InfiniteStamina = false,
        Run = false
    }

    -- Config
    self.Config = {
        SpeedBoost = 8,            -- WalkSpeed bonus (added to original WalkSpeed)
        FarmWaitTime = 0.5,
        ItemCollectDistance = 50,
        CollectionWaitTime = 0.2,
        MainLoopWaitTime = 0.1,
        StatusUpdateTime = 0.5
    }

    -- Callbacks
    self.Callbacks = {}

    -- Setup respawn handler
    self:_setupRespawnHandler()

    return self
end

-- ========== FEATURE CALLBACKS ==========
function MadaraZen:OnFeatureToggle(featureName, callback)
    if not self.Callbacks then self.Callbacks = {} end
    if not self.Callbacks[featureName] then self.Callbacks[featureName] = {} end
    table.insert(self.Callbacks[featureName], callback)
end

function MadaraZen:_triggerCallback(featureName, state)
    if self.Callbacks and self.Callbacks[featureName] then
        for _, callback in ipairs(self.Callbacks[featureName]) do
            pcall(callback, state)
        end
    end
end

-- ========== FEATURE GETTERS/SETTERS ==========
function MadaraZen:IsFeatureActive(featureName)
    return self.Features[featureName] or false
end

function MadaraZen:SetFeature(featureName, state)
    if self.Features[featureName] == state then return end
    self.Features[featureName] = state
    self:_triggerCallback(featureName, state)

    -- If Speed feature is toggled off, restore WalkSpeed
    if featureName == "Speed" and not state and self.Humanoid then
        pcall(function()
            self.Humanoid.WalkSpeed = self._originalWalkSpeed
        end)
    end
end

function MadaraZen:ToggleFeature(featureName)
    local newState = not self.Features[featureName]
    self:SetFeature(featureName, newState)
    return newState
end

function MadaraZen:DisableAllFeatures()
    for featureName, _ in pairs(self.Features) do
        self:SetFeature(featureName, false)
    end
end

-- ========== SPEED BOOST ==========
function MadaraZen:SpeedBoost()
    if not self:IsFeatureActive("Speed") then return end
    pcall(function()
        if not self.Humanoid then return end
        -- Apply a WalkSpeed-based speed boost so it's more reliable than manipulating Velocity
        local base = self._originalWalkSpeed or 16
        local boost = tonumber(self.Config.SpeedBoost) or 0
        self.Humanoid.WalkSpeed = base + boost
    end)
end

-- ========== AUTO CLICKER ==========
-- Safer implementation: find nearest strength item model with a BasePart, move near it and attempt simple interactions.
function MadaraZen:AutoClicker()
    if not self:IsFeatureActive("AutoClicker") then return end

    pcall(function()
        if not self.Character or not self.HumanoidRootPart then return end

        local targetItem = nil
        local targetPart = nil

        for _, item in ipairs(game.Workspace:GetChildren()) do
            if item and item:IsA("Model") and self:_tableFind(self.STRENGTH_ITEMS, item.Name) then
                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if part then
                    if not targetPart then
                        targetItem = item
                        targetPart = part
                    else
                        local dist1 = (part.Position - self.HumanoidRootPart.Position).Magnitude
                        local dist2 = (targetPart.Position - self.HumanoidRootPart.Position).Magnitude
                        if dist1 < dist2 then
                            targetItem = item
                            targetPart = part
                        end
                    end
                end
            end
        end

        if targetItem and targetPart then
            local distance = (targetPart.Position - self.HumanoidRootPart.Position).Magnitude
            if distance <= (self.Config.ItemCollectDistance or 50) then
                -- Move near the item to trigger serverside touch/proximity logic
                local safeCFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                pcall(function() self.HumanoidRootPart.CFrame = safeCFrame end)
                task.wait(self.Config.CollectionWaitTime or 0.2)

                -- Try common collection triggers: ProximityPrompt(s), ClickDetector(s), Tools
                for _, desc in ipairs(targetItem:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        pcall(function()
                            -- Best-effort; many environments restrict programmatic firing of prompts
                            desc:InputHoldBegin()
                            task.wait(0.1)
                            desc:InputHoldEnd()
                        end)
                    elseif desc:IsA("ClickDetector") then
                        pcall(function()
                            -- ClickDetector.MouseClick can be fired from server in some contexts
                            desc:MouseClick(self.LocalPlayer)
                        end)
                    elseif desc:IsA("Tool") then
                        pcall(function()
                            desc.Parent = self.Character
                            if typeof(desc.Activate) == "function" then
                                desc:Activate()
                            end
                            desc.Parent = self.LocalPlayer.Backpack
                        end)
                    end
                end
            else
                -- If not within collect distance, consider moving closer (optional)
                -- Only move if Farm/Run features are active to avoid accidental teleporting
                if self:IsFeatureActive("Run") or self:IsFeatureActive("Farm") then
                    pcall(function() self.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0) end)
                    task.wait(self.Config.CollectionWaitTime or 0.2)
                end
            end
        end
    end)
end

-- ========== INFINITE STAMINA ==========
function MadaraZen:InfiniteStamina()
    if not self:IsFeatureActive("InfiniteStamina") then return end

    pcall(function()
        -- Try multiple common locations for stamina
        if self.Humanoid and self.Humanoid:FindFirstChild("Stamina") and type(self.Humanoid.Stamina.Value) == "number" then
            self.Humanoid.Stamina.Value = math.max(self.Humanoid.Stamina.Value, 100)
        end

        if self.Character and self.Character:FindFirstChild("Stats") and self.Character.Stats:FindFirstChild("Stamina") then
            local s = self.Character.Stats.Stamina
            if type(s.Value) == "number" then
                s.Value = math.max(s.Value, 999999)
            end
        end

        -- Some games use leaderstats or attributes
        if self.LocalPlayer and self.LocalPlayer:FindFirstChild("leaderstats") and self.LocalPlayer.leaderstats:FindFirstChild("Stamina") then
            local ls = self.LocalPlayer.leaderstats.Stamina
            if type(ls.Value) == "number" then
                ls.Value = math.max(ls.Value, 999999)
            end
        end
    end)
end

-- ========== AUTO STRENGTH ==========
function MadaraZen:ActivateStrength()
    if not self:IsFeatureActive("Strength") then return end

    pcall(function()
        for _, itemName in ipairs(self.STRENGTH_ITEMS) do
            if not self:IsFeatureActive("Strength") then break end

            local item = self.LocalPlayer.Backpack and self.LocalPlayer.Backpack:FindFirstChild(itemName)
            if item then
                item.Parent = self.Character
                self.RunService.Heartbeat:Wait()

                if self.Character:FindFirstChild(itemName) then
                    local tool = self.Character:FindFirstChild(itemName)
                    -- Tools normally have Activate method
                    pcall(function()
                        if typeof(tool.Activate) == "function" then
                            tool:Activate()
                        end
                    end)
                end

                -- Return to backpack if still present
                if self.LocalPlayer.Backpack and self.LocalPlayer.Backpack:FindFirstChild(itemName) == nil and self.Character:FindFirstChild(itemName) then
                    local tool = self.Character:FindFirstChild(itemName)
                    pcall(function() tool.Parent = self.LocalPlayer.Backpack end)
                end
            end
        end
    end)
end

-- ========== AUTO FARM ==========
function MadaraZen:AutoFarm()
    if not self:IsFeatureActive("Farm") then return end

    pcall(function()
        for _, location in ipairs(self.FARM_LOCATIONS) do
            if not self:IsFeatureActive("Farm") then break end
            if self.HumanoidRootPart then
                pcall(function() self.HumanoidRootPart.CFrame = CFrame.new(location) end)
            end
            task.wait(self.Config.FarmWaitTime)
        end

        for _, item in ipairs(game.Workspace:GetChildren()) do
            if not self:IsFeatureActive("Farm") then break end
            if item and item:IsA("Model") and self:_tableFind(self.STRENGTH_ITEMS, item.Name) then
                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if part and self.HumanoidRootPart then
                    if (part.Position - self.HumanoidRootPart.Position).Magnitude < (self.Config.ItemCollectDistance or 50) then
                        pcall(function() self.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0) end)
                        task.wait(self.Config.CollectionWaitTime)
                    end
                end
            end
        end
    end)
end

-- ========== AUTO REBIRTH ==========
function MadaraZen:AutoRebirth()
    if not self:IsFeatureActive("Rebirth") then return end

    pcall(function()
        local playerGui = self.LocalPlayer and self.LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end

        for _, v in ipairs(playerGui:GetDescendants()) do
            if not self:IsFeatureActive("Rebirth") then break end
            if v and v:IsA("TextButton") then
                local text = v.Text or ""
                if text:match("Rebirth") or text:match("rebirth") then
                    -- Try several safe methods to trigger the button
                    pcall(function()
                        if typeof(v.Activate) == "function" then
                            v:Activate()
                        elseif v.MouseButton1Click and typeof(v.MouseButton1Click.Fire) == "function" then
                            v.MouseButton1Click:Fire()
                        end
                    end)

                    task.wait(2)
                    break
                end
            end
        end
    end)
end

-- ========== GOD MODE ==========
function MadaraZen:GodMode()
    if not self:IsFeatureActive("GodMode") then return end

    pcall(function()
        if self.Humanoid and self.Humanoid.MaxHealth then
            self.Humanoid.Health = self.Humanoid.MaxHealth
        end
        if self.HumanoidRootPart and typeof(self.HumanoidRootPart.CanCollide) == "boolean" then
            self.HumanoidRootPart.CanCollide = false
        end
        if self.Humanoid and typeof(self.Humanoid.SetStateEnabled) == "function" then
            self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dying, false)
        end
    end)
end

-- ========== RUN ALL FEATURES ==========
function MadaraZen:RunAll()
    if not self:IsFeatureActive("Run") then return end

    while self:IsFeatureActive("Run") do
        pcall(function()
            if self:IsFeatureActive("Strength") then
                self:ActivateStrength()
            end

            if self:IsFeatureActive("Farm") then
                self:AutoFarm()
            end

            if self:IsFeatureActive("Rebirth") then
                self:AutoRebirth()
            end

            if self:IsFeatureActive("GodMode") then
                self:GodMode()
            end

            if self:IsFeatureActive("Speed") then
                self:SpeedBoost()
            end

            if self:IsFeatureActive("AutoClicker") then
                self:AutoClicker()
            end

            if self:IsFeatureActive("InfiniteStamina") then
                self:InfiniteStamina()
            end
        end)
        task.wait(self.Config.MainLoopWaitTime)
    end
end

-- ========== MAIN LOOP ==========
function MadaraZen:StartMainLoop()
    task.spawn(function()
        while true do
            pcall(function()
                if self:IsFeatureActive("Strength") then
                    self:ActivateStrength()
                end

                if self:IsFeatureActive("Farm") then
                    self:AutoFarm()
                end

                if self:IsFeatureActive("Rebirth") then
                    self:AutoRebirth()
                end

                if self:IsFeatureActive("GodMode") then
                    self:GodMode()
                end

                if self:IsFeatureActive("Speed") then
                    self:SpeedBoost()
                end

                if self:IsFeatureActive("AutoClicker") then
                    self:AutoClicker()
                end

                if self:IsFeatureActive("InfiniteStamina") then
                    self:InfiniteStamina()
                end
            end)
            task.wait(self.Config.MainLoopWaitTime)
        end
    end)
end

-- ========== STATUS DISPLAY ==========
function MadaraZen:GetStatusString()
    return string.format(
        "⚡ Str: %s | 🌾 Farm: %s\n" ..
        "♻️ Rebirth: %s | 👑 God: %s\n" ..
        "🚀 Speed: %s | 🖱️ Click: %s\n" ..
        "⚡ Stamina: %s | ▶️ Run: %s\n" ..
        "HP: %d/%d",
        self:IsFeatureActive("Strength") and "✅" or "❌",
        self:IsFeatureActive("Farm") and "✅" or "❌",
        self:IsFeatureActive("Rebirth") and "✅" or "❌",
        self:IsFeatureActive("GodMode") and "✅" or "❌",
        self:IsFeatureActive("Speed") and "✅" or "❌",
        self:IsFeatureActive("AutoClicker") and "✅" or "❌",
        self:IsFeatureActive("InfiniteStamina") and "✅" or "❌",
        self:IsFeatureActive("Run") and "▶️ ON" or "⏹️ OFF",
        math.floor(self.Humanoid and self.Humanoid.Health or 0),
        math.floor(self.Humanoid and self.Humanoid.MaxHealth or 0)
    )
end

-- ========== CONFIGURATION ==========
function MadaraZen:SetConfig(configTable)
    for key, value in pairs(configTable) do
        -- allow falsy values like 0 or false to be set; only skip unknown keys
        if self.Config[key] ~= nil then
            self.Config[key] = value
        end
    end
end

function MadaraZen:GetConfig()
    return self.Config
end

-- ========== UTILITY FUNCTIONS ==========
function MadaraZen:_tableFind(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function MadaraZen:_setupRespawnHandler()
    if not self.LocalPlayer then return end
    self.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        self.Character = newCharacter
        self.Humanoid = self.Character:WaitForChild("Humanoid")
        self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")

        -- restore original walk speed reference
        self._originalWalkSpeed = (self.Humanoid and self.Humanoid.WalkSpeed) or self._originalWalkSpeed

        if self:IsFeatureActive("GodMode") then
            task.spawn(function() self:GodMode() end)
        end

        if self:IsFeatureActive("Speed") then
            task.spawn(function() self:SpeedBoost() end)
        end
    end)
end

-- ========== PRINT FUNCTIONS ==========
function MadaraZen:Print(message)
    print("[MADARA ZEN] " .. tostring(message))
end

function MadaraZen:PrintInfo()
    self:Print("✅ MADARA ZEN v" .. self.VERSION .. " LIBRARY LOADED!")
    self:Print("Features: Strength, Farm, Rebirth, GodMode, Speed, AutoClicker, InfiniteStamina, Run")
end

return MadaraZen
