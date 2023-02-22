Class Dinosaur extends tk_Monster
	config(tk_Monsters);

#EXEC OBJ LOAD FILE="Resources/tk_Dinotopia_rc.u" PACKAGE="tk_Dinotopia"

var() Name DeathAnim;
var() Name SleepAnim;
var() Name CallAnim;
var() Name RoarAnim;
var() Name EatAnim;
var() Name MeleeAnims[2];
var() Name VictoryAnim;
var() Name RangedAttackAnims[2];
var() Name TailSwipeAnims[2];
var() Name TailAttackBoneName;
var() Name RangedBoneName; //if you plan on making a dino shoot projectiles, this is te bone name you need to set (as well as the projectile class & bHasRangedAttack), where the projectile will spawn. Look at the Dilophosaurus for an example.
var() Name ChargeAnim;

var() Material FemaleSkin;
var() Material MaleSkin;
var() Material FemaleZombieSkin;
var() Material MaleZombieSkin;
//var() Material NullEntropyMat;

var() Sound RoarSounds[2];
var() Sound CallSounds[2];
var() Sound MeleeAttackSounds[2];
var() Sound FootStepSounds[2];
var() Sound TailSwipeSound;

var() int TailBoneRadius;
var() int AimError;
var() config int StompDamage; //brach, camara, when they stomp with 2 feet
var() config int MeleeDamage;
var() config int TailDamage; //anky, brach, camara, stegys etc...
// var() config int HP; //Declared in base_m class

var() bool bOverlayFix;
var() config bool bUseHealth;
var() config bool bUseSpeed;
var() config bool bCanLunge; //raptor, dryo etc..
var() config bool bHasRangedAttack; //for dilopho + any other future crazy dinos that will no doubt shoot redeemers...
var() config bool bFemale;
var() config bool bRandomSex;
var() config bool bCanBeTeleFrag;
var() config bool bZombie;
var() config bool bHasTailAttack; //brach, camara, anky, stegys etc...
var() config bool bCanCharge; //Pachy, Homalo //not currently implemented
var() config bool bPaleo; //not currently implemented
var() config bool bHerbivore; //not currently implemented
var() config bool bNeutral;

var() config float CallIntervalTime;
var() config float RangedAttackInterval;
var() config float RoarIntervalTime;
var() config float GroundShakeStrength;
var() config float LungeIntervalTime;
var() config float GroundShakeRadius;
var() config float DinoSpeedMultiplier;

//var() array<string> InvalidOverlays[5];
var() config string ProjectileClassName;

struct InvalidOverlays
{
	var() String InvalidOverlay;
	var() Material ReplacementMat;
};

var() array<InvalidOverlays> OverlaySet[2];

//var() class<Projectile> ProjectileClass;
var() class<Controller> PaleoControllerClass;

//Constantly updated variables
var float LastRangedAttackTime;
var float LastCallTime;
var float LastRoarTime;
var float LastLungeTime;
var vector TailBoneLocation;
var bool bLunging;
var bool bCharging;
var Private float PreChargeSpeed;

Replication
{
	reliable if(Role == Role_Authority)
		bFemale, bRandomSex, bZombie, GroundShakeStrength;
}

simulated function PostBeginPlay()
{
	Super(xPawn).PostBeginPlay();
	if(bRandomSex)
	{
		bFemale = fRand() > 0.5;
	}
	SexChange();
	if(Role == Role_Authority)
	{
		if(bUseHealth)
		{
			Health = HP;
			HealthMax = HP;
		}

		if(bUseSpeed)
		{
			GroundSpeed *= DinoSpeedMultiplier;
			AirSpeed *= DinoSpeedMultiplier;
			WaterSpeed *= DinoSpeedMultiplier;
		}

		if ( (ControllerClass != None) && (Controller == None) )
		{
			//if(bPaleo && bHerbivore)
			if(bNeutral)
			{
				Controller = spawn(PaleoControllerClass);
			}
			else
			{
				Controller = spawn(ControllerClass);
			}
		}
		if ( Controller != None )
		{
			Controller.Possess(self);
			MyAmmo = spawn(AmmunitionClass);
		}
	}
}

