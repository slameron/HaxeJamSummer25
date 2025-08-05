package states;

import flixel.addons.display.FlxGridOverlay;

class TransitionState extends DefaultState
{
	var winner:Bool;
	var next:() -> Void;

	public function new(winner:Bool, next:() -> Void)
	{
		super();
		this.winner = winner;
		this.next = next;
	}

	override public function create()
	{
		super.create();

		var bg:FlxSprite = FlxGridOverlay.create(32, 32, FlxG.width, FlxG.height, true, winner ? 0xFF20371D : 0xFF531A1A, winner ? 0xFF589E5C : 0xFF922525);
		add(bg);

		var resultText = new Text(0, 0, 0, winner ? "WINNERRR!" : "failed...", 32, true);
		resultText.screenCenter();
		resultText.color = winner ? 0xFF00FF00 : 0xFFFF0000;
		add(resultText);

		if (!winner)
		{
			var explosion = new FlxSprite().loadGraphic('assets/images/explosion.png', true, 96, 96);
			explosion.animation.add('explode', [for (i in 0...12) i], 24, false);
			explosion.animation.play('explode');
			add(explosion);
			explosion.scale.set(3, 3);
			explosion.screenCenter();
			explosion.animation.onFinish.addOnce(name -> explosion.kill());

			Sound.play('explode');
		}
		else
			Sound.play('win');

		new FlxTimer().start(2.5, (tmr) ->
		{
			if (next != null)
			{
				next();
			}
		});
	}
}
