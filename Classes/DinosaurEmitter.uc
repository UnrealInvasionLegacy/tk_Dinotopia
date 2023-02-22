class DinosaurEmitter extends Emitter;

simulated event BaseChange()
{
	if(Base == None)
	{
		Kill();
	}
	super.BaseChange();
}

defaultproperties
{
     AutoDestroy=True
     bNoDelete=False
     RemoteRole=ROLE_SimulatedProxy
     bNotOnDedServer=False
}
