class DilophoSpitTrail extends DinosaurEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=134,G=249,R=139,A=255))
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=48,G=177,R=152))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=27,G=156,R=43))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.100000,Max=0.100000),Z=(Min=0.100000,Max=0.100000))
         Opacity=0.700000
         FadeOutStartTime=0.800000
         CoordinateSystem=PTCS_Relative
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000))
         UseSkeletalLocationAs=PTSU_Location
         SkeletalScale=(X=0.400000,Y=0.400000,Z=0.370000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.BurnFlare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.250000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'tk_Dinotopia.DilophoSpitTrail.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         ColorMultiplierRange=(Z=(Min=0.500000,Max=0.500000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=4.000000,Max=6.000000))
         Texture=Texture'EmitterTextures.MultiFrame.Effect_D'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.600000,Max=0.300000)
     End Object
     Emitters(1)=SpriteEmitter'tk_Dinotopia.DilophoSpitTrail.SpriteEmitter3'

     Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_Linear
         TrailLocation=PTTL_FollowEmitter
         DistanceThreshold=100.000000
         UseCrossedSheets=True
         UseColorScale=True
         FadeOut=True
         ColorScale(0)=(Color=(G=255,R=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=29,G=139,R=43))
         ColorMultiplierRange=(Y=(Min=0.500000,Max=0.500000),Z=(Min=0.000000,Max=0.000000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=2.000000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         Texture=Texture'TurretParticles.Beams.TurretBeam5'
         LifetimeRange=(Min=0.500000,Max=0.800000)
     End Object
     Emitters(2)=TrailEmitter'tk_Dinotopia.DilophoSpitTrail.TrailEmitter0'

}
