-- ui lib

-- https://cat-sus.gitbook.io/fatality
local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Fatality/refs/heads/main/src/source.luau"))();


if not Fatality then
    warn("Failed to load the ui library, executor is probably unsupported or the github link was deleted.")
    return
end

local thegetgenvissupportedomg = false

function checkgetgenv()
    if getgenv and type(getgenv) == "function" then
        thegetgenvissupportedomg = true
    else
        warn("getgenv is not supported. This script cant run without it.")
        return
    end
end

checkgetgenv()

if not thegetgenvissupportedomg then
    return
end

local Notification = Fatality:CreateNotifier();


if game.PlaceId ~= 122764594952227 then
    Notification:Notify({ Title = "Error", Content = "This script is for Penablox HVH only!", Icon = "bell" })
    return
end

-- check if the executor is supported

-- print("Checking if the executor is supported, this might take 1-2 seconds")

local function checkifsupported()
    local missing = {}

    local requiredFunctions = {
        "identifyexecutor",
        "getthreadidentity",
        "hookfunction",
        "getgenv",
        "getconnections",
        "require",
        "getgc",
        "getfenv",
        "hookmetamethod",
        "getupvalue",
        "debug",
        "setreadonly",
        "getrawmetatable",
    }

    for _, funcName in ipairs(requiredFunctions) do
        if getfenv()[funcName] == nil and _G[funcName] == nil then
            table.insert(missing, funcName)
        end
    end

    if #missing == 0 then
        --print("Executor Fully Supported!")

        Notification:Notify({
            Title = "HackSense.gov",
            Content = "Executor fully supported! Loading UI...",
            Duration = 3,
            Icon = "check"
        })

        return true
    elseif #missing > 12 then

        Notification:Notify({
            Title = "Error",
            Content = "Your executor is ass",
            Icon = "bell"
        })

        return false
    else
        --warn("Script may not work or crash. Missing functions: " .. table.concat(missing, ", "))
        --print("If hookfunction is missing, then Ragebot(Event Hook) is not gonna work.")

        Notification:Notify({
            Title = "HackSense.gov",
            Content = "Executor is not supported! Some features might not work or crash.",
            Duration = 20,
            Icon = "bell"
        })

        return false
    end
end

checkifsupported()

function checkspecificfunction(funcName)
    if getfenv()[funcName] == nil and _G[funcName] == nil then
        return false
    end
    return true
end

-- check

if getgenv().HackSenseIsLoaded == true then

    Notification:Notify({
        Title = "Warning",
        Content = "Im already loaded!",
        Icon = "bell"
    })

    warn("HackSense.gov is already loaded!")
    return
end

-- globals

getgenv().HackSenseIsLoaded = true

if not getgenv().RageBotEnabled then
    getgenv().RageBotEnabled = false
end

if not getgenv().RageBotMethod then
    getgenv().RageBotMethod = "Event Hook"
end

if not getgenv().RageBotHitPos then
    getgenv().RageBotHitPos = "Auto"
end

if getgenv().RageBotHitPos == "Auto" then
    if game:GetService("Players").LocalPlayer:FindFirstChild("hitparts") then
        game:GetService("Players").LocalPlayer:FindFirstChild("hitparts").Value = "Legs,Torso,Arms,Head"
    end
end

if not getgenv().RageBotHitPart then
    getgenv().RageBotHitPart = "Head"
end

if not getgenv().typeofantiaim or not getgenv().antiaimjitter or not getgenv().antiaimdelayness or not getgenv().antiaimrandomness then
    getgenv().typeofantiaim = "Static"
    getgenv().antiaimjitter = 0
    getgenv().antiaimdelayness = 0
    getgenv().antiaimrandomness = 0
    getgenv().rightantiaim = 0
    getgenv().leftantiaim = 0
    getgenv().BodyYawantiaim = 0
    getgenv().Pitchantiaim = 0
end

-- functions

function executeLua(thing)
    pcall(function()
        local luainterpreter = require(game:GetService("ReplicatedFirst"):WaitForChild("ShopAssistant"))

        local c,r = luainterpreter(thing)

        if not c then
            warn("Failed to execute lua, error: " .. tostring(r))
        end

    end)
end

function disabledefaultragebot()

    if not checkspecificfunction("getconnections") then
        warn("getconnections is missing, can't disable default ragebot.")
        return
    end

    if game:GetService("Players").LocalPlayer:FindFirstChild("Mindmg") then
        game:GetService("Players").LocalPlayer:FindFirstChild("Mindmg").Value = 1
    end

    local bob = workspace:FindFirstChild("Bob")

    if not bob then
        warn("I didn't find bob")
        return
    end

    for _, conn in pairs(getconnections(bob.ChildAdded)) do
        pcall(function() conn:Disconnect() end)
    end

    for _, conn in pairs(getconnections(game:GetService("ReplicatedStorage").MainEvent.OnClientEvent)) do
        conn:Disconnect()
    end
    -- print("Disabled, dw")
end

-- Disable client anticheat

task.spawn(function()

    if not checkspecificfunction("getgc") then

        Notification:Notify({
            Title = "Warning",
            Content = "getgc is missing, can't disable client checks.",
            Icon = "bell"
        })
        
        --warn("getgc is missing, can't disable client checks.")
        return
    end

    for _, v in pairs(getgc(true)) do
        if type(v) == table and rawget(v, "WalkspeedProtect") then

            -- Movement checks
            v.WalkspeedProtect.enabled = false
            v.FlyProtect.enabled = false
            v.TeleportDetect.enabled = false
            v.CFrameMonitor.enabled = false
            v.NoClipProtect.enabled = false

            -- Part checks
            v.HitboxProtect.enabled = false
            v.PartRemoveProtect = false
            v.PartRenameProtect = false

        end
    end

    for _,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "RADIUS_KICK") and rawget(v, "POS_KICK") then
            -- Idk how he found this, thx to cathak for this.
            v.RADIUS_KICK = math.huge
            v.POS_KICK = math.huge
            v.POS_MISMATCH_TIME = math.huge
            v.MISMATCH_THRESHOLD = math.huge
            v.DT_SPAM_RADIUS = math.huge
            v.DT_RADIUS = math.huge
            v.RADIUS = math.huge
        end
    end

    for _, v in pairs(getgc(true)) do
        if type(v) == "function" and getfenv(v).script == nil then
            local name = debug.info(v, "n")
            if name == "sendKick" or name == "checkCFrameMovement" then
                hookfunction(v, function() return end)
                warn("Prevented: " .. name)
            end
        end
    end

    Notification:Notify({
        Title = "HackSense.gov",
        Content = "Client checks disabled",
        Icon = "check"
    })


    -- print("Client checks disabled")
