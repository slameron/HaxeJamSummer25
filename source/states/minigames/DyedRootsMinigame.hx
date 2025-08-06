package states.minigames;

class DyedRootsMinigame extends BaseMinigame
{
	override public function new(time:Float)
	{
		super(time);
		inputRequirement = ARROWS;
	}

	var hair:FlxSprite;
	var brush:FlxSprite;
	var numPresses:Int;
	var presses:Int = 0;
	var lastLeft:Bool = false;

	var smearTimer:FlxTimer;

	override function start()
	{
		instruction = 'Dye the roots!';
		numPresses = FlxG.random.int(15, 25);

		hair = Helpers.retChar(new FlxSprite(), 'hair', '');
		hair.animation.play('root');
		hair.setPosition(playBounds.x + playBounds.width / 2 - hair.width / 2, playBounds.y + playBounds.height / 2 - hair.height / 2);
		add(hair);

		brush = Helpers.retChar(new FlxSprite(), 'rootbrush', '');
		brush.animation.play(FlxG.random.bool(50) ? 'left' : 'right');
		brush.setPosition(playArea.x + playArea.width / 2 - brush.width / 2 - (brush.animation.name == 'left' ? 50 : -50), hair.y + 20);
		add(brush);

		smearTimer = new FlxTimer();

		smearTimer.start(.25, tmr ->
		{
			if (brush.animation.name == 'smearLeft')
				brush.animation.play('left');
			else if (brush.animation.name == 'smearRight')
				brush.animation.play('right');
		});
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

		hair.animation.curAnim.curFrame = Std.int(FlxMath.remapToRange(presses, 0, numPresses, 0, hair.animation.getByName('root').numFrames - 1));
		if (ended)
			return;

		if (controls.justPressed('left') && (!lastLeft || presses == 0))
		{
			lastLeft = true;

			presses++;

			brush.x = playArea.x + playArea.width / 2 - brush.width / 2 - 50;
			brush.animation.play('smearLeft');
			smearTimer.reset(.25);
		}
		if (controls.justPressed('right') && (lastLeft || presses == 0))
		{
			lastLeft = false;

			presses++;

			brush.x = playArea.x + playArea.width / 2 - brush.width / 2 + 50;

			brush.animation.play('smearRight');
			smearTimer.reset(.25);
		}

		if (presses >= numPresses)
			end(true);
	}
}
