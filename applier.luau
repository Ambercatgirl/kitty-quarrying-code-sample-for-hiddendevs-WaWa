local RunService = game:GetService("RunService")

local module = {}
module.ActiveBuffs = {}
module.Checking = false

function module.BuffDurationChecking()
	local RSC
	local Total = 0
	local CurrentTime = os.clock()

	RSC = RunService.Heartbeat:Connect(function(d)
		local Now = os.clock()
		local Diff = Now-CurrentTime
		CurrentTime = Now

		for BuffId, BuffInfo in pairs(module.ActiveBuffs) do
			BuffInfo.TickedTime += Diff

			if BuffInfo.TickedTime < BuffInfo.Duration then
				continue
			end

			local RemovalTable = {}
			for Key,_ in pairs(BuffInfo.Buffs) do
				RemovalTable[Key] = true;
			end

			if BuffInfo.DeathConnection then
				BuffInfo.DeathConnection:Disconnect()
				BuffInfo.DeathConnection = nil
			end

			BuffInfo.BuffService:RemoveNormalBuff(BuffId,RemovalTable)
			module.ActiveBuffs[BuffId] = nil
		end

		if not next(module.ActiveBuffs) then
			RSC:Disconnect()
			RSC = nil
			module.Checking = false
			return
		end
	end)
end

local Meta = {
	__newindex = function(IndexingTable,Index,Value)
		rawset(IndexingTable,Index,Value)
		if not module.Checking then
			module.Checking = true
			module.BuffDurationChecking()
		end
	end
}
setmetatable(module.ActiveBuffs,Meta)

return module