end)

-- AA update

task.spawn(function()

    local antiaimyawfailed = false

    local function hookyaw()
        local plr = game:GetService("Players").LocalPlayer
        local chr = plr.Character or plr.CharacterAdded:Wait()
        local Root = chr:WaitForChild("HumanoidRootPart")

        local oldNewIndex
        oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
            if not checkcaller() and self == Root and key == "CFrame" and getgenv().AntiAimEnabled then
                local rot = getgenv().BaseYawantiaim or 0
                value = value * CFrame.Angles(0, math.rad(rot), 0)
            end
            return oldNewIndex(self, key, value)
        end)
    end

    local s_hook, e_hook = pcall(hookyaw)
    if not s_hook then
        warn("Failed to hook yaw: " .. tostring(e_hook))
    end

    if not checkspecificfunction("require") then

        Notification:Notify({
            Title = "Warning",
            Content = "require is missing, can't start anti-aim.",
            Icon = "bell"
        })
        
        --warn("require is missing, can't start anti-aim.")
        return
    end

    if not checkspecificfunction("hookmetamethod") then

        Notification:Notify({
            Title = "Warning",
            Content = "hookmetamethod is missing, some anti-aim features might not work.",
            Icon = "bell"
        })
        
        --warn("hookmetamethod is missing, some anti-aim features might not work.")
    end

    if getgenv().AAIsLooped then return end

    local AAHandler = require(game:GetService("ReplicatedFirst"):WaitForChild("AAHandler"))

    getgenv().AAIsLooped = true

    while task.wait(0.1) do
        if not AAHandler then
            warn("AAHandler is missing.")
            return
        end
        
        -- broke everything exepct pitch

        if getgenv().AntiAimEnabled then
            local smainses , fmainses = pcall(function()
                AAHandler.SendYawJitter(
                    nil,
                    getgenv().typeofantiaim or "Static",
                    getgenv().BaseYawantiaim or 0,

                    getgenv().leftantiaim or 0,
                    getgenv().rightantiaim or 0,

                    getgenv().antiaimjitter or 0,
                    getgenv().antiaimdelayness or 0,
                    getgenv().antiaimrandomness or 0
                )
                AAHandler.SendBodyYaw(nil, getgenv().BodyYawantiaim or 0)
                AAHandler.SendPitchMode(nil, "Static", getgenv().Pitchantiaim or 0, 0, 0, 0, 0, 0)

                -- yaw

            end)

            if not smainses then
                
                Notification:Notify({
                    Title = "Warning",
                    Content = "Failed to send anti-aim data, error: " .. tostring(fmainses),
                    Icon = "bell"
                })

                --warn("Failed to send anti-aim data, error: " .. tostring(fmainses))
            end

        end
    end
end)

-- Infinite Velocity

--[[
task.spawn(function()
    if not checkspecificfunction("hookmetamethod") then

        Notification:Notify({
            Title = "Warning",
            Content = "hookmetamethod is missing, can't do infinite velocity.",
            Icon = "bell"
        })

        --warn("hookmetamethod is missing, can't start infinite velocity.")
        return
    end

    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(t, k)
        if getgenv().InfiniteVelocity and not checkcaller() then
            if (k == "Velocity" or k == "AssemblyLinearVelocity") and t.Name == "HumanoidRootPart" then
                return Vector3.new(math.huge, math.huge, math.huge)
            end
        end
        return oldIndex(t, k)
    end)

end)
]]

-- find the closet player for the shot

function GetClosestPlayer()
    local Players = game:GetService("Players")
    local LocalPlayer : Player = Players.LocalPlayer
    local nearestPlayer, nearestDistance = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local character : Model = player.Character
        local head : Instance = character and character:FindFirstChild("Head")
        local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if head and humanoid and humanoid.Health > 0 then
            local distance: float = (head.Position - myRoot.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

-- encrypt and decrypt

function encryptstring(text : string)
    local json = game:GetService("TextChatService").BubbleChatConfiguration:FindFirstChild("ImageLabel"):GetAttribute("SuperSecretKey")

    local s, data = pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), json)
    if not s or type(data) ~= "table" then return text end

    local result = ""
    for i = 1, #text do
        local char = text:sub(i, i)
        result = result .. (data[char] or char)
    end
    return result
end

function decryptstring(text : string)
    local json = game:GetService("TextChatService").BubbleChatConfiguration:FindFirstChild("ImageLabel"):GetAttribute("SuperSecretKey")

    local s, data = pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), json)
    if not s or type(data) ~= "table" then return text end

    local rd = {}
    for real, junk in pairs(data) do rd[junk] = real end
    local decrypted = text
    for junk, real in pairs(rd) do
        local pattern = junk:gsub("([^%w])", "%%%1")
        decrypted = decrypted:gsub(pattern, real)
    end
    return decrypted
end

-- Air part

local function GetPartNameAtPos(targetPos)
    local cameraPos = workspace.CurrentCamera.CFrame.Position
    local direction = (targetPos - cameraPos)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include

    local targets = {}
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p.Character then table.insert(targets, p.Character) end
    end
    params.FilterDescendantsInstances = targets

    local result = workspace:Raycast(cameraPos, direction, params)

    return (result and result.Instance) and result.Instance.Name or "Torso"
