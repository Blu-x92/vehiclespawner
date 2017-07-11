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

function ENT:CreateVehicle( vname, pos, ang )
	local VehicleList = list.Get( "simfphys_vehicles" )
	local vehicle = VehicleList[ vname ]
	
	if not vehicle then return end
	
	local Angles = ang
	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 180 + (vehicle.SpawnAngleOffset and vehicle.SpawnAngleOffset or 0)
	
	local pos = pos + Vector(0,0,25) + (vehicle.SpawnOffset or Vector(0,0,0))
	
	local Ent = simfphys.SpawnVehicleSimple( vname, pos, ang )
	self.spawnedvehicle = Ent
	
	timer.Simple( 0.2, function()
		if not IsValid( Ent ) then return end
		if not simfphys then return end
		if not simfphys.RegisterEquipment then return end
		
		simfphys.RegisterEquipment( Ent )
	end)
	
	if self.Locked then
		Ent:Lock()
	end
	
	if self.team and Ent.setDoorGroup then
		Ent:setDoorGroup(self.team)
	end
end

function ENT:Think()
	if not self.spawnedvehicle or not IsValid(self.spawnedvehicle) then
		local pos = self:GetPos()
		local ang = self:GetAngles()
		local vehicle = self.vehicle
		self:CreateVehicle( vehicle, pos, ang )
	end
	
	self:NextThink(CurTime() + 10)
	return true
end