package states.minigames;

class WateringMinigame extends BaseMinigame
{
	override public function new()
	{
		super();
		inputRequirement = MOUSE;
	}

	override function start()
	{
		// add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.LIME));

		instruction = 'Water the flowers!';
	}
}