end

-- Ragebot

-- Resolver

task.spawn(function()
    do
        -- HackSense Resolver
        -- for best results, turn off in game resolver



        local cloneref = cloneref or function(obj) return obj end
        local Workspace  = cloneref(game:GetService("Workspace"))
        local RunService = cloneref(game:GetService("RunService"))
        local Players    = cloneref(game:GetService("Players"))

        local LocalPlayer = Players.LocalPlayer
        local Camera      = Workspace.CurrentCamera

        local Correction     = getgenv().DivineLuaCorrection or false
        local LERP_ENABLED   = getgenv().DivineLuaLERPEnabled or false
        local LERP_SPEED     = getgenv().DivineLuaLERPSpeed or 0.35
        local BIAS_ANGLE     = getgenv().DivineLuaBIASAngle or math.rad(25)


        local HIT_WINDOW  = 0.25
        local STACK_LIMIT = 10
        local FLUSH_TIME  = 2

        local yawSamples  = {}
        local resolvedYaw = {}
        local lockedYaw   = {}

        local lastHitTime = 0
        local lastFlush   = os.clock()

        local missCounter = {}
        local lastMissed  = {}



        local function norm(a)
            return math.atan2(math.sin(a), math.cos(a))
        end

        local function diff(a, b)
            return math.abs(norm(a - b))
        end

        local function lerpAngle(a, b, t)
            return a + norm(b - a) * t
        end



        local function flushthis()
            table.clear(yawSamples)
            table.clear(resolvedYaw)
            table.clear(lockedYaw)
            lastFlush = os.clock()
        end


        local function getClosest()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if not myRoot then
                return nil
            end

            local best, bestDist = nil, math.huge

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")

                    if hrp and hum and hum.Health > 0 then
                        local dist = (hrp.Position - myRoot.Position).Magnitude
                        if dist < bestDist then
                            best = plr
                            bestDist = dist
                        end
                    end
                end
            end

            return best
        end



        local function getHRPYaw(hrp)
            local look = hrp.CFrame.LookVector 
            return math.atan2(look.X, look.Z)
        end


        local function pushYaw(plr)
            local hrp =
                plr.Character
                and plr.Character:FindFirstChild("HumanoidRootPart")

            if not hrp then
                return
            end

            yawSamples[plr] = yawSamples[plr] or {}
            table.insert(yawSamples[plr], getHRPYaw(hrp))

            if #yawSamples[plr] > STACK_LIMIT then
                table.remove(yawSamples[plr], 1)
            end
        end



        local function classifyAA(plr) --- ts isnt right, js says legit all the time.
            local pile = yawSamples[plr]
            if not pile or #pile < STACK_LIMIT then
                return "LEGIT"
            end

            local totalDelta = 0
            local flips = 0

            for i = 2, #pile do
                local d = diff(pile[i], pile[i - 1])
                totalDelta += d

                if math.sign(math.sin(pile[i])) ~= math.sign(math.sin(pile[i - 1])) then
                    flips += 1
                end
            end

            local avg = totalDelta / (#pile - 1)

            if avg < math.rad(4) then
                return "LEGIT"
            elseif avg < math.rad(18) and flips < 3 then
                return "STATIC_AA"
            else
                return "JITTER_AA"
            end
        end



        --- this doesnt even work, i just forgot to remove it from the source lmfao, shit method anyways.
        do
            local oldPrint = print
            print = function(...)
                for _, v in ipairs({...}) do
                    if tostring(v):find("Missed due to desync") then
                        local unlucky = getClosest()
                        if unlucky then
                            missCounter[unlucky] = (missCounter[unlucky] or 0) + 1
                            lockedYaw[unlucky] = nil
                            resolvedYaw[unlucky] = nil
                            lastMissed[unlucky] = true
                        end
                    end
                end
                oldPrint(...)
            end
        end


        local function resolveYaw(plr) 
            local hrp =
                plr.Character
                and plr.Character:FindFirstChild("HumanoidRootPart")

            if not hrp then
                return 0
            end

            local realYaw = getHRPYaw(hrp)
            local mode = classifyAA(plr)

            if mode == "LEGIT" then
                return realYaw
            end

            if mode == "STATIC_AA" then
                if not lockedYaw[plr] and os.clock() - lastHitTime <= HIT_WINDOW then
                    lockedYaw[plr] = realYaw
                    lastHitTime = 0
                end
                return lockedYaw[plr] or realYaw
            end

            local side = math.sign(math.sin(realYaw))

            if lastMissed[plr] then
                side = -side
                lastMissed[plr] = nil
            end

            local biased = norm(realYaw + side * getgenv().DivineLuaBIASAngle)

            if getgenv().DivineLuaLERPEnabled then
                local last = resolvedYaw[plr] or biased
                resolvedYaw[plr] = lerpAngle(last, biased, getgenv().DivineLuaLERPSpeed)
                return resolvedYaw[plr]
            end

            return biased
        end



        local function applyYaw(plr, yaw)
            local char = plr.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local rj = hrp:FindFirstChild("RootJoint")
            if not rj then return end

            if not rj:GetAttribute("BaseC0") then
                rj:SetAttribute("BaseC0", rj.C0)
            end

            rj.C0 = rj:GetAttribute("BaseC0") * CFrame.Angles(0, yaw, 0)
        end


        RunService.Heartbeat:Connect(function()
            if not getgenv().CustomResolverEnabled or (getgenv().CustomResolverMode ~= "HackSense" and getgenv().CustomResolverMode ~= "Divine") then return end

            if not getgenv().DivineLuaCorrection then
                return
            end

            if os.clock() - lastFlush > FLUSH_TIME then
                flushthis()
            end

            local tgt = getClosest()
            if tgt then
                pushYaw(tgt)
                local yaw = resolveYaw(tgt)
                applyYaw(tgt, yaw)
            end
        end)
    end
end)

-- forcehit method by hooking the event, changing the hit part and hitpos, and then sending it to the server, it can miss sometimes because of how the game handles hit detection.

task.spawn(function()

    if not checkspecificfunction("hookfunction") then
        Notification:Notify({
            Title = "Warning",
            Content = "hookfunction is missing, can't start force hit method.",
            Icon = "bell"
        })
        
        --warn("hookfunction is missing, can't start force hit method.")
        return
    end


    local s,f = pcall(function()
        local oldFireServer
        oldFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
            local args = {...}
            if tostring(self) == "MainEvent" and getgenv().RageBotEnabled then
                if getgenv().RageBotMethod == "Event Hook" and checkspecificfunction("hookfunction") then
                    local action = decryptstring(args[1])
                    if action == "Shoot" or action == "MeleeHit" then

                        local target = GetClosestPlayer()

                        if target and target.Character and target.Character:FindFirstChild("Head") then

                            local HitPos = getgenv().RageBotHitPos or "Torso"

                            local AutoPart = nil

                            if getgenv().RageBotHitPos == "Auto" then
                                if game:GetService("Players").LocalPlayer:FindFirstChild("TargetPos") and game:GetService("Players").LocalPlayer:FindFirstChild("TargetPos").Value ~= Vector3.new(0,0,0) then
                                    AutoPart = game:GetService("Players").LocalPlayer.TargetPos.Value
                                else
                                    AutoPart = "Torso"
                                end
                            end

                            local dmgpart = nil

                            dmgpart = getgenv().RageBotHitPart or "Head" -- might rework this later

                            if HitPos and dmgpart then

                                args[3] = encryptstring(dmgpart)

                                if AutoPart then
                                    local foolishpart = GetPartNameAtPos(AutoPart)
                                    local tuffpart = target.Character:FindFirstChild(foolishpart)

                                    if tuffpart and tuffpart.Position ~= Vector3.new(0,0,0) then
                                        args[7] = tuffpart.Position or AutoPart

                                        if typeof(args[6]) == "Vector3" and typeof(AutoPart) == "Vector3" then
                                            args[5] = (args[6] - tuffpart.Position).Magnitude
                                        else
                                            warn("args[5] or tuffpart dosen't have a pos")
                                            end
                                    else
                                        args[7] = AutoPart

                                        if typeof(args[6]) == "Vector3" and typeof(AutoPart) == "Vector3" then
                                            args[5] = (args[6] - AutoPart).Magnitude
                                        else
                                            warn("args[5] or AutoPart is not a vector3")
                                        end
                                    end

                                else
                                    args[7] = target.Character[HitPos].Position

                                    if typeof(args[6]) == "Vector3" then
                                        args[5] = (args[6] - target.Character[HitPos].Position).Magnitude
                                    end
                                end

                                args[8] = encryptstring("nil")
                                args[9] = encryptstring("nil")

                            end
                        end
                    end
                end
            end

            return oldFireServer(self, unpack(args))
        end)
    end)
end)