simulated function SexChange()
{
	if(bFemale)
	{
		if(bZombie)
		{
			Skins[0] = FemaleZombieSkin;
		}
		else
		{
			Skins[0] = FemaleSkin;
		}
	}
	else
	{
		if(bZombie)
		{
			Skins[0] = MaleZombieSkin;
		}
		else
		{
			Skins[0] = MaleSkin;
		}
	}
}

event EncroachedBy( actor Other )
{
    if(bCanBeTeleFrag)
    {
		Super.EncroachedBy(Other);
	}
}

function RangedAttack(Actor A)
{
	local float Dist;
	//local Name CurrentState;

	if ( bShotAnim || bCharging)
	{
		return;
	}
	Dist = VSize(A.Location - Location);

	if(Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
	{
		SetAnimAction(MeleeAnims[Rand(2)]);
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
		bShotAnim = true;
	}
	else if(bHasRangedAttack && Level.TimeSeconds - LastRangedAttackTime > RangedAttackInterval)
	{
		SetAnimAction(RangedAttackAnims[Rand(2)]);
		LastRangedAttackTime = Level.TimeSeconds;
		bShotAnim = true;
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else if(fRand() > 0.8 && Level.TimeSeconds - LastCallTime > CallIntervalTime)
	{
		SetAnimAction(CallAnim);
		LastCallTime = Level.TimeSeconds;
		bShotAnim = true;
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else if(fRand() > 0.8 && Level.TimeSeconds - LastRoarTime > RoarIntervalTime)
	{
		SetAnimAction(RoarAnim);
		LastRoarTime = Level.TimeSeconds;
		bShotAnim = true;
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else if(bHasTailAttack && CheckTail())
	{
		SetAnimAction(TailSwipeAnims[Rand(2)]);
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
		bShotAnim = true;
	}
	else if(!bLunging && bCanLunge && Dist < 500 && Level.TimeSeconds - LastLungeTime > LungeIntervalTime)
	{
		LastLungeTime = Level.TimeSeconds;
		bLunging = true;
		Enable('Bump');
		SetAnimAction('Jump_Start');
		bShotAnim = true;
		Velocity = 700 * Normal(A.Location + A.CollisionHeight * vect(0,0,0.75) - Location);
		if ( Dist > CollisionRadius + A.CollisionRadius + 35 )
		{
			Velocity.Z += 0.7 * Dist;
		}
		SetPhysics(PHYS_Falling);
	}
	/*else if(bCanCharge && Dist > 1000 && FastTrace(A.Location,Location))
	{
		bShotAnim = true;
		CurrentState = GetStateName();
		if(CurrentState != 'Dying' && CurrentState != 'Charging')
		{
			GoToState('Charging');
		}
	}*/
}

State Charging
{
	function Charging()
	{
		if(Controller != None && Controller.Target != None)
		{
			if(vSize(Controller.Target.Location - Location) <= MeleeRange + CollisionRadius + Controller.Target.CollisionRadius )
			{
				Controller.bPreparingMove = true;
				Controller.Destination = Location + 110 * (Normal(Location - Controller.Target.Location) + VRand());
				GoToState('');
			}
		}
		else
		{
			GoToState('');
		}
	}

	function BeginState()
	{
		local int i;

		if(Controller != None && Controller.Target != None)
		{
			for(i=0;i<3;i++)
			{
				MovementAnims[i] = ChargeAnim;
			}

			bCharging = true;
			Controller.bPreparingMove = true;
			Acceleration = vect(0,0,0);
			PreChargeSpeed = GroundSpeed;
			GroundSpeed *= 2;
			Velocity *= GroundSpeed/2;
			bShotAnim = true;
		}
		else
		{
			GoToState('');
		}
	}

	simulated function EndState()
	{
		local int i;

		for(i=0;i<3;i++)
		{
			MovementAnims[i] = default.MovementAnims[i];
		}

		GroundSpeed = PreChargeSpeed;
		bShotAnim = false;
		bCharging = false;
	}

Begin:
	Sleep(0.2);
	Charging();
	GoTo'Begin';
}

singular function Bump(actor Other)
{
    local name Anim;
    local float frame,rate;

    if ( bShotAnim && bLunging )
    {
        bLunging = false;
        GetAnimParams(0, Anim,frame,rate);
        if ( Anim == 'Jump_Start' )
        {
            MeleeAttack();
		}
    }
    else if(bShotAnim && bCharging)
    {
		MeleeAttack();
	}

    Super.Bump(Other);
}

simulated function Landed(vector HitNormal)
{
	bLunging = false;
	Super.Landed(HitNormal);
}

function MeleeAttack()
{
	if(Controller != None && Controller.Target != None)
	{
		MeleeDamageTarget(MeleeDamage, (30000 * Normal(Controller.Target.Location - Location)));
		PlaySound(MeleeAttackSounds[Rand(2)], SLOT_Interact);
	}
}

function PlayVictoryAnimation()
{
	PlayVictory();
}

function PlayVictory()
{
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlayAnim(VictoryAnim, 1.0, 0.1);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}

simulated function PlayFootSteps()
{
	PlaySound(FootStepSounds[Rand(2)],SLOT_Misc,4);
	if(GroundShakeStrength > 0)
	{
		ShakeCamera(GroundShakeStrength);
	}
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    PlayDirectionalHit(HitLocation);

    if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
        return;

    LastPainSound = Level.TimeSeconds;
    PlaySound(HitSound[Rand(4)], SLOT_Pain,2*TransientSoundVolume,,200);
}

function PlayRoar()
{
	PlaySound(RoarSounds[Rand(2)],SLOT_Interact);
}

function PlayCall()
{
	PlaySound(CallSounds[Rand(2)],SLOT_Interact);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
	PlayAnim(DeathAnim,, 0.1);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
}

function PlayMoverHitSound()
{
	PlaySound(HitSound[0], SLOT_Interact);
}

function bool SameSpeciesAs(Pawn P)
{
	if(Controller != None && Monster(P) != None && Monster(P).Controller != None)
	{
		/*if(bPaleo && !bHerbivore)
		{
			//Controller.Trigger(P,P);
			if(Dinosaur(P) != None)
			{
				if( P.Controller.IsA('PetController') || (Controller.IsA('FriendlyMonsterController') && P.Controller.IsA('FriendlyMonsterController')) )
				{
					return true;
				}
				else if(Dinosaur(P).bHerbivore)
				{
					return false;
				}
			}
		}*/

		return CompareControllers(Controller,Monster(P).Controller);
	}

	return false;
}

function bool CompareControllers(Controller A, Controller B)
{
	if(A.class == B.class)
	{
		return true;
	}

	if( (A.IsA('MonsterController') && B.IsA('SMPNaliFighterController')) || (A.IsA('SMPNaliFighterController') && B.IsA('MonsterController')) )
	{
		return true;
	}

	if( A.IsA('PetController') || B.IsA('PetController') )
	{
		return true;
	}

	if( (A.IsA('FriendlyMonsterController') && B.IsA('PlayerController')) || (B.IsA('FriendlyMonsterController') && A.IsA('PlayerController')) )
	{
		return true;
	}

	return false;
}

simulated function ShakeCamera(int ShakeStrength)
{
	local PlayerController PC;
	local float Dist, Scale;
	local vector ShakeRotPower;
	local vector ShakeOffsetPower;

    if( Level.NetMode != NM_DedicatedServer )
    {
		PC = Level.GetLocalPlayerController();
		if(PC != None && PC.ViewTarget != None)
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			//if player is within groundshake radius, then full power!
			if(Dist < GroundShakeRadius)
			{
            	Scale = 1.0;
			}
			else //else scale the power
			{
				Scale = (GroundShakeRadius*2.0 - Dist) / (GroundShakeRadius);
			}
			//Clamp the scale so it doesn't go into negative numbers
			Scale = FClamp( Scale, 0, 1);
			ShakeRotPower.Z = 100 * ShakeStrength;
			ShakeOffsetPower.Z = 10 * ShakeStrength;
			PC.ShakeView( ShakeRotPower*Scale, vect(0.0,0.00,500) ,2, ShakeOffsetPower*Scale, vect(0.0,0.00,100),2);
		}
	}
}

function TailAttack()
{
	local vector PushDir;
	local Pawn P;

	PlaySound(TailSwipeSound, SLOT_Interact);
	TailBoneLocation = GetBoneCoords(TailAttackBoneName).Origin;
	foreach VisibleCollidingActors(class'Pawn',P,TailBoneRadius,TailBoneLocation,true)
	{
		if(P != None && !SameSpeciesAs(P))
		{
			PushDir = 30000 * Normal(P.Location - Location);
			PushDir.Z += 1000;
			TailDamageTarget(P, TailDamage, PushDir);
		}
	}
}

function bool CheckTail()
{
	local Pawn P;

	TailBoneLocation = GetBoneCoords(TailAttackBoneName).Origin;
	foreach VisibleCollidingActors(class'Pawn',P,TailBoneRadius,TailBoneLocation,true)
	{
		if(P != None && !SameSpeciesAs(P))
		{
			return true;
		}
	}

	return false;
}

function bool TailDamageTarget(Pawn P, int hitdamage, vector pushdir)
{
    local vector HitLocation, HitNormal;
    local actor HitActor;

    If ( (P != None) && (VSize(P.Location - TailBoneLocation) <= TailBoneRadius * 1.4 + P.CollisionRadius + CollisionRadius)
        && ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(TailBoneLocation.Z - P.Location.Z)
            <= FMax(CollisionHeight, P.CollisionHeight) + 0.5 * FMin(CollisionHeight, P.CollisionHeight))) )
    {
        HitActor = Trace(HitLocation, HitNormal, P.Location, TailBoneLocation, false);
        if ( HitActor != None )
            return false;
        P.TakeDamage(hitdamage, self,HitLocation, pushdir, class'MeleeDamage');
        return true;
    }
    return false;
}

function bool CheckShakePhysics(Pawn P)
{
	if(P.Physics == PHYS_Walking || P.Physics == PHYS_Spider || P.Physics == PHYS_Hovering)
	{
		return true;
	}

	return false;
}

//damage from shake, not the shake itself - brach/camara
function GroundShake()
{
	local Pawn P;
	local float Dist, Scale;
	local vector PushDir;

	PlayFootSteps();
	foreach VisibleCollidingActors(class'Pawn',P,GroundShakeRadius+100,Location)
	{
		if(P != None && P.Health > 0 && CheckShakePhysics(P) && !SameSpeciesAs(P))
		{
			PushDir = 30000 * Normal(P.Location - Location);
			Dist = VSize(Location - P.Location);
			if(Dist < GroundShakeRadius/2)
			{
				Scale = 1.0;
			}
			else
			{
				Scale = (GroundShakeRadius*2.0 - Dist) / (GroundShakeRadius);
			}

			P.TakeDamage(StompDamage*Scale, self,P.Location, PushDir, class'MeleeDamage');
		}
	}
}

//slow dinos bump into each other, need to disable them crushing each other - none cylinder collision bug
singular event BaseChange()
{
	local float decorMass;

	if ( bInterpolating )
		return;
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise we do some damage and jump off.
	else if ( Pawn(Base) != None && Base != DrivenVehicle )
	{
		if ( !Pawn(Base).bCanBeBaseForPawns )
		{
			if(!SameSpeciesAs(Pawn(Base)))
			{
				Base.TakeDamage( (1-Velocity.Z/400)* Mass/Base.Mass, Self,Location,0.5 * Velocity , class'Crushed');
			}
			JumpOffPawn();
		}
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, class'Crushed');
	}
}

