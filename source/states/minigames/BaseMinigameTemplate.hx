package states.minigames;

class BaseMinigameTemplate extends BaseMinigame
{
	override public function new(time:Float)
	{
		super(time);
		inputRequirement = MOUSE;
	}

	override function start()
	{
		instruction = 'Change the Instruction!';
	}

	override public function end(success:Bool)
	{
		if (ended)
			return;

		super.end(success);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
