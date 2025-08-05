package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
import states.minigames.BaseMinigame.Input;

class GetReadyState extends DefaultState
{
	var inputRequirement:Input;
	var level:Int;
	var lives:Int;
	var maxLives:Int;
	var speedup:Bool;
	var onFinish:() -> Void;

	override public function new(inputRequirement:Input, level:Int, lives:Int, maxLives:Int, speedup:Bool, onFinish:() -> Void)
	{
		super();

		this.inputRequirement = inputRequirement;
		this.level = level;
		this.lives = lives;
		this.maxLives = maxLives;
		this.speedup = speedup;
		this.onFinish = onFinish;
	}

	override public function create()
	{
		super.create();

		var bg = new FlxBackdrop(FlxGridOverlay.createGrid(16, 16, 32, 32, true, 0xFF3f3f74, 0xFF34135E));
		bg.velocity.set(50, 50);
		add(bg);

		var getReadyText = new Text(0, 0, 0, 'Get Ready!!', 48, true);
		getReadyText.setPosition(FlxG.width / 2 - getReadyText.width / 2, 20);
		add(getReadyText);

		var inputPath = switch (inputRequirement)
		{
			case MOUSE: 'assets/images/inputs/mouse.png';
			case KEYBOARD: 'assets/images/inputs/keyboard.png';
			case WASDSPACE: 'assets/images/inputs/wasdspace.png';
			case ARROWS: 'assets/images/inputs/arrows.png';
			case NUMBERS: 'assets/images/inputs/numbers.png';
		}

		var inputSprite = new FlxSprite().loadGraphic(inputPath);
		inputSprite.scale.set(2, 2);
		inputSprite.screenCenter();
		add(inputSprite);

		var use = new FlxSprite().loadGraphic('assets/images/readyScreen/use.png');
		add(use);

		var useArrow = new FlxSprite().loadGraphic('assets/images/readyScreen/useArrow.png');
		add(useArrow);
		FlxFlicker.flicker(useArrow, 2.5, .4, true);

		var levelText = new Text(0, 0, 0, 'Round ', 24, true);
		levelText.setPosition(25, 50);
		add(levelText);

		if (level > 1)
		{
			var lastLevel = new Text(0, 0, 0, '${level - 1}', 48, true);
			lastLevel.setPosition(levelText.x + levelText.width + 10, levelText.y + levelText.height / 2 - lastLevel.height / 2);
			add(lastLevel);

			FlxTween.tween(lastLevel, {y: FlxG.height}, .6, {ease: FlxEase.backIn, startDelay: .75});
		}

		var thisLevel = new Text(0, 0, 0, '${level}', 48, true);
		thisLevel.setPosition(levelText.x + levelText.width + 10, levelText.y + levelText.height / 2 - thisLevel.height / 2);
		thisLevel.alpha = 0;
		add(thisLevel);

		thisLevel.scale.set(6, 6);
		FlxTween.tween(thisLevel, {
			'alpha': 1,
			'scale.x': thisLevel.sizeScale,
			'scale.y': thisLevel.sizeScale,
			'angle': 1080
		}, .75, {ease: FlxEase.smootherStepIn});

		var livesGroup = new FlxSpriteGroup();
		for (i in 0...maxLives)
		{
			var carrot = new FlxSprite(i * 28).loadGraphic(i < lives ? 'assets/images/life.png' : 'assets/images/lostLife.png');
			carrot.angle = -5;
			FlxTween.tween(carrot, {'angle': 10}, 1.2, {ease: FlxEase.smootherStepInOut, startDelay: i * .15, type: PINGPONG});
			livesGroup.add(carrot);
		}

		livesGroup.screenCenter(X);
		livesGroup.y = FlxG.height - livesGroup.height - 10;
		add(livesGroup);

		Sound.play('getready');
		if (onFinish != null)
			new FlxTimer().start(2, tmr -> if (speedup) speedUp() else onFinish());
	}

	function speedUp()
	{
		var speedupText = new Text(0, 0, 0, 'Speed Up!', 64, true);
		speedupText.screenCenter();
		add(speedupText);

		Sound.play('speedup');

		new FlxTimer().start(2, tmr -> onFinish());
	}
}
