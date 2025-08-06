package states.minigames;

import flixel.group.FlxGroup.FlxTypedGroup;

class WateringMinigame extends BaseMinigame
{
	override public function new(time:Float)
	{
		super(time);
		inputRequirement = MOUSE;
	}

	var wateringCan:FlxSprite;
	var flowers:FlxTypedGroup<Flower>;

	override function start()
	{
		instruction = 'Water the flowers!';

		flowers = new FlxTypedGroup();
		add(flowers);

		for (i in 0...FlxG.random.int(3, 7))
			flowers.add(new Flower(FlxG.random.float(playBounds.x + 20, playBounds.x + playBounds.width - 52),
				FlxG.random.float(playBounds.y + 10, playBounds.y + playBounds.height - 42)));

		wateringCan = Helpers.retChar(new FlxSprite(), 'watercan', '');
		wateringCan.animation.play('regular');

		add(wateringCan);
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

		wateringCan.setPosition(FlxG.mouse.x - wateringCan.width / 2, FlxG.mouse.y - wateringCan.height / 2);

		if (FlxG.mouse.justPressed)
		{
			wateringCan.animation.play('pouring');
			new FlxTimer().start(.15, tmr -> wateringCan.animation.play('regular'));
		}

		FlxG.overlap(wateringCan, flowers, (can:FlxSprite, flower:Flower) ->
		{
			if (can.animation.name == 'pouring' && !flower.watered)
				flower.water();
		});

		var allFlowersWatered:Bool = true;

		flowers.forEach(flower -> if (!flower.watered) allFlowersWatered = false);

		if (allFlowersWatered)
			end(true);
	}
}

class Flower extends FlxSprite
{
	public var watered:Bool = false;

	override public function new(x:Float, y:Float)
	{
		super(x, y);

		Helpers.retChar(this, 'waterflowers', '');
		animation.play('sadFlower${FlxG.random.int(1, 3)}');
	}

	public function water()
	{
		animation.play('happyFlower${FlxG.random.int(1, 3)}');
		watered = true;
	}
}
