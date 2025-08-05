package states.minigames;

import flixel.group.FlxGroup;

class UprootMinigame extends BaseMinigame
{
	override public function new(time:Float)
	{
		super(time);
		inputRequirement = WASDSPACE;
	}

	var player:FlxSprite;
	var weeds:FlxTypedGroup<Weed>;

	override function start()
	{
		instruction = 'Pluck the weeds!';

		weeds = new FlxTypedGroup();
		add(weeds);

		for (i in 0...FlxG.random.int(1, 3))
		{
			weeds.add(new Weed(FlxG.random.float(playBounds.x + 50, playBounds.width + playBounds.x - 82), playBounds.y + playBounds.height - 82));
		}
		player = Helpers.retChar(new FlxSprite(), 'gardenboy', '');
		player.animation.play('idle');
		player.setPosition(FlxG.random.float(playBounds.x + 50, playBounds.width + playBounds.x - 82), playBounds.y
			+ playBounds.height
			- player.height
			- 50);
		add(player);

		selectedSong = FlxG.random.getObject(songsList);
		Sound.playMusic('${selectedSong}Loop');
	}

	override public function end(success:Bool)
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

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		player.velocity.x = 0;
		if (controls.pressed('left'))
			player.velocity.x = -200;
		if (controls.pressed('right'))
			player.velocity.x = 200;
		if (controls.pressed('left') && controls.pressed('right'))
			player.velocity.x = 0;

		if (player.animation.name != 'pluck')
			if (player.velocity.x != 0)
				player.animation.play('walk');
			else
				player.animation.play('idle');

		for (weed in weeds)
			weed.prompt.visible = false;
		FlxG.overlap(player, weeds, (player, weed) ->
		{
			if (weed.alive)
			{
				cast(weed, Weed).prompt.visible = true;

				if (FlxG.keys.justPressed.SPACE)
				{
					weed.pluck();
					player.animation.play('pluck');
					player.animation.onFinish.addOnce(name -> player.animation.play('idle'));
				}
			}
		});

		var weedsAlive:Bool = false;
		weeds.forEachAlive(weed -> if (weed.alive) weedsAlive = true);

		if (!weedsAlive)
			end(true);
	}
}

class Weed extends FlxSprite
{
	public var prompt:ButtonPrompt;

	override public function new(x:Float, y:Float)
	{
		super(x, y);
		Helpers.retChar(this, 'gardenplant', '');
		animation.play('plant');

		prompt = new ButtonPrompt(0, 0, Init.controls.getPrompt('jump'), 1, null, 8, 1, FlxColor.WHITE, FlxColor.BLACK, this, FlxPoint.get(0, 5), true);
	}

	public function pluck()
	{
		kill();
	}

	override public function kill()
	{
		alive = false;
		animation.play('pluck');
		animation.onFinish.addOnce(name -> exists = false);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		prompt.update(elapsed);
	}

	override public function draw()
	{
		super.draw();
		if (prompt.visible)
			prompt.draw();
	}
}
