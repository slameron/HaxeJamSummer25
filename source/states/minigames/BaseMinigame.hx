package states.minigames;

import flixel.addons.display.FlxBackdrop;
import flixel.ui.FlxBar;

enum Input
{
	NUMBERS;
	ARROWS;
	WASDSPACE;
	KEYBOARD;
	MOUSE;
}

class BaseMinigame extends DefaultState
{
	public var onComplete:Bool->Void;

	public var inputRequirement:Input;

	var instruction:String = "SET THE INSTRUCTION!";

	var timer:FlxTimer;

	public function new()
	{
		super();
	}

	override public function create():Void
	{
		super.create();

		var colors:Array<FlxColor> = [0xFF639bff, 0xFF37946e, 0xFF76428a];
		var bgColor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxG.random.getObject(colors));
		add(bgColor);

		var bgTile = new FlxBackdrop('assets/images/tileBG.png', XY);
		bgTile.velocity.set(50 * FlxG.random.int(-1, 1, [0]), 50 * FlxG.random.int(-1, 1, [0]));
		add(bgTile);

		var instructionBG = new FlxSprite().loadGraphic('assets/images/instructionBG.png');
		instructionBG.setPosition(FlxG.width / 2 - instructionBG.width / 2, 15);
		add(instructionBG);

		var playArea = new FlxSprite().loadGraphic('assets/images/playArea.png');
		playArea.setPosition(FlxG.width / 2 - playArea.width / 2, FlxG.height - playArea.height - 15);
		add(playArea);

		start();

		var playAreaOverlay = new FlxSprite().loadGraphic('assets/images/playAreaOverlay.png');
		playAreaOverlay.setPosition(FlxG.width / 2 - playAreaOverlay.width / 2, playArea.y + playArea.height / 2 - playAreaOverlay.height / 2);
		add(playAreaOverlay);

		var instructionText = new Text(0, 0, 0, instruction, 32, true);
		instructionText.screenCenter(X);
		instructionText.y = instructionBG.y + instructionBG.height / 2 - instructionText.height / 2;
		add(instructionText);

		var timerBar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, 586, 34, null, '', 0, 586);
		timerBar.createImageBar('assets/images/timerBarEmpty.png', 'assets/images/timerBarFilled.png');
		timerBar.setPosition(FlxG.width / 2 - timerBar.width / 2, instructionBG.y + instructionBG.height - 1);
		add(timerBar);

		var timerBarOverlay = new FlxSprite().loadGraphic('assets/images/timerBarOverlay.png');
		timerBarOverlay.setPosition(FlxG.width / 2 - timerBarOverlay.width / 2, timerBar.y + timerBar.height / 2 - timerBarOverlay.height / 2);
		add(timerBarOverlay);

		timer = new FlxTimer().start(5, (tmr) -> end(false));

		timerBar.value = 586;
		FlxTween.tween(timerBar, {'value': 0}, 5, {ease: FlxEase.smootherStepOut});
	}

	public function start():Void
	{
		trace('Just started new game ${Type.getClassName(Type.getClass(FlxG.state))}');
	}

	public function end(success:Bool):Void
	{
		if (onComplete != null)
		{
			onComplete(success);
		}
	}
}
