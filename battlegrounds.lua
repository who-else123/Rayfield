if getgenv().thread then
    getgenv().thread:Disconnect()
    getgenv().thread = nil
end

local function getService(service)
	local ser = game:GetService(service)
	return ser and cloneref and cloneref( ser )
end

local coreGui = getService("CoreGui")
local players = getService("Players")
local replicatedStorage = getService("ReplicatedStorage")
local debris = getService("Debris")
local runService = getService("RunService")
local teleportService = getService("TeleportService")
local httpService = getService("HttpService")
local textChatService = getService("TextChatService")
local tweenService = getService("TweenService")

local localPlayer = players.LocalPlayer
local usercharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

localPlayer.CharacterAdded:Connect(function(char)
    usercharacter = char
end)

local serverFX = workspace:WaitForChild(".Ignore"):WaitForChild(".ServerEffects")
local collecting = false

local function collect(object)
    if not usercharacter or not usercharacter:FindFirstChild("HumanoidRootPart") then
        repeat task.wait() until usercharacter and usercharacter:FindFirstChild("HumanoidRootPart")
    end

    if not object then return end

    local rootPart = usercharacter.HumanoidRootPart
    local oldCFrame = rootPart.CFrame

    for _ = 1, 3, 1 do
        if not object then continue end
        rootPart.CFrame = object.CFrame

        task.wait(0.1)
        firetouchinterest(usercharacter.HumanoidRootPart, object, 1)
        task.wait()
        firetouchinterest(usercharacter.HumanoidRootPart, object, 0)
        task.wait(0.1)
    end

    usercharacter.HumanoidRootPart.CFrame = oldCFrame
    collecting = false
end

local function rejoin()
    local bestServer = nil
    local mostPlayers = -1

    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    local body = httpService:JSONDecode(req)

    if body and body.data then
        for i, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.playing > mostPlayers and v.id ~= game.JobId then
                bestServer = v.id
                mostPlayers = v.playing
            end
        end
    end

    if bestServer then
        queueonteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/who-else123/Rayfield/refs/heads/main/battlegrounds.lua'))()")
        teleportService:TeleportToPlaceInstance(game.PlaceId, bestServer, localPlayer)
    else
        task.wait(10)
        return rejoin()
    end
end


local function isShard(child)
    if child:IsA("BasePart") and child.Name == "Shard" and child.Color == Color3.fromRGB(255,255,0) then
        return true
    end
end

local function isDiamond(child)
    if child:isA("BasePart") and child.Name == "Diamond" and child.Color == Color3.fromRGB(0,255,255) then
        return true
    end
end

local onChildAdded = function(child)
    if isShard(child) or isDiamond(child) then
        if collecting then repeat task.wait() until not collecting end
        collecting = true

        if not usercharacter or usercharacter:FindFirstChild("HumanoidRootPart") then
            repeat task.wait() until usercharacter and usercharacter:FindFirstChild("HumanoidRootPart")
        end

        print("Collecting "..child.Name)
        task.spawn(collect, child)
    end
end

for _, child in pairs(serverFX:GetChildren()) do
    onChildAdded(child)
end
getgenv().thread = serverFX.ChildAdded:Connect(onChildAdded)

while task.wait(1) do
    local playing = #players:GetPlayers()
    if playing <= 6 then
        rejoin()
    end
end
