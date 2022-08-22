// All rights reserved. https://github.com/darkfated/small-glua/blob/master/LICENSE

DarkFatedPropSystem = DarkFatedPropSystem or {}
DarkFatedPropSystem.AntiProp = {
	physgun_stop_motion_on_drop = true,
	physgun_disallow_pushing = true,
	physgun_prop_transparancy = true,
	deny_entity_damage = true,
	deny_player_owned_prop_damage_only = false,
	delay_entity_damage = 15,
	deny_vehicle_damage = true,
}

local HookRun = 0
local HookRunDelay = 0.05

hook.Add( 'PhysgunPickup', 'AntiPropPhysgunPickup', function( ply, ent )
	if ( ent:IsPlayer() ) then
		return
	end

	if ( not ent:IsValid() ) then
		return false
	end

	if ( HookRun + HookRunDelay > CurTime() ) then
		return
	end

	HookRun = CurTime()

	local Can = hook.Call( 'PhysgunPickup', nil, ply, ent )

	if ( not Can and Can != nil ) then
		return false
	end

	local Props = ent:IsConstrained() and constraint.GetAllConstrainedEntities( ent ) or {}

	table.insert( Props, ent )

	for k, v in pairs( Props ) do
		v.lm = CurTime()

		if ( timer.Exists( 'AntiPropTimer' .. ' - ' .. tostring( ent:EntIndex() ) .. ' - ' .. tostring( ent:GetCreationTime() ) ) ) then
			timer.Destroy( 'AntiPropTimer' .. ' - ' .. tostring( ent:EntIndex() ) .. ' - ' .. tostring( ent:GetCreationTime() ) )
		end

		if ( ply:GetGroundEntity() == v ) then
			ply:SetPos( ply:GetPos() )
		end

		if ( not DarkFatedPropSystem.AntiProp.physgun_disallow_pushing ) then
			return
		end

		if ( not v:IsPlayer() ) then
			if ( DarkFatedPropSystem.AntiProp.physgun_prop_transparancy ) then
				if ( not v.renderMode ) then
					v.renderMode = v:GetRenderMode()
				end

				v.OldColor = v:GetColor()

				v:SetColor( Color( v.OldColor.r, v.OldColor.g, v.OldColor.b, 100 ) )
				v:SetRenderMode( 1 )
			end

			v.OldColGroup = v:GetCollisionGroup()
			v:SetCollisionGroup( 20 )
		end
	end
end )

local function DontLockMeIn( ent )
	if ( ent:IsPlayer() ) then
		return
	end

	if ( not IsValid( ent ) ) then
		return
	end

	local Colliding = ents.FindInSphere( ent:LocalToWorld( ent:OBBCenter() ), ent:BoundingRadius() )

	for k, v in pairs( Colliding ) do
		if ( v:IsPlayer() and not v:InVehicle() and not tobool( v:GetObserverMode() ) ) then
			if ( ent:NearestPoint( v:NearestPoint( ent:GetPos() ) ):Distance( v:NearestPoint( ent:GetPos() ) ) <= 20 ) then
				timer.Create( 'AntiPropTimer' .. ' - ' .. tostring( ent:EntIndex() ) .. ' - ' .. tostring( ent:GetCreationTime() ), 0.1, 1, function()
					DontLockMeIn( ent )
				end )

				return false
			end
		end
	end

	if ( ent.OldColGroup != nil ) then
		if ( ent.OldColGroup == 20 ) then
			ent.OldColGroup = 0
		end

		if ( DarkFatedPropSystem.AntiProp.physgun_prop_transparancy and ent.OldColor ) then
			ent:SetColor( Color( ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a ) )
			ent:SetRenderMode( ent.renderMode or 0 )
		end

		ent:SetCollisionGroup( ent.OldColGroup )

		ent.OldColGroup = nil
	end

	return true
end

hook.Add( 'PhysgunDrop', 'AntiPropPhysgunDrop', function( ply, ent )
	if ( not ent:IsValid() ) then
		return false
	end

	ent.lm = CurTime()

	if ( not DarkFatedPropSystem.AntiProp.physgun_disallow_pushing ) then
		return
	end

	local Props = ent:IsConstrained() and constraint.GetAllConstrainedEntities( ent ) or {}

	table.insert( Props, ent )

	for _, prop in pairs( Props ) do
		if ( prop.OldColGroup ) then
			DontLockMeIn( prop )
		end
	end

	if ( not DarkFatedPropSystem.AntiProp.physgun_stop_motion_on_drop ) then
		return
	end

	for k, v in pairs( Props ) do
		local Phys = v:GetPhysicsObject()

		if ( Phys:IsValid() and Phys:IsMotionEnabled() ) then
			Phys:EnableMotion( false )
		end
	end
end )

