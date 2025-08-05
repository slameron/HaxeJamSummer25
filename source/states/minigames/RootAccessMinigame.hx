package states.minigames;

import flixel.input.keyboard.FlxKey;

class RootAccessMinigame extends BaseMinigame
{
	override public function new(time:Float)
	{
		super(time);
		inputRequirement = KEYBOARD;
	}

	var funnyText:Text;
	var funnyString:String = '0101010101101000011001010110110001101100011011110010000001110111011011110111001001101100011001000101010001010101010101010101011101001010101';

	override function start()
	{
		instruction = 'Unlock root access!';

		playArea.color = FlxColor.BLACK;

		funnyText = new Text(playBounds.x + 20, playBounds.y + 20, playBounds.width - 40, '> ', 16, false);
		funnyText.color = FlxColor.LIME;
		add(funnyText);

		Sound.playMusic('rootaccessLoop', false);
	}

	override public function end(success:Bool)
	{
		if (ended)
			return;
		ended = true;

		if (timer.active)
			timer.cancel();

		if (timerTween.active)
			timerTween.cancel();

		if (Sound.musics.exists('rootaccessLoop'))
			Sound.musics.get('rootaccessLoop').kill();

		if (success)
		{
			Sound.play('rootaccessStab');

			new FlxTimer().start(2, tmr -> if (onComplete != null)
			{
				onComplete(success);
			});
		}
		else if (onComplete != null)
			onComplete(success);
	}

	var spamString:String = '';

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.firstJustPressed() != -1)
		{
			var key:FlxKey = FlxG.keys.firstJustPressed();

			if (key != NONE)
				spamString += 'a';

			funnyText.text = '> ${funnyString.substr(0, Std.int((funnyString.length / 25) * spamString.length))}';
		}

		if (spamString.length >= 25)
			end(true);
	}
}
