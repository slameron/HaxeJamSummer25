package states.minigames;

import flixel.group.FlxGroup;

class RootCanalMinigame extends BaseMinigame
{
	override public function new(time:Float)
	{
		super(time);
		inputRequirement = MOUSE;
	}

	var teeth:FlxTypedGroup<Tooth>;

	override function start()
	{
		instruction = 'Uproot the bad teeth!';

		FlxG.mouse.visible = true;

		teeth = new FlxTypedGroup();
		add(teeth);

		var numDamaged = FlxG.random.int(1, 5);

		var arrTeeth:Array<Tooth> = [];

		var numTeeth:Int = 6;
		var toothWidth:Int = 54;
		var spacing = 10;
		var teethWidth = (toothWidth + spacing) * (numTeeth) - spacing;
		var startingX = playBounds.x + playBounds.width / 2 - teethWidth / 2;

		for (i in 0...numTeeth)
		{
			var toothTop:Tooth = new Tooth();
			toothTop.flipY = true;
			toothTop.setPosition(startingX + (toothTop.width + spacing) * i, playBounds.y + 5);
			teeth.add(toothTop);
			arrTeeth.push(toothTop);

			var toothBottom:Tooth = new Tooth();
			toothBottom.setPosition(startingX + (toothBottom.width + spacing) * i, playBounds.y + playBounds.height - toothBottom.height - 5);
			teeth.add(toothBottom);
			arrTeeth.push(toothBottom);
		}

		while (numDamaged > 0)
		{
			var selTooth = FlxG.random.getObject(arrTeeth);
			arrTeeth.remove(selTooth);

			selTooth.damage();
			numDamaged--;
		}
	}

	override public function end(success:Bool)
	{
		if (ended)
			return;

		super.end(success);
	}

	var pullingTooth:Tooth;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var anyDamaged:Bool = false;

		if (FlxG.mouse.justReleased)
			pullingTooth = null;

		if (pullingTooth != null && Math.abs(FlxG.mouse.y - pullingTooth.getMidpoint().y) >= 75)
		{
			pullingTooth.pull();
			pullingTooth = null;
		}

		for (tooth in teeth)
		{
			if (tooth.damaged)
				anyDamaged = true;

			if (FlxG.mouse.overlaps(tooth) && FlxG.mouse.justPressed && tooth.damaged)
			{
				pullingTooth = tooth;
			}
		}

		if (!anyDamaged)
			end(true);
	}
}

class Tooth extends FlxSprite
{
	public var damaged:Bool = false;

	public function damage()
	{
		damaged = true;
		animation.play('bad');
	}

	override public function new()
	{
		super(0, 0);

		Helpers.retChar(this, 'tooth', '');
		animation.play('good');
		flipX = FlxG.random.bool(50);
	}

	public function pull()
	{
		damaged = false;

		FlxTween.tween(this, {y: flipY ? y + 10 : y - 10}, .25, {
			ease: FlxEase.smootherStepIn,
			onComplete: twn ->
			{
				FlxTween.color(this, 1, FlxColor.WHITE, 0x00000000, {ease: FlxEase.smootherStepIn});
				// FlxTween.tween(this, {'alpha': 0.01}, 1, {ease: FlxEase.smootherStepIn});
			}
		});
	}
}
