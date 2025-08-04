package states;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;

class PlayState extends DefaultState
{
	var minigameHandler:MinigameHandler;

	override public function create()
	{
		super.create();

		// add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLUE));
		// add(new Text(0, 0, 0, 'Hello world', 64, true));

		/*var square:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileSquare);
			square.persist = true;
			square.destroyOnNoUse = false;
			FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, .25, FlxPoint.get(1, 1), {asset: square, width: 32, height: 32});
			FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, .25, FlxPoint.get(1, 1), {asset: square, width: 32, height: 32}); */
		minigameHandler = new MinigameHandler(this);
		minigameHandler.startNextGame();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
