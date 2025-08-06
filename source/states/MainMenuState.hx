package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class MainMenuState extends DefaultState
{
	var quitButton:FlxSprite;
	var fullscreenButton:FlxSprite;
	var playButton:FlxSprite;

	override public function create()
	{
		super.create();

		Sound.playMusic('menu', false);
		var bg = new FlxBackdrop(FlxGridOverlay.createGrid(32, 32, 64, 64, true, 0xFF16012a, 0xFF250841), XY);

		FlxG.mouse.visible = true;

		bg.velocity.set(50, 50);
		add(bg);

		var overlay = new FlxSprite().loadGraphic('assets/images/menuOverlay.png');
		add(overlay);

		var title = new FlxSprite().loadGraphic('assets/images/menuTitle.png');
		add(title);

		playButton = Helpers.retChar(new FlxSprite(), 'menuPlayBig', '');
		playButton.setPosition(FlxG.width / 2 - playButton.width / 2, FlxG.height / 2 + 20);
		add(playButton);
		playButton.animation.play('small');

		#if desktop
		quitButton = new FlxSprite(10, 10).loadGraphic('assets/images/menuQuit.png');
		add(quitButton);
		#end

		fullscreenButton = new FlxSprite().loadGraphic('assets/images/menuFullscreen.png');
		fullscreenButton.setPosition(FlxG.width - fullscreenButton.width, 10);
		add(fullscreenButton);

		var highscoreText = new Text(0, 0, 0, 'Highscore: ${FlxG.save.data.highscore}', 24, true);
		highscoreText.setPosition(FlxG.width / 2 - highscoreText.width / 2, FlxG.height - highscoreText.height - 2);
		add(highscoreText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if FLX_DEBUG
		if (FlxG.keys.justPressed.G)
			FlxG.switchState(() -> new MenuState());
		#end

		if (FlxG.mouse.overlaps(playButton))
		{
			playButton.animation.play('big');

			if (FlxG.mouse.justPressed)
				FlxG.switchState(() -> new PlayState());
		}
		else
			playButton.animation.play('small');

		#if desktop
		if (FlxG.mouse.overlaps(quitButton) && FlxG.mouse.justPressed)
			Sys.exit(0);
		#end

		if (FlxG.mouse.overlaps(fullscreenButton) && FlxG.mouse.justPressed)
			FlxG.fullscreen = !FlxG.fullscreen;
	}
}
