package states;

class GameOverState extends DefaultState
{
	override public function create()
	{
		super.create();

		var gameOver = new FlxSprite().loadGraphic('assets/images/gameover.png');
		add(gameOver);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ANY)
		{
			FlxG.switchState(() -> new MenuState());
		}
	}
}
