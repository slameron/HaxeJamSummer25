package util;

import states.minigames.BaseMinigame;
import states.minigames.RootAccessMinigame;
import states.minigames.SquareRootMinigame;
import states.minigames.UprootMinigame;
import states.minigames.WateringMinigame;

typedef Minigame = Class<BaseMinigame>;

class MinigameHandler
{
	var minigameList:Array<Minigame>;
	var level:Int = 0;
	var parentState:FlxState;

	public function new(state:FlxState)
	{
		parentState = state;
		minigameList = [RootAccessMinigame, SquareRootMinigame, UprootMinigame, WateringMinigame];
	}

	public function startNextGame(?success:Bool):Void
	{
		/*if (currentIndex >= microgameList.length)
			{
				currentIndex = 0;
				FlxG.log.add("Super win");
				return;
		}*/

		var nextClass:Minigame = FlxG.random.getObject(minigameList);
		var nextGame = Type.createInstance(nextClass, []);

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
				FlxG.switchState(() -> nextGame);
			}));
		else
			FlxG.switchState(() -> nextGame);
	}
}
