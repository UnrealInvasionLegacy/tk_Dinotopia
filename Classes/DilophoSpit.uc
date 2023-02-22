class DilophoSpit extends Projectile placeable;

var() class<Emitter> TrailClass;
var() class<Emitter> ExplosionClass;

var Emitter Trail;

simulated function PostBeginPlay()
{
	local Rotator R;

    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
    {
        Trail = Spawn(TrailClass, self);
        Trail.SetBase(self);
    }

    Velocity = Vector(Rotation) * Speed;
	R = Rotation;
	R.Roll = 32768;
	SetRotation(R);
	Velocity.z += TossZ;
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
    if ( Role == ROLE_Authority )
    {
        HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
    }

    PlaySound(ImpactSound, SLOT_Misc);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(ExplosionClass,,, Location);
    }
    SetCollisionSize(0.0, 0.0);
    Destroy();
}

simulated function Destroyed()
{
    if (Trail != None)
    {
		Trail.Kill();
    }

    Super.Destroyed();
}

defaultproperties
{
     TrailClass=class'tk_Dinotopia.DilophoSpitTrail'
     ExplosionClass=class'tk_Dinotopia.DilophoSpitSplash'
     Speed=900.000000
     MaxSpeed=1150.000000
     TossZ=10.000000
     Damage=20.000000
     MyDamageType=class'tk_Dinotopia.DamTypeDilophoSpit'
     ImpactSound=Sound'tk_Dinotopia.Generic_Sounds.SpitSplash01'
     ExplosionDecal=Class'XEffects.RocketMark'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=127
     LightSaturation=85
     LightBrightness=171.000000
     LightRadius=4.000000
     DrawType=DT_Sprite
     CullDistance=4000.000000
     bDynamicLight=True
     bNetTemporary=False
     LifeSpan=10.000000
     Texture=None
     DrawScale=0.200000
     SoundVolume=255
     SoundRadius=150.000000
     CollisionRadius=10.000000
     CollisionHeight=10.000000
}