function bool DoJump( bool bUpdating )
{
	if ( !bUpdating && CanDoubleJump()&& (Abs(Velocity.Z) < 100) && IsLocallyControlled() )
    {
        if ( PlayerController(Controller) != None )
            PlayerController(Controller).bDoubleJump = true;
        DoDoubleJump(bUpdating);
        MultiJumpRemaining -= 1;
        return true;
    }

    if ( Super.DoJump(bUpdating) )
    {
        return true;
    }
    return false;
}

function FireProjectile()
{
	local Coords BoneLocation;
	local Projectile Proj;
	local class<Projectile> ProjectileClass;

	if ( Controller != None && ProjectileClassName != "" && ProjectileClassName != "None")
	{
		ProjectileClass = Class<Projectile>(DynamicLoadObject(ProjectileClassName,class'Class'));
		BoneLocation = GetBoneCoords(RangedBoneName);
		Proj = Spawn(ProjectileClass,,,BoneLocation.Origin,Controller.AdjustAim(SavedFireProperties,BoneLocation.Origin,AimError));
		if(Proj != None)
		{
			PlaySound(FireSound, SLOT_Interact);
		}
	}
}

simulated function SetOverlayMaterial( Material mat, float  time, bool  bOverride)
{
	local string Overlaymat;

	if(bOverlayFix)
	{
		Overlaymat = string(mat);
		if(Overlaymat ~= OverlaySet[0].InvalidOverlay)
		{
			mat = OverlaySet[0].ReplacementMat;
		}
		else if(Overlaymat ~= OverlaySet[1].InvalidOverlay)
		{
			mat = OverlaySet[1].ReplacementMat;
		}
	}

	Super.SetOverlayMaterial(mat, time, bOverride);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if(instigatedBy == self || SameSpeciesAs(instigatedBy))
	{
		return;
	}

	Super.TakeDamage(Damage,instigatedBy,hitlocation, momentum, damageType);
}

