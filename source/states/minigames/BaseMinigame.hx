package states.minigames;

import flixel.FlxBasic;
import flixel.FlxObject;
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
	var timerTween:FlxTween;

	var playArea:FlxSprite;
	var playBounds:FlxObject;

	var time:Float;

	public var ended:Bool = false;

	var songsList:Array<String> = ['rootbeer', 'rootaccess', 'squareroot'];
	var selectedSong:String;

	public function new(time:Float)
	{
		super();
		this.time = time;
	}

	override public function create():Void
	{
		super.create();

		var colors:Array<FlxColor> = [0xFF639bff, 0xFF37946e, 0xFF76428a];
		var bgColor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxG.random.getObject(colors));
		add(bgColor);

		var bgTile = new FlxBackdrop('assets/images/minigame/tileBG.png', XY);
		bgTile.velocity.set(50 * FlxG.random.int(-1, 1, [0]), 50 * FlxG.random.int(-1, 1, [0]));
		add(bgTile);

		var instructionBG = new FlxSprite().loadGraphic('assets/images/minigame/instructionBG.png');
		instructionBG.setPosition(FlxG.width / 2 - instructionBG.width / 2, 15);
		add(instructionBG);

		playArea = new FlxSprite().loadGraphic('assets/images/minigame/playArea.png');
		playArea.setPosition(FlxG.width / 2 - playArea.width / 2, FlxG.height - playArea.height - 15);
		add(playArea);

		playBounds = new FlxObject(playArea.x + 10, playArea.y + 5, playArea.width - 20, playArea.height - 10);

		selectedSong = FlxG.random.getObject(songsList);

		start();

		var playAreaOverlay = new FlxSprite().loadGraphic('assets/images/minigame/playAreaOverlay.png');
		playAreaOverlay.setPosition(FlxG.width / 2 - playAreaOverlay.width / 2, playArea.y + playArea.height / 2 - playAreaOverlay.height / 2);
		add(playAreaOverlay);

		var instructionText = new Text(0, 0, 0, instruction, 32, true);
		instructionText.screenCenter(X);
		instructionText.y = instructionBG.y + instructionBG.height / 2 - instructionText.height / 2;
		add(instructionText);

		var timerBar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, 586, 34, null, '', 0, 586);
		timerBar.createImageBar('assets/images/minigame/timerBarEmpty.png', 'assets/images/minigame/timerBarFilled.png');
		timerBar.setPosition(FlxG.width / 2 - timerBar.width / 2, instructionBG.y + instructionBG.height - 1);
		add(timerBar);

		var timerBarOverlay = new FlxSprite().loadGraphic('assets/images/minigame/timerBarOverlay.png');
		timerBarOverlay.setPosition(FlxG.width / 2 - timerBarOverlay.width / 2, timerBar.y + timerBar.height / 2 - timerBarOverlay.height / 2);
		add(timerBarOverlay);

		timer = new FlxTimer().start(time, (tmr) -> end(false));

		timerBar.value = 586;
		timerTween = FlxTween.tween(timerBar, {'value': 0}, time, {ease: FlxEase.smootherStepOut});

		Sound.playMusic('${selectedSong}Loop');
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if FLX_DEBUG
		if (FlxG.keys.justPressed.G)
			end(true);
		#end
	}

	public function start():Void
	{
		trace('Just started new game ${Type.getClassName(Type.getClass(FlxG.state))}');
	}

	public function end(success:Bool):Void
	{
		if (ended)
			return;
		ended = true;

		if (timer.active)
			timer.cancel();

		if (timerTween.active)
			timerTween.cancel();

		if (Sound.musics.exists('${selectedSong}Loop'))
			Sound.musics.get('${selectedSong}Loop').kill();

		if (success)
		{
			Sound.play('${selectedSong}Stab');

			new FlxTimer().start(2, tmr -> if (onComplete != null)
			{
				onComplete(success);
			});
		}
		else if (onComplete != null)
			onComplete(success);
	}
}
