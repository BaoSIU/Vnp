-- autoboss.lua

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local beli = plr:WaitForChild("Data"):WaitForChild("Belis")

local NPCName = _G.NameNpc or "Boss"
local RewardValue = tonumber(_G.Rewardvalue) or 1000000

-- Bộ đếm riêng để giữ lại giá trị không bị reset
local beliCounter = beli.Value

-- Giữ cho Beli không bị tụt về số cũ
beli:GetPropertyChangedSignal("Value"):Connect(function()
    if beli.Value < beliCounter then
        beli.Value = beliCounter
    end
end)

-- Hàm cộng tiền
local function AddBeli()
    beliCounter = beliCounter + RewardValue
    beli.Value = beliCounter
    print("[+] "..NPCName.." die, +"..RewardValue.." Beli. Tổng:", beliCounter)
end

-- Hàm theo dõi boss
local function WatchBoss(boss)
    -- Humanoid
    local hum = boss:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function()
            AddBeli()
        end)
    end
    -- Value Health/HP
    for _, obj in pairs(boss:GetDescendants()) do
        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
            if string.lower(obj.Name):find("health") or string.lower(obj.Name):find("hp") then
                obj.Changed:Connect(function(new)
                    if tonumber(new) and new <= 0 then
                        AddBeli()
                    end
                end)
            end
        end
    end
end

-- Theo dõi boss trong folder
local npcFolder = workspace:WaitForChild("NPC DAMAGE")

-- Boss hiện có
local boss = npcFolder:FindFirstChild(NPCName)
if boss then
    WatchBoss(boss)
end

-- Boss spawn lại
npcFolder.ChildAdded:Connect(function(child)
    if child.Name == NPCName then
        task.wait(1)
        WatchBoss(child)
    end
end)