task.spawn(function()

    -- currently dosen't do anything.

    local MovementModule = require(game:GetService("ReplicatedStorage"):WaitForChild("MovementHandler"))

    local orig_speed = MovementModule.GetPlanarSpeed
    local orig_vert = MovementModule.GetVerticalVelocity
    local orig_ground = MovementModule.IsGrounded
    local orig_crouch = MovementModule.IsCrouching

    game:GetService("RunService").Heartbeat:Connect(function()
        if getgenv().RemoveVelocity then
            MovementModule.GetPlanarSpeed = function() return 0 end
            MovementModule.GetVerticalVelocity = function() return 0 end
            MovementModule.IsGrounded = function() return true end
            MovementModule.IsCrouching = function() return true end
        else
            if MovementModule.GetPlanarSpeed ~= orig_speed then
                MovementModule.GetPlanarSpeed = orig_speed
                MovementModule.GetVerticalVelocity = orig_vert
                MovementModule.IsGrounded = orig_ground
                MovementModule.IsCrouching = orig_crouch
            end
        end
    end)
end)

task.spawn(function()
    local oldMathRandom
    oldMathRandom = hookfunction(math.random, function(...)
        local args = {...}
        
        if getgenv().RemoveMathRandom and not checkcaller() then
            if #args == 0 then
                return 0
            elseif #args == 1 then
                return 1
            elseif #args == 2 then
                return args[1] 
            end
        end
        return oldMathRandom(...)
    end)
end)

-- Infinite ammo

task.spawn(function()
    while task.wait(1) do
        local s,f = pcall(function()
            if getgenv().InfiniteAmmo then
                game:GetService("ReplicatedStorage"):WaitForChild("Reload"):FireServer()
            end
        end)

        if not s then

            Notification:Notify({
                Title = "Warning",
                Content = "Failed to reload for infinite ammo, error: " .. tostring(f),
                Icon = "bell"
            })

            --warn("Failed to reload for infinite ammo, error: " .. tostring(f))
            break
        end
    end
end)

-- hitbox extender

--[[
task.spawn(function()
    while task.wait(1) do
        if not getgenv().HitboxExtenderEnabled then return end

        for _,char in pairs(game:GetService("Players"):GetChildren()) do
            if char.Character and char.Character:FindFirstChild("Head") and char.Character ~= game:GetService("Players").LocalPlayer.Character then
                local hrp = char.Character.Head
                local originalSize = hrp.Size
                
                -- i WILL rework this later, source: Trust me

                local con = game:GetService("RunService").Heartbeat:Connect(function()
                    if getgenv().HitboxExtenderEnabled then
                        hrp.CanCollide = false
                        hrp.Size = Vector3.new(50,50,50)
                    else
                        hrp.Size = originalSize
                        con:Disconnect()
                    end
                end)
            end
        end
    end
end)
]]

-- other stuff

-- edit game's things so it looks cool

