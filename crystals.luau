local BuffApplier = require(script.Parent.Parent.BuffApplier)
local NREnum = require(game:GetService("ReplicatedStorage"):WaitForChild("NoReplication"):WaitForChild("EnumData")).Enums

local module = {}
module.CrystalId = 0

module.Crystals = {
	[NREnum.CrystalColor.Pink] = {
		Buffs = {
			["CaveExclusiveLuck"] = 100;
			["CaveOreLuck"] = 100;
			["CaveTypeLuck"] = 100;
		};
		Duration = 15;
	};
	[NREnum.CrystalColor.Purple] = {
		Buffs = {
			["AllRate"] = 75;
		};
		Duration = 15;
	};
	[NREnum.CrystalColor.Red] = {
		Buffs = {
			["PickaxeRate"] = 50;
			["GearRate"] = 75;
		};
		Duration = 15;
	};
	[NREnum.CrystalColor.Green] = {
		Buffs = {
			["LayerLuck"] = 50;
		};
		Duration = 15;
	};
	[NREnum.CrystalColor.Blue] = {
		Buffs = {
			["AddedWalkSpeed"] = 1;
			["AddedJumpPower"] = 1;
		};
		Duration = 15;
	};
}

function module.CrystalMined(Player : Player, BuffService, CrystalType)
	local Crystal = module.Crystals[CrystalType]
	
	module.CrystalId += 1
	local ThisId =`Crystal_{tostring(module.CrystalId)}`
	
	local Character = Player.Character
	local Humanoid : Humanoid = Character and Character:FindFirstChild("Humanoid")
	
	if not Humanoid then
		return
	end
	
	local HDC
	HDC = Humanoid.Died:Once(function()
		BuffService:RemoveNormalBuff(ThisId,{
			["AddedJumpPower"] = true;
			["AddedWalkSpeed"] = true;
		})
	end)
	
	local NewCrystalTable = {
		Duration = Crystal.Duration;
		Buffs = table.clone(Crystal.Buffs);
		BuffService = BuffService;
		TickedTime = 0;
		DeathConnection = HDC;
	}
	
	BuffService:ApplyNormalBuff(ThisId,NewCrystalTable.Buffs)
	BuffApplier.ActiveBuffs[ThisId] = NewCrystalTable
end

return module