defaultproperties
{
     DeathAnim="Death"
     SleepAnim="Sleep"
     CallAnim="Call"
     RoarAnim="Roar"
     EatAnim="Eat"
     MeleeAnims(0)="Melee01"
     MeleeAnims(1)="Melee02"
     VictoryAnim="Roar"
     RangedAttackAnims(0)="RangedAttack"
     RangedAttackAnims(1)="RangedAttack"
     TailSwipeAnims(0)="Melee_L"
     TailSwipeAnims(1)="Melee_R"
     TailAttackBoneName="Tail01"
     RangedBoneName="spitbone"
     FemaleSkin=Texture'Engine.DefaultTexture'
     MaleSkin=Texture'Engine.DefaultTexture'
     FemaleZombieSkin=Texture'Engine.DefaultTexture'
     MaleZombieSkin=Texture'Engine.DefaultTexture'
     RoarSounds(0)=Sound'tk_Dinotopia.Generic_Sounds.GenLgrowl02'
     RoarSounds(1)=Sound'tk_Dinotopia.Generic_Sounds.GenLgrowl03'
     CallSounds(0)=Sound'tk_Dinotopia.Generic_Sounds.GenSniff02'
     CallSounds(1)=Sound'tk_Dinotopia.Generic_Sounds.Gensnap'
     TailSwipeSound=Sound'tk_Dinotopia.Generic_Sounds.Tailswipe'
     TailBoneRadius=100
     aimerror=1
     StompDamage=200
     MeleeDamage=30
     bFemale=True
     bRandomSex=True
     bHerbivore=True
     CallIntervalTime=30.000000
     RangedAttackInterval=1.500000
     RoarIntervalTime=15.000000
     LungeIntervalTime=5.000000
     GroundShakeRadius=500.000000
     DinoSpeedMultiplier=1.000000
     OverlaySet(0)=(InvalidOverlay="MutantSkins.Shaders.MutantGlowShader",ReplacementMat=TexPanner'MutantSkins.Shaders.TexPanner3')
     OverlaySet(1)=(InvalidOverlay="DruidsRPGShaders1.DomShaders.PulseGreyShader",ReplacementMat=Shader'tk_Dinotopia.Overlay_Mats.Freeze_S')
     PaleoControllerClass=class'tk_Dinotopia.DinoController'
     HitSound(0)=Sound'tk_Dinotopia.Generic_Sounds.Herbgrowl02'
     HitSound(1)=Sound'tk_Dinotopia.Generic_Sounds.Herbgrowl02'
     HitSound(2)=Sound'tk_Dinotopia.Generic_Sounds.Herbgrowl02'
     HitSound(3)=Sound'tk_Dinotopia.Generic_Sounds.Herbgrowl02'
     DeathSound(0)=Sound'tk_Dinotopia.Generic_Sounds.Gen_Whine'
     DeathSound(1)=Sound'tk_Dinotopia.Generic_Sounds.Gen_Whine'
     DeathSound(2)=Sound'tk_Dinotopia.Generic_Sounds.Gen_Whine'
     DeathSound(3)=Sound'tk_Dinotopia.Generic_Sounds.Gen_Whine'
     ChallengeSound(0)=Sound'tk_Dinotopia.Generic_Sounds.Gen_Long_Growl'
     ChallengeSound(1)=Sound'tk_Dinotopia.Generic_Sounds.Genbored01'
     ChallengeSound(2)=Sound'tk_Dinotopia.Generic_Sounds.Gen_Long_Growl'
     ChallengeSound(3)=Sound'tk_Dinotopia.Generic_Sounds.Genbored01'
     MinTimeBetweenPainSounds=1.500000
     WallDodgeAnims(0)="DodgeL"
     WallDodgeAnims(1)="DodgeR"
     WallDodgeAnims(2)="DodgeL"
     WallDodgeAnims(3)="DodgeR"
     IdleHeavyAnim="Idle"
     IdleRifleAnim="Idle"
     FireHeavyRapidAnim="Walk"
     FireHeavyBurstAnim="Walk"
     FireRifleRapidAnim="Walk"
     FireRifleBurstAnim="Walk"
     bBlobShadow=True
     bCanStrafe=False
     bCanDoubleJump=False
     bCanWallDodge=False
     bCanWalkOffLedges=True
     MeleeRange=80.000000
     JumpZ=100.000000
     MovementAnims(0)="Run"
     MovementAnims(1)="Run"
     MovementAnims(2)="Run"
     MovementAnims(3)="Run"
     TurnLeftAnim="Run"
     TurnRightAnim="Run"
     SwimAnims(0)="Swim"
     SwimAnims(1)="Swim"
     SwimAnims(2)="Swim"
     SwimAnims(3)="Swim"
     CrouchAnims(0)="Walk"
     CrouchAnims(1)="Walk"
     CrouchAnims(2)="Walk"
     CrouchAnims(3)="Walk"
     WalkAnims(0)="Run"
     WalkAnims(1)="Run"
     WalkAnims(2)="Run"
     WalkAnims(3)="Run"
     AirAnims(0)="InAir"
     AirAnims(1)="InAir"
     AirAnims(2)="InAir"
     AirAnims(3)="InAir"
     TakeoffAnims(0)="InAir"
     TakeoffAnims(1)="InAir"
     TakeoffAnims(2)="InAir"
     TakeoffAnims(3)="InAir"
     LandAnims(0)="Walk"
     LandAnims(1)="Walk"
     LandAnims(2)="Walk"
     LandAnims(3)="Walk"
     DoubleJumpAnims(0)="InAir"
     DoubleJumpAnims(1)="InAir"
     DoubleJumpAnims(2)="InAir"
     DoubleJumpAnims(3)="InAir"
     DodgeAnims(0)="DodgeL"
     DodgeAnims(1)="DodgeR"
     DodgeAnims(2)="DodgeL"
     DodgeAnims(3)="DodgeR"
     AirStillAnim="InAir"
     TakeoffStillAnim="InAir"
     CrouchTurnRightAnim="Walk"
     CrouchTurnLeftAnim="Walk"
     IdleCrouchAnim="Idle"
     IdleSwimAnim="Idle"
     IdleWeaponAnim="Idle"
     IdleRestAnim="Idle"
     IdleChatAnim="Idle"
     CollisionRadius=60.000000
     CollisionHeight=100.000000
     bUseCylinderCollision=False
}
