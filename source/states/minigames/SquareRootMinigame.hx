package states.minigames;

import flixel.input.keyboard.FlxKey;

using StringTools;

class SquareRootMinigame extends BaseMinigame
{
	override public function new(time:Float)
	{
		super(time);
		inputRequirement = NUMBERS;
	}

	var sqrtNumber:Int;
	var lastEntered:String = '';
	var numberText:Text;

	override function start()
	{
		instruction = 'Find the square root!';

		sqrtNumber = FlxG.random.int(2, 15);

		numberText = new Text(0, 0, 0, 'sqrt ${sqrtNumber * sqrtNumber} = ?', 78, true);
		numberText.setPosition(playBounds.x + playBounds.width / 2 - numberText.width / 2, playBounds.y + playBounds.height / 2 - numberText.height / 2);
		add(numberText);

		selectedSong = 'squareroot';
	}

	override public function end(success:Bool)
	{
		if (ended)
			return;

		super.end(success);

		if (success)
			numberText.text = 'sqrt ${sqrtNumber * sqrtNumber} = $sqrtNumber!';
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.firstJustPressed() != -1)
		{
			var key:FlxKey = FlxG.keys.firstJustPressed();

			if (key != NONE)
				lastEntered += switch (key)
				{
					case ONE | NUMPADONE: '1';
					case TWO | NUMPADTWO: '2';
					case THREE | NUMPADTHREE: '3';
					case FOUR | NUMPADFOUR: '4';
					case FIVE | NUMPADFIVE: '5';
					case SIX | NUMPADSIX: '6';
					case SEVEN | NUMPADSEVEN: '7';
					case EIGHT | NUMPADEIGHT: '8';
					case NINE | NUMPADNINE: '9';
					case ZERO | NUMPADZERO: '0';

					default: '';
				}

			if (lastEntered.endsWith('$sqrtNumber'))
				end(true);
		}
	}
}
