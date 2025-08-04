package states.minigames;

class UprootMinigame extends BaseMinigame
{
	override public function new()
	{
		super();
		inputRequirement = WASDSPACE;
	}

	override function start()
	{
		// add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GREEN));

		instruction = 'Pluck the weeds!';
	}
}