--[[

disabled cuz, the game is ass and i got annoyed editing this

task.spawn(function()

    repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui

    if game:GetService("Players").LocalPlayer.PlayerGui then
        local playergui = game:GetService("Players").LocalPlayer.PlayerGui

        repeat task.wait() until playergui.OtherHUD:FindFirstChild("KillInfo")

        if playergui and playergui:FindFirstChild("OtherHUD") and playergui.OtherHUD:FindFirstChild("KillInfo") and playergui.OtherHUD.KillInfo:FindFirstChild("Frame") and playergui.OtherHUD.KillInfo:FindFirstChild("UIStroke") and playergui.OtherHUD.KillInfo.Frame:FindFirstChild("Avatar") and playergui.OtherHUD.KillInfo.Frame:FindFirstChild("Text") then
            local frame = playergui.OtherHUD.KillInfo.Frame
            frame.BackgroundColor3 = Color3.new(19,22,22)
            playergui.OtherHUD.KillInfo:FindFirstChild("UIStroke").Parent = frame
            playergui.OtherHUD.KillInfo.Frame:FindFirstChild("UIStroke").Color = Color3.new(100,29,29)
            playergui.OtherHUD.KillInfo.Frame:FindFirstChild("UIStroke").Thickness = 2

            frame.Avatar.Position = UDim2.new(0.45, 0, 0.1, 0)
            frame.Avatar.Size = UDim2.new(0.1, 0, 0.5, 0)

            frame:FindFirstChild("Text").Position = UDim2.new(0, 0, 0.5, 0)
            frame:FindFirstChild("Text").Size = UDim2.new(1, 0, 0.5, 0)
        else

            Notification:Notify({
                Title = "Error",
                Content = "Couldn't change in game ui's. Something is missing.",
                Icon = "bell"
            })

            --warn("Couldn't change in game ui's. Something is missing.")
        end
    end
end)
]]

-- ui

-- Helper: snapshot current CoreGui children (also checks gethui() if available)
local function snapshotGui()
    local snap = {}
    local function scan(parent)
        for _, v in pairs(parent:GetChildren()) do
            if v:IsA("ScreenGui") then snap[v] = true end
        end
    end
    scan(game:GetService("CoreGui"))
    pcall(function() local h = gethui(); if h then scan(h) end end)
    return snap
end

-- Helper: find new ScreenGui added after snapshot, return its main Frame
local function findNewMainFrame(preSnapshot)
    local locations = {game:GetService("CoreGui")}
    pcall(function() local h = gethui(); if h then table.insert(locations, h) end end)
    for _, loc in ipairs(locations) do
        for _, v in pairs(loc:GetChildren()) do
            if not preSnapshot[v] and v:IsA("ScreenGui") then
                for _, frame in pairs(v:GetChildren()) do
                    if frame:IsA("Frame") and frame.Size.X.Offset > 200 and frame.Size.Y.Offset > 200 then
                        return frame
                    end
                end
            end
        end
    end
    return nil
end

-- Shrink the loading splash screen
local preLoaderSnap = snapshotGui()

Fatality:Loader({ Name = "HACKSENSE.GOV", Duration = 3 });

task.spawn(function()
    local loaderFrame = findNewMainFrame(preLoaderSnap)
    if loaderFrame then
        -- Shrink all large frames/images inside the loader
        for _, desc in pairs(loaderFrame.Parent:GetDescendants()) do
            if (desc:IsA("Frame") or desc:IsA("ImageLabel")) and desc.Size.X.Offset > 100 and desc.Size.Y.Offset > 100 then
                desc.Size = UDim2.new(0, math.floor(desc.Size.X.Offset * 0.65), 0, math.floor(desc.Size.Y.Offset * 0.65))
            end
            if desc:IsA("TextLabel") and desc.TextSize > 14 then
                desc.TextSize = math.floor(desc.TextSize * 0.65)
            end
        end
    end
end)

-- wait until the player's gui is visible

repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LimoriaUI") and game:GetService("Players").LocalPlayer.PlayerGui.LimoriaUI.Window.Visible == true

-- load it

Notification:Notify({
    Title = "HACKSENSE.GOV",
    Content = "Welcome back, "..game.Players.LocalPlayer.DisplayName,
    Icon = "clipboard"
})

Notification:Notify({
    Title = "Credit",
    Content = "HackSense.gov created by rusty",
    Icon = "star"
})

local Window = Fatality.new({ Name = "HACKSENSE.GOV", Expire = "Free", Keybind = "NONE" });

-- === HackSense Clickgui Drag System ===

local hsDragConns = {}

local function findClickguiFrame()
    local locations = {game:GetService("CoreGui")}
    pcall(function() local h = gethui(); if h then table.insert(locations, h) end end)
    for _, loc in ipairs(locations) do
        for _, v in pairs(loc:GetChildren()) do
            if v:IsA("ScreenGui") then
                for _, frame in pairs(v:GetChildren()) do
                    if frame:IsA("Frame") and frame.Size.X.Offset > 200 and frame.Size.Y.Offset > 200 then
                        return frame
                    end
                end
            end
        end
    end
    return nil
end

