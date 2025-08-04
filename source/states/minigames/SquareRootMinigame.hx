package states.minigames;

class SquareRootMinigame extends BaseMinigame
{
	override public function new()
	{
		super();
		inputRequirement = NUMBERS;
	}

	override function start()
	{
		// add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.PURPLE));
		instruction = 'Find the square root!';
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
			end(true);
	}
}
