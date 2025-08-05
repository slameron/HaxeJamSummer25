package util;

import states.minigames.BaseMinigame;
import states.minigames.RootAccessMinigame;
import states.minigames.RootBeerMinigame;
import states.minigames.SeedDropperMinigame;
import states.minigames.SquareRootMinigame;
import states.minigames.UprootMinigame;
import states.minigames.WateringMinigame;
import states.minigames.WiresMinigame;

typedef Minigame = Class<BaseMinigame>;

class MinigameHandler
{
	public static var minigameList:Array<Minigame> = [
		RootAccessMinigame,
		RootBeerMinigame,
		SeedDropperMinigame,
		SquareRootMinigame,
		UprootMinigame,
		WateringMinigame,
		WiresMinigame
	];

	var level:Int = 0;
	var lives:Int;
	var maxLives:Int = 3;
	var parentState:FlxState;
	var lastGame:String;
	var firstGame:Minigame;

	var startingTime:Float = 5;
	var minTime:Float = 1;
	var currentTime:Float;
	var timeDecrement:Float = .75;

	public function new(state:FlxState, ?firstGame:Minigame)
	{
		parentState = state;
		lives = maxLives;
		currentTime = startingTime;
		this.firstGame = firstGame;
	}

	public function startNextGame(?success:Bool):Void
	{
		FlxG.mouse.visible = false;

		if (success != null)
			if (!success)
				lives--;

		if (lives <= 0)
		{
			FlxG.switchState(() -> new TransitionState(success, () ->
			{
				FlxG.switchState(() -> new GameOverState(level));
			}));
			return;
		}

		var speedup = false;
		if (level > 0 && level % 5 == 0)
		{
			trace('Speed up');

			var oldTime = currentTime;

			currentTime -= timeDecrement;
			if (currentTime < minTime)
				currentTime = minTime;

			if (currentTime != oldTime)
				speedup = true;
		}

		var nextClass:Minigame = FlxG.random.getObject(minigameList);
		while (Type.getClassName(nextClass) == lastGame)
			nextClass = FlxG.random.getObject(minigameList);

		if (firstGame != null)
		{
			nextClass = firstGame;
			firstGame = null;
		}

		lastGame = Type.getClassName(nextClass);

		var nextGame = Type.createInstance(nextClass, [currentTime]);

		level++;
		trace('Level $level');

		nextGame.onComplete = (success:Bool) ->
		{
			FlxG.log.add("Minigame complete: " + (success ? "Win" : "Lose"));
			startNextGame(success);
		};

		if (success != null)
			FlxG.switchState(() -> new TransitionState(success, () ->
			{
				FlxG.switchState(() -> new GetReadyState(nextGame.inputRequirement, level, lives, maxLives, speedup, () -> FlxG.switchState(() -> nextGame)));
			}));
		else
			FlxG.switchState(() -> new GetReadyState(nextGame.inputRequirement, level, lives, maxLives, speedup, () -> FlxG.switchState(() -> nextGame)));
	}
}
