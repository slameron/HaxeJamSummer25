package states.minigames;

import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDirection;

class RootBeerMinigame extends BaseMinigame
{
	override public function new(time:Float)
	{
		super(time);
		inputRequirement = ARROWS;
	}

	var directions:Array<FlxDirection> = [LEFT, RIGHT, UP, DOWN];

	var arrows:FlxTypedSpriteGroup<StratagemArrow>;
	var currentArrow:Int = 0;

	var theSipper:FlxSprite;

	override function start()
	{
		instruction = 'Drink Root beer!';

		theSipper = Helpers.retChar(new FlxSprite(), 'roobeer', '');
		theSipper.animation.play('drink');
		theSipper.setPosition(playBounds.x + playBounds.width / 2 - theSipper.width / 2, playBounds.y + playBounds.height - theSipper.height);
		add(theSipper);

		arrows = new FlxTypedSpriteGroup();
		for (i in 0...FlxG.random.int(4, 8))
			arrows.add(new StratagemArrow(i * 64, 0, FlxG.random.getObject(directions)));

		arrows.setPosition(playBounds.x + playBounds.width / 2 - arrows.width / 2, playBounds.y + playBounds.height / 2 - arrows.height / 2);
		add(arrows);

		selectedSong = 'rootbeer';
	}

	override public function end(success:Bool)
	{
		if (ended)
			return;

		super.end(success);

		if (success)
		{
			Sound.play('cola');
			theSipper.animation.play('winwinyummyyummy');
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ended)
			return;

		var nextDirection:Array<FlxKey> = switch (arrows.members[currentArrow].arrowDir)
		{
			case LEFT: [LEFT, A];

			case RIGHT: [RIGHT, D];

			case UP: [UP, W];

			case DOWN: [DOWN, S];
		};

		if (FlxG.keys.anyJustPressed(nextDirection))
		{
			arrows.members[currentArrow].hit(true);

			if (currentArrow + 1 >= arrows.members.length)
				end(true);
			else
				currentArrow++;
		}
		else if (FlxG.keys.firstJustPressed() != -1)
		{
			for (arrow in arrows)
				arrow.hit(false);

			FlxTween.shake(arrows, .05, .25);

			currentArrow = 0;
		}

		if (ended)
			return;
		theSipper.animation.curAnim.curFrame = Std.int(FlxMath.remapToRange(currentArrow, 0, arrows.members.length - 1, 0,
			theSipper.animation.getByName('drink').numFrames - 1));
	}
}

class StratagemArrow extends FlxSprite
{
	public var arrowDir:FlxDirection;

	override public function new(x:Float, y:Float, direction:FlxDirection)
	{
		super(x, y);
		arrowDir = direction;

		Helpers.retChar(this, 'arrows', '');
		animation.play(direction.toString());

		color = 0xFF431B1B;
	}

	public function hit(hit:Bool)
	{
		color = hit ? 0xFF2E863E : 0xFF431B1B;
	}
}
