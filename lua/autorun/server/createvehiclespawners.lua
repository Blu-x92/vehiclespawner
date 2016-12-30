
local Spawners = {
	["gm_carcon_ws"] = {
		{
			pos = Vector(-433,-658,-14591.719),
			ang = Angle(0,0,0),
			team = "Cops and Mayor only",
			vehicle = "sim_fphys_dukes",
		},
		{
			pos = Vector(-250,-658,-14591.719),
			ang = Angle(0,0,0),
			team = "Cops and Mayor only",
			vehicle = "sim_fphys_jeep",
		},
	},
	["rp_rockford_v1b"] = {
		{
			pos = Vector(-8662,-4865,0),
			ang = Angle(0,0,0),
			team = "GOVERNMENT",
			vehicle = "sim_fphys_conscriptapc",
		},
		{
			pos = Vector(-8368,-4931,0),
			ang = Angle(0,0,0),
			team = "GOVERNMENT",
			vehicle = "sim_fphys_conscriptapc",
		},
	}
}

local function WouldYouKindlyCheck(This)

	local ok = list.Get( "simfphys_vehicles" )[ This ]
	if not ok then 
		print(This.." does not exist")
		return false
	end
	
	return This
end

local function CreateSpawnersPlease()
	local map = game.GetMap()
	local myfiles = Spawners[map]
	
	if myfiles and istable( myfiles ) then
		for i = 1, table.Count( myfiles ) do
			
			local pos = myfiles[i].pos
			local ang = myfiles[i].ang
			local team = myfiles[i].team
			local vehicle = WouldYouKindlyCheck( myfiles[i].vehicle )
			
			if pos and ang and vehicle then
				local ent = ents.Create( "sent_simfphys_vehicle_spawner" )
				ent:SetPos( pos )
				ent:SetAngles( ang )
				ent:Spawn()
				ent:Activate()
				ent.vehicle = vehicle
				ent.team = team
			end
		end
		return true
	end
	return false
end

hook.Add( "InitPostEntity", "simfphysvehiclespawner", function()
	CreateSpawnersPlease()
end )

--[[
hook.Add("OnPlayerChangedTeam", "RemoveAutospawnedVehicles", function(ply, oldTeam)
	for k, v in pairs(ents.FindByClass("gmod_sent_vehicle_fphysics_base")) do
		if (v:getDoorOwner() == ply) and (v.AutoSpawned == true) then
			v:Remove()
		end
	end
end)
]]--

--[[
concommand.Add( "vehiclespawner_reload", function( ply, cmd, args )
	ply:PrintMessage( HUD_PRINTTALK, "Removing existing spawners")
	
	for k, v in pairs( ents.FindByClass( "sent_simfphys_vehicle_spawner" ) ) do
		v:Remove()
	end
	timer.Simple( 0.1, function()
		local ok = CreateSpawnersPlease()
		if ok then
			ply:PrintMessage( HUD_PRINTTALK, "Done")
		else
			ply:PrintMessage( HUD_PRINTTALK, "No data for this map found.")
		end
	end)
end )
]]--