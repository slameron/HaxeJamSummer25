package states.minigames;

import flixel.input.keyboard.FlxKey;

class RootAccessMinigame extends BaseMinigame
{
	override public function new()
	{
		super();
		inputRequirement = KEYBOARD;
	}

	override function start()
	{
		// add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.PURPLE));
		instruction = 'Unlock root access!';
	}

	var spamString:String = '';

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.firstJustPressed() != -1)
			spamString += ' ';

		if (spamString.length >= 25)
			end(true);
	}
}