hook.Add( 'OnPhysgunFreeze', 'AntiPropPhysgunFreezing', function( weapon, physobj, ent )
	if ( not ent:IsValid() ) then
		return false
	end

	ent.lm = CurTime()

	local Props = ent:IsConstrained() and constraint.GetAllConstrainedEntities( ent ) or {}

	table.insert( Props, ent )

	for _, prop in pairs( Props ) do
		local Colliding = ents.FindInSphere( prop:LocalToWorld( prop:OBBCenter() ), prop:BoundingRadius() )

		for k, v in pairs( Colliding ) do
			if ( v:IsPlayer() and v:GetObserverMode() ) then
				if ( prop:NearestPoint( v:NearestPoint( prop:GetPos() ) ):Distance( v:NearestPoint( prop:GetPos() ) ) <= 20 ) then
					DarkRP.notify( weapon:GetOwner(), NOTIFY_ERROR, 1.5, 'Слишком близко для заморозки!' )

					return false
				end
			end
		end
	end
end )

hook.Add( 'CanPlayerUnfreeze', 'AntiPropPhysgunUnfreeze', function( ply, ent, physobj )
	return false
end )

hook.Add( 'GravGunOnDropped', 'AntiPropGravGunOnDropped', function( ply, ent )
	ent.lm = CurTime()
end )

hook.Add( 'GravGunOnPickedUp', 'AntiPropGravGunOnPickedUp', function( ply, ent )
	ent.lm = CurTime()
end )

hook.Add( 'OnEntityCreated', 'AntiPropOnEntityCreated', function( ent )
	if ( IsValid( ent ) ) then
		ent.lm = CurTime()
	end
end )

local function AddOwnerShipTag( ply, ent, _ )
	if ( IsValid( _ ) ) then
		ent = _
	end

	if ( IsValid( ent ) ) then
		ent.EntityOwner = ply:UniqueID()

		if ( not DarkFatedPropSystem.AntiProp.physgun_disallow_pushing ) then
			return
		end

		if ( not ent.OldColGroup and not ent:IsPlayer() ) then
			if ( DarkFatedPropSystem.AntiProp.physgun_prop_transparancy ) then
				if ( not ent.renderMode ) then
					ent.renderMode = ent:GetRenderMode()
				end

				ent.OldColor = ent:GetColor()

				ent:SetColor( Color( ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, 100 ) )
				ent:SetRenderMode( 1 )
			end

			ent.OldColGroup = ent:GetCollisionGroup()

			ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		end

		DontLockMeIn( ent )
	end
end

hook.Add( 'PlayerSpawnedEffect', 'AntiPropTagEffect', AddOwnerShipTag )
hook.Add( 'PlayerSpawnedNPC', 'AntiPropTagNPC', AddOwnerShipTag )
hook.Add( 'PlayerSpawnedProp', 'AntiPropTagProp', AddOwnerShipTag )
hook.Add( 'PlayerSpawnedRagdoll', 'AntiPropTagRagdoll', AddOwnerShipTag )
hook.Add( 'PlayerSpawnedSENT', 'AntiPropTagSENT', AddOwnerShipTag )
hook.Add( 'PlayerSpawnedSWEP', 'AntiPropTagSWEP', AddOwnerShipTag )
hook.Add( 'PlayerSpawnedVehicle', 'AntiPropTagVehicle', AddOwnerShipTag )

hook.Add( 'EntityTakeDamage', 'AntiPropPreventPropDamage', function( target, damageinfo )
	local Attacker = damageinfo:GetAttacker()

	if ( not Attacker:IsPlayer() and ( not DarkFatedPropSystem.AntiProp.deny_player_owned_prop_damage_only or tonumber( Attacker.EntityOwner ) ) ) then
		if ( not damageinfo:IsFallDamage() and damageinfo:GetDamageType() == DMG_CRUSH ) then
			if ( DarkFatedPropSystem.AntiProp.deny_entity_damage ) then
				damageinfo:ScaleDamage( 0 )
			else
				if ( Attacker:IsWorld() or ( Attacker.lm and ( Attacker.lm + DarkFatedPropSystem.AntiProp.delay_entity_damage ) > CurTime() ) ) then
					damageinfo:ScaleDamage( 0 )
				end
			end
		end
	end

	if ( DarkFatedPropSystem.AntiProp.deny_vehicle_damage ) then
		if ( target:IsPlayer() and ( Attacker:IsVehicle() or ( bit.band( damageinfo:GetDamageType(), DMG_VEHICLE ) != 0 ) ) ) then
			damageinfo:ScaleDamage( 0 )
		end
	end
end )

local function SpawnPropPlayer( ply, model, ent )
	if ( not DarkFatedPropSystem.AntiProp.physgun_stop_motion_on_drop ) then
		return
	end

	local Phys = ent:GetPhysicsObject()

	if ( IsValid( Phys ) ) then
		Phys:EnableMotion( false )
	end
end

hook.Add( 'PlayerSpawnedProp', 'AntiPropGhost', SpawnPropPlayer )
hook.Add( 'PlayerSpawnedEffect', 'AntiPropGhost', SpawnPropPlayer )
hook.Add( 'PlayerSpawnedRagdoll', 'AntiPropGhost', SpawnPropPlayer )