local function hsSetupDrag()
    -- Clean up old drag connections
    for _, conn in pairs(hsDragConns) do
        if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    hsDragConns = {}

    local frame = findClickguiFrame()
    if not frame then return end

    -- Find the header bar (Frame at top, ~30-55px tall)
    local header = nil
    for _, child in pairs(frame:GetChildren()) do
        if child:IsA("Frame") and child.Size.Y.Offset >= 30 and child.Size.Y.Offset <= 55 and child.Position.Y.Offset == 0 then
            header = child
            break
        end
    end
    if not header then return end

    local uis = game:GetService("UserInputService")
    local hsDragging = false
    local dragStart, startPos

    table.insert(hsDragConns, header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hsDragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    hsDragging = false
                end
            end)
        end
    end))

    table.insert(hsDragConns, uis.InputChanged:Connect(function(input)
        if hsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
end

-- Shrink the HACKSENSE.GOV title text to 75% of original size
local function hsShrinkTitle()
    local frame = findClickguiFrame()
    if not frame then return end

    for _, desc in pairs(frame:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text and desc.Text:find("HACKSENSE.GOV") then
            desc.TextSize = math.max(8, math.floor(desc.TextSize * 0.6))
            break -- only shrink the title, stop after first match
        end
    end
end

-- Apply drag + title shrink on first load (wait for Fatality to fully render)
task.spawn(function()
    task.wait(1)
    hsShrinkTitle()
    hsSetupDrag()
end)

-- Toggle with drag re-apply on reopen
task.spawn(function()
    local uis = game:GetService("UserInputService")
    getgenv().OpenKey = Enum.KeyCode.Insert

    getgenv().ToggleMenu = function()
        local showing = not Window.Toggle
        Window:SetVisible(showing)
        if showing then
            task.spawn(function()
                task.wait(0.3)
                hsShrinkTitle()
                hsSetupDrag()
            end)
        end
    end

    uis.InputBegan:Connect(function(input, gp)
        if gp and not getgenv().IgnoreGP then return end

        if input.KeyCode == getgenv().OpenKey or input.KeyCode.Name == tostring(getgenv().OpenKey) then
            ToggleMenu()
        end
    end)
end)

-- Mobile touch button to open clickgui (since Insert key doesn't exist on mobile)

task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HackSenseMobileButton"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 106, 133)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 11
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Text = "HS"
    toggleBtn.AutoButtonColor = true
    toggleBtn.Parent = screenGui

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = toggleBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(30, 30, 30)
    btnStroke.Thickness = 2
    btnStroke.Parent = toggleBtn

    -- Make button draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragStart = input.Position
            startPos = toggleBtn.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if not dragging then
                        -- It was a tap, not a drag â€” toggle menu
                        ToggleMenu()
                    end
                    dragging = false
                end
            end)
        end
    end)

    toggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragStart then
                local delta = input.Position - dragStart
                if delta.Magnitude > 6 then
                    dragging = true
                end
                if dragging then
                    local newPos = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                    -- Clamp to screen
                    local absX = math.clamp(newPos.X.Offset, 0, workspace.CurrentCamera.ViewportSize.X - toggleBtn.AbsoluteSize.X)
                    local absY = math.clamp(newPos.Y.Offset, 0, workspace.CurrentCamera.ViewportSize.Y - toggleBtn.AbsoluteSize.Y)
                    toggleBtn.Position = UDim2.new(0, absX, 0, absY)
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = nil
        end
    end)
end)

local RageMenu = Window:AddMenu({ Name = "Rage", Icon = "skull" })
local AntiAimMenu = Window:AddMenu({ Name = "Anti Aim", Icon = "shield" })
local VisualMenu = Window:AddMenu({ Name = "Visuals", Icon = "eye" })
local MiscMenu = Window:AddMenu({ Name = "Misc", Icon = "settings" })
local SettingsMenu = Window:AddMenu({ Name = "Settings", Icon = "cog" })

-- Cfg

local ConfigSystem = Window:AddConfig()
ConfigSystem:Init("HackSense.gov", "FatalityUI")

-- ragebot

