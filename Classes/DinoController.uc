class DinoController extends MonsterController;

function FightEnemy(bool bCanCharge)
{
	Target = None;
}

/*function bool FindNewEnemy()
{
	local Controller C;

	for( C=Level.ControllerList; MonsterController(C)!=None; C=C.NextController )
	{
		if(Dinosaur(C.Pawn) != None && !Dinosaur(C.Pawn).bHerbivore)
		{
			if(MonsterController(C).Target == None || vSize(MonsterController(C).Target.Location - Pawn.Location) < 256)
			{
				MonsterController(C).Trigger(Pawn, Pawn);
			}
		}
	}

	Target = None;
	return false;
}*/

function bool FindNewEnemy()
{
	Target = None;
	return false;
}

function ChangeEnemy(Pawn NewEnemy, bool bCanSeeNewEnemy)
{
	Target = None;
}

function bool SetEnemy( Pawn NewEnemy, optional bool bHateMonster )
{
	return false;
}

function bool CheckFutureSight(float deltatime)
{
	Target = None;
	return false;
}

defaultproperties
{
}
