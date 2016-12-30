AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include('shared.lua')

function ENT:Initialize()	
	self:SetModel( "models/props_junk/sawblade001a.mdl" )
	
	self:PhysicsInit( SOLID_NONE  )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE   )
	self:SetNotSolid( true )
	self:DrawShadow( false ) 
	self.DoNotDuplicate = true
end

local function MakeLuaVehicle( Pos, Ang, Model, Class, VName, VTable, data )

	if (!file.Exists( Model, "GAME" )) then 
		return
	end
	
	local Ent = ents.Create( "gmod_sent_vehicle_fphysics_base" )
	if ( !Ent ) then return NULL end

	duplicator.DoGeneric( Ent, data )
	
	Ent:SetModel( Model )
	Ent:SetAngles( Ang )
	Ent:SetPos( Pos )

	DoPropSpawnedEffect( Ent )

	Ent:Spawn()
	Ent:Activate()

	Ent.VehicleName = VName
	Ent.VehicleTable = VTable
	--Ent.EntityOwner = Player
	
	timer.Simple( 0.15, function()
		if (IsValid(Ent)) then
			Ent:SetSpawn_List( VName )
		end
	end)

	return Ent

end

function ENT:CreateVehicle( vname, pos, ang )
	local VehicleList = list.Get( "simfphys_vehicles" )
	local vehicle = VehicleList[ vname ]

	if ( !vehicle ) then return end
	
	local Angles = ang
	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 180 + (vehicle.SpawnAngleOffset and vehicle.SpawnAngleOffset or 0)
	
	local pos = pos + Vector(0,0,25) + (vehicle.SpawnOffset or Vector(0,0,0))
	
	local Ent = MakeLuaVehicle(pos, Angles, vehicle.Model, vehicle.Class, vname, vehicle )
	self.spawnedvehicle = Ent
	
	if ( vehicle.Members ) then
		table.Merge( Ent, vehicle.Members )
		duplicator.StoreEntityModifier( Ent, "VehicleMemDupe", vehicle.Members )
	end
	
	Ent.IsLocked = true
	Ent.AutoSpawned = true
	
	timer.Simple( 0.02, function()
		if (!IsValid(Ent)) then return end
		
		if (Ent.ModelInfo) then
			if (Ent.ModelInfo.Bodygroups) then
				for i = 1, table.Count( Ent.ModelInfo.Bodygroups ) do
					Ent:SetBodygroup(i, Ent.ModelInfo.Bodygroups[i] ) 
				end
			end
			
			if (Ent.ModelInfo.Skin) then
				Ent:SetSkin( Ent.ModelInfo.Skin )
			end
			
			if (Ent.ModelInfo.Color) then
				Ent:SetColor( Ent.ModelInfo.Color )
				
				local Color = Ent.ModelInfo.Color
				local dot = Color.r * Color.g * Color.b * Color.a
				Ent.OldColor = dot
				
				local data = {
					Color = Color,
					RenderMode = 0,
					RenderFX = 0
				}
				duplicator.StoreEntityModifier( Ent, "colour", data )
			end
		end
		
		Ent:SetTireSmokeColor(Vector(180,180,180) / 255)
		
		Ent.Turbocharged = Ent.Turbocharged or false
		Ent.Supercharged = Ent.Supercharged or false
		
		Ent:SetEngineSoundPreset( Ent.EngineSoundPreset )
		Ent:SetSteerSpeed( Ent.TurnSpeed )
		Ent:SetMaxTorque( Ent.PeakTorque )
		Ent:SetDifferentialGear( Ent.DifferentialGear )
		Ent:SetFastSteerConeFadeSpeed( Ent.SteeringFadeFastSpeed )
		Ent:SetEfficiency( Ent.Efficiency )
		Ent:SetMaxTraction( Ent.MaxGrip )
		Ent:SetTractionBias( Ent.GripOffset / Ent.MaxGrip )
		Ent:SetPowerDistribution( Ent.PowerBias )
		
		Ent:SetBackFire( Ent.Backfire or false )
		Ent:SetDoNotStall( Ent.DoNotStall or false )
		
		Ent:SetIdleRPM( Ent.IdleRPM )
		Ent:SetLimitRPM( Ent.LimitRPM )
		Ent:SetRevlimiter( Ent.Revlimiter or false )
		Ent:SetPowerBandEnd( Ent.PowerbandEnd )
		Ent:SetPowerBandStart( Ent.PowerbandStart )
		
		Ent:SetTurboCharged( Ent.Turbocharged )
		Ent:SetSuperCharged( Ent.Supercharged )
		Ent:SetBrakePower( Ent.BrakePower )
		
		Ent:SetLights_List( Ent.LightsTable or "no_lights" )
		
		Ent:keysLock()
		if (self.team) then
			Ent:setDoorGroup(self.team)
		end
	end )
	
	
	if (Ent:GetModel( ) == "models/apc/apc.mdl") then
		timer.Simple( 0.2, function()
			if (!IsValid(vehicle)) then return end
			if (vname == "sim_fphys_conscriptapc_armed") then
				table.insert(armedAPCSTable, Ent)
			end
		end)
	end
	
	if (Ent:GetModel( ) == "models/vehicles/buggy_elite.mdl") then
		timer.Simple( 0.2, function()
			if (!IsValid(vehicle)) then return end
			if (vname == "sim_fphys_v8elite_armed") then
				table.insert(armedJEEPSTable, Ent)
				vehicle:SetBodygroup(1,1)
			end
		end)
	end
end

function ENT:Think()
	if (!self.spawnedvehicle or !IsValid(self.spawnedvehicle)) then
		local pos = self:GetPos()
		local ang = self:GetAngles()
		local vehicle = self.vehicle
		self:CreateVehicle( vehicle, pos, ang )
	end
	
	self:NextThink(CurTime() + 10)
	return true
end