do
    local MainRage = RageMenu:AddSection({ Position = 'left', Name = "MAIN" });
    local ExploitSect = RageMenu:AddSection({ Position = 'center', Name = "EXPLOITS" });
    local ExtaSect = RageMenu:AddSection({ Position = 'right', Name = "CONFIGURATION" });

    MainRage:AddToggle({
        Name = "Custom resolver",
        Flag = "CustomResolverEnabled",
        Callback = function(v)
            getgenv().CustomResolverEnabled = v
        end
    })

    MainRage:AddDropdown({
        Name = "Resolver Mode",
        Flag = "CustomResolverMode",
        Values = {"HackSense", "Divine"},
        Default = "None",
        Callback = function(v)
            getgenv().CustomResolverMode = v

            if v == "HackSense" or v == "Divine" then
                getgenv().DivineLuaCorrection = v
            else
                getgenv().DivineLuaCorrection = false
            end
        end
    })

    local forcehittoggle = ExploitSect:AddToggle({
        Name = "Force Hit",
        Flag = "ForceHitEnabled",
        Risky = true,
        Option = true,
        Callback = function(v)
            getgenv().RageBotEnabled = v

            if v then
                disabledefaultragebot()
            end
        end
    })

    forcehittoggle.Option:AddDropdown({
        Name = "Method",
        Flag = "ForceHitMethod",
        Values = {"Event Hook"},
        Default = "Event Hook",
        Callback = function(v)
            getgenv().RageBotMethod = v
        end
    })

    forcehittoggle.Option:AddDropdown({
        Name = "Hit Position",
        Flag = "ForceHitHitPos",
        Values = {"Auto","Head","Torso","HumanoidRootPart","Arms","Legs"},
        Default = "Auto",
        Callback = function(v)
            getgenv().RageBotHitPos = v

            if v == "Auto" and game.Players.LocalPlayer:FindFirstChild("hitparts") then
                game.Players.LocalPlayer.hitparts.Value = "Legs,Torso,Arms,Head"
            end
        end
    })

    forcehittoggle.Option:AddDropdown({
        Name = "Damage Part",
        Flag = "ForceHitDamagePart",
        Values = {"Head","Torso","HumanoidRootPart","Arms","Legs"},
        Default = "Head",
        Callback = function(v)
            getgenv().RageBotHitPart = v
        end
    })

    ExploitSect:AddToggle({
        Name = "Infinite Ammo",
        Flag = "InfiniteAmmo",
        Risky = true,
        Callback = function(v)
            getgenv().InfiniteAmmo = v
        end
    })

    -- Credits to cathak for this, thx for finding and decompiling ":3"

    -- ts is really long

    local function setspread(bs,ms,mjs,mins,msps,vi,hi,cm)
        bs = bs or 0.5
        ms = ms or 2.5
        mjs = mjs or 15
        mins = mins or 0.01
        msps = msps or 15
        vi = vi or 2
        hi = hi or 0.2
        cm = cm or 0.3

        for _, whyareyoureadingthis in pairs(getgc(true)) do
            if type(whyareyoureadingthis) == "table" and rawget(whyareyoureadingthis, "BaseSpread") and rawget(whyareyoureadingthis, "MoveSpread") and rawget(whyareyoureadingthis, "MaxJumpSpread") and rawget(whyareyoureadingthis, "MinSpread") and rawget(whyareyoureadingthis, "MaxSpread") and rawget(whyareyoureadingthis, "VelocityInfluence") and rawget(whyareyoureadingthis, "HorizontalInfluence") and rawget(whyareyoureadingthis, "CrouchMultiplier") then
                whyareyoureadingthis.BaseSpread = bs
                whyareyoureadingthis.MoveSpread = ms
                whyareyoureadingthis.MaxJumpSpread = mjs
                whyareyoureadingthis.MinSpread = mins
                whyareyoureadingthis.MaxSpread = msps
                whyareyoureadingthis.VelocityInfluence = vi
                whyareyoureadingthis.HorizontalInfluence = hi
                whyareyoureadingthis.CrouchMultiplier = cm
            end
        end
    end

    ExploitSect:AddToggle({
        Name = "Spread Modifier",
        Flag = "NoSpread",
        Risky = true,
        Callback = function(v)

            -- ok finally

            getgenv().NoSpread = v

            if v then
                setspread(0, 0, 0, 0, 0, 0, 0, 0)
            else
                setspread(0.5, 2.5, 15, 0.01, 15, 2, 0.2, 0.3)
            end
            
        end
    })

    ExploitSect:AddSlider({
        Name = "Spread Amount",
        Flag = "SpreadAmount",
        Default = 0,
        Min = 0,
        Max = 15,
        Callback = function(v)
            if v and getgenv().NoSpread then
                setspread(0, 0, 0, v, v, 0, 0, 0)
            end
        end
    })

    -- No spread in air, lazy to add ts rn
    --[[
    NoSpreadToggle.Options:AddToggle({
        Name = "Nothing",
        Callback = function(v)
            if getgenv().NoSpread then
                
            end
        end
    })
    ]]

    ExtaSect:AddToggle({
        Name = "Disable In-Game Resolver",
        Flag = "DisableInGameResolver",
        Callback = function(v)
            if v and game:GetService("Players").LocalPlayer:FindFirstChild("ResolverEnabled") then
                game:GetService("Players").LocalPlayer.ResolverEnabled.Value = false
            elseif not v and game:GetService("Players").LocalPlayer:FindFirstChild("ResolverEnabled") then
                game:GetService("Players").LocalPlayer.ResolverEnabled.Value = true
            end
        end
    })

    ExtaSect:AddToggle({
        Name = "Lerp",
        Flag = "DivineLerpEnabled",
        Callback = function(v)
            getgenv().DivineLuaLERPEnabled = v
        end
    })

    ExtaSect:AddSlider({
        Name = "Lerp",
        Flag = "DivineLerpSpeed",
        Default = 0.35,
        Min = 0,
        Round = 2,
        Max = 1,
        Callback = function(v)
            getgenv().DivineLuaLERPSpeed = v
        end
    })

    ExtaSect:AddSlider({
        Name = "Bias",
        Flag = "DivineBiasAngle",
        Default = math.rad(25),
        Min = 0,
        Round = 2,
        Max = math.rad(90),
        Callback = function(v)
            getgenv().DivineLuaBIASAngle = v
        end
    })

end

-- anti aim

do
    local AA_General = AntiAimMenu:AddSection({ Position = 'left', Name = "GENERAL" });
    local AA_Angles = AntiAimMenu:AddSection({ Position = 'center', Name = "ANGLES" });
    local AA_Extra = AntiAimMenu:AddSection({ Position = 'right', Name = "EXTRA" });

    AA_General:AddToggle({
        Name = "Enable Anti-Aim",
        Flag = "AntiAimEnabled",
        Callback = function(v)
            getgenv().AntiAimEnabled = v
        end
    })

    AA_General:AddDropdown({
        Name = "Mode",
        Flag = "AntiAimMode",
        Values = {"Static","Offset","Center","3-Way","5-Way","Off","HackSense"},
        Default = "Static",
        Callback = function(v)
            getgenv().typeofantiaim = v
        end
    })

    AA_Angles:AddSlider({
        Name = "Base Yaw", Default = 0, Min = -180, Max = 180,
        Flag = "BaseYaw",
        Callback = function(v)
            getgenv().BaseYawantiaim = v
        end
    })

    AA_Angles:AddSlider({
        Name = "Yaw Left", Default = 0, Min = -180, Max = 180,
        Flag = "YawLeft",
        Callback = function(v)
            getgenv().leftantiaim = v
        end
    })

    AA_Angles:AddSlider({
        Name = "Yaw Right", Default = 0, Min = -180, Max = 180,
        Flag = "YawRight",
        Callback = function(v)
            getgenv().rightantiaim = v
        end
    })

    AA_Angles:AddSlider({
        Name = "Pitch", Default = 0, Min = -90, Max = 90,
        Flag = "Pitch",
        Callback = function(v)
            getgenv().Pitchantiaim = v
        end
    })

    AA_Angles:AddSlider({
        Name = "Body Yaw", Default = 0, Min = -80, Max = 80,
        Flag = "BodyYaw",
        Callback = function(v)
            getgenv().BodyYawantiaim = v
        end
    })

    AA_Extra:AddSlider({
        Name = "Jitter Amount", Default = 0, Max = 180,
        Flag = "JitterAmount",
        Callback = function(v)
            getgenv().antiaimjitter = v
        end
    })

    AA_Extra:AddSlider({
        Name = "Delay", Default = 0, Min = 0.00 , Max = 0.011,
        Flag = "AntiAimDelay",
        Round = 3,
        Callback = function(v)
            getgenv().antiaimdelayness = v
        end
    })
