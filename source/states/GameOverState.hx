package states;

class GameOverState extends DefaultState
{
	var level:Int;

	var canProceed:Bool = false;

	override public function new(level:Int)
	{
		super();
		this.level = level;
	}

	override public function create()
	{
		super.create();

		var gameOver = new FlxSprite().loadGraphic('assets/images/gameover.png');
		add(gameOver);

		var scoreText:Text = new Text(0, 0, 0, 'You made it to round $level!', 32, true);
		scoreText.setPosition(65, 170);
		add(scoreText);

		if (level > FlxG.save.data.highscore)
		{
			var highscore = new Text(0, 0, 0, 'New Highscore!!', 24, true);
			highscore.setPosition(scoreText.x + 25, scoreText.y + scoreText.height - 5);
			add(highscore);

			FlxG.save.data.highscore = level;
			FlxG.save.flush();
		}

		new FlxTimer().start(2, tmr -> canProceed = true);

		Sound.playMusic('gameover', false);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE && canProceed)
		{
			FlxG.switchState(() -> new MainMenuState());
		}
	}
}
