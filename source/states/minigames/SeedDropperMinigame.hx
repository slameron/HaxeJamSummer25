package states.minigames;

class SeedDropperMinigame extends BaseMinigame
{
	override public function new(time:Float)
	{
		super(time);
		inputRequirement = WASDSPACE;
	}

	var pot:FlxSprite;

	var seed:FlxSprite;

	override function start()
	{
		instruction = 'Plant the Seed!';

		pot = new FlxSprite().loadGraphic('assets/images/pot.png');
		pot.setPosition(playBounds.x + 10, playBounds.y + playBounds.height - pot.height - 10);
		FlxTween.tween(pot, {x: playBounds.x + playBounds.width - 10 - pot.width}, 3, {ease: FlxEase.smootherStepInOut, type: PINGPONG});
		add(pot);

		seed = new FlxSprite().loadGraphic('assets/images/seed.png');
		seed.setPosition(FlxG.random.int(Std.int(playBounds.x + 10), Std.int(playBounds.x + playBounds.width - 10 - seed.width)), playBounds.y + 10);
		add(seed);
	}

	override public function end(success:Bool)
	{
		if (ended)
			return;

		super.end(success);

		seed.velocity.y = 0;
		FlxTween.cancelTweensOf(pot);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		seed.velocity.x = 0;
		if (ended)
			return;

		if (controls.pressed('left'))
			seed.velocity.x = -200;
		if (controls.pressed('right'))
			seed.velocity.x = 200;
		if (controls.pressed('left') && controls.pressed('right'))
			seed.velocity.x = 0;

		if (controls.justPressed('jump'))
			seed.velocity.y = 300;

		if (FlxG.overlap(pot, seed))
			end(true);
	}
}