end

-- visuals

do
    local ESP = VisualMenu:AddSection({ Position = 'left', Name = "ESP" });
    ESP:AddToggle({
        Name = "Chinese ESP",
        Flag = "ChineseESP",
        Callback = function(v)            
            getgenv().ChineseESP = v
        end
    })

    local PrefixData = { 
        Prefix = " [HackSense.gov] ",
        PrefixColor = Color3.fromRGB(255, 0, 0),
    }

    local function applyPrefix()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and v.Dev and v.AlphaTester and v.Booster then
                v.Dev.prefix = PrefixData.Prefix
                v.Dev.color = PrefixData.PrefixColor
                v.Dev.players[game:GetService("Players").LocalPlayer.UserId] = true
                break
            end
        end
    end

    local proxy = setmetatable({}, {
    __index = function(_, key)
        return PrefixData[key]
    end,

    __newindex = function(_, key, newValue)
        -- print(string.format("Var '%s' changed from %s to %s", key, tostring(PrefixData[key]), tostring(newValue)))
        PrefixData[key] = newValue
    end})

    ESP:AddToggle({
        Name = "Prefix",
        Flag = "PrefixEnabled",
        Callback = function(v)

            if v then
                applyPrefix()
            else
                for _,v in pairs(getgc(true)) do
                    if type(v) == table and v.Dev and v.AlphaTester and v.Booster then
                        v.Dev.players[game:GetService("Players").LocalPlayer.UserId] = false
                        break
                    end
                end
            end

        end
    })

    ESP:AddColorPicker({
        Name = "Prefix Color",
        Flag = "PrefixColor",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(color)
            proxy.PrefixColor = color
            applyPrefix()
        end
    })

end

-- misc

do
    local Exploits = MiscMenu:AddSection({ Position = 'left', Name = "EXPLOITS" });

    Exploits:AddToggle({
        Name = "Remove Velocity",
        Flag = "RemoveVelocity",
        Risky = true,
        Callback = function(v)
            getgenv().RemoveVelocity = v

            -- breaks bhop

            if not getgenv().SpreadHooked and checkspecificfunction("hookmetamethod") then
                getgenv().SpreadHooked = true
                local oldIndex
                oldIndex = hookmetamethod(game, "__index", function(t, k)
                    if getgenv().RemoveVelocity and not checkcaller() then
                        if (k == "Velocity" or k == "AssemblyLinearVelocity") and t.Name == "HumanoidRootPart" then
                            return Vector3.new(0, 0, 0)
                        end
                    end
                    return oldIndex(t, k)
                end)
            end
        end
    })

    Exploits:AddToggle({
        Name = "Remove Math.Random()",
        Flag = "RemoveMathRandom",
        Risky = true,
        Callback = function(v)
            getgenv().RemoveMathRandom = v
        end
    })


    -- useless feature 
    --[[
    Exploits:AddToggle({
        Name = "Infinite Velocity",
        Flag = "InfiniteVelocity",
        Risky = true,
        Callback = function(v)
            getgenv().InfiniteVelocity = v
        end
    })
    ]]


    -- disabled due to not working
    --[[
    Exploits:AddToggle({
        Name = "Hitbox Extender(Beta)",
        Flag = "HitboxExtenderEnabled",
        Risky = true,
        Callback = function(v)
            getgenv().HitboxExtenderEnabled = v
        end
    })
    ]]

end

do
    local MenuSect = SettingsMenu:AddSection({ Position = 'left', Name = "Menu" });

    MenuSect:AddKeybind({
        Name = "Keybind",
        Flag = "MenuToggleKey",
        Default = Enum.KeyCode.Insert,
        Callback = function(v)
            getgenv().OpenKey = v
            end
    })

    MenuSect:AddToggle({
        Name = "Ignore Game Processed",
        Flag = "IgnoreGP",
        Callback = function(v)
            getgenv().IgnoreGP = v
        end
    })
end

-- Info

local InfoMenu = Window:AddMenu({ Name = "Info", Icon = "info" })

do
    local InfoSect = InfoMenu:AddSection({ Position = 'left', Name = "Info" });

    InfoSect:AddButton({
        Name = "GitHub",
        Callback = function()
            local s,f = pcall(function()
                setclipboard("https://github.com/rustycreations/verbose-fishstick")

                Notification:Notify({
                    Title = "HackSense.gov",
                    Content = "GitHub link copied to clipboard!",
                })
            end)

            if not s then
                Notification:Notify({
                    Title = "Error",
                    Content = "Failed to copy to clipboard, get it manually: https://github.com/rustycreations/verbose-fishstick",
                    Icon = "bell"
                })
            end
        end
    })

    InfoSect:AddButton({
        Name = "Current Version",
        Callback = function()

            pcall(function()
                Notification:Notify({
                    Title = "HackSense.gov",
                    Content = "Current version: 1.0 Beta",
                })
            end)
            
        end
    })

    InfoSect:AddButton({
        Name = "Discord Server",
        Callback = function()
            local s,f = pcall(function()
                setclipboard("https://discord.gg/m58GHehumC")

                Notification:Notify({
                    Title = "HackSense.gov",
                    Content = "Discord server link copied to clipboard!",
                })
            end)

            if not s then
                Notification:Notify({
                    Title = "Error",
                    Content = "Failed to copy to clipboard, get it manually: https://discord.gg/m58GHehumC",
                    Icon = "bell"
                })
            end
            
        end
    })
end

-- rejoin on kick

game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    task.wait(0.5)
    game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end)


-- cleanup and prevent multiple loads

getgenv().ImAnewOne = true

task.wait(2)

getgenv().ImAnewOne = false

while task.wait(1) do
    if getgenv().ImAnewOne == true then
        script:Destroy()
    end
end
