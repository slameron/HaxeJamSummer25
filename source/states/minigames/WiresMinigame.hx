package states.minigames;

import flixel.group.FlxGroup;
import openfl.display.Graphics;
import openfl.display.Shape;

class WiresMinigame extends BaseMinigame
{
	var colors:Array<Int> = [0xFF3E0000, 0xFFC29400, 0xFF91A700, 0xFFC15300];
	var leftWires:Array<FlxSprite> = [];
	var rightWires:Array<FlxSprite> = [];

	var dragging:FlxSprite = null;
	var wireLines:Array<Shape> = [];
	var connections:Map<FlxSprite, FlxSprite> = new Map();

	override public function new(time:Float)
	{
		super(time);
		inputRequirement = MOUSE;
	}

	override public function start()
	{
		time *= 2;
		FlxG.mouse.visible = true;
		instruction = 'Connect the Roots!';

		var shuffledColors = colors.copy();
		FlxG.random.shuffle(shuffledColors);

		for (i in 0...colors.length)
		{
			var l = new FlxSprite(playBounds.x + 30, playBounds.y + 20 + i * 50);
			l.makeGraphic(20, 20, colors[i]);
			add(l);
			leftWires.push(l);

			var r = new FlxSprite(playBounds.width + playBounds.x - 50, playBounds.y + 20 + i * 50);
			r.makeGraphic(20, 20, shuffledColors[i]);
			add(r);
			rightWires.push(r);

			var line = new Shape();
			FlxG.stage.addChild(line);
			wireLines.push(line);
		}

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

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
		{
			for (wire in leftWires)
			{
				if (FlxMath.distanceToMouse(wire) <= 30)
				{
					dragging = wire;
					break;
				}
			}
		}

		if (FlxG.mouse.justReleased && dragging != null)
		{
			for (target in rightWires)
			{
				if (FlxMath.distanceToMouse(target) <= 30)
				{
					var colorMatch = getColor(dragging) == getColor(target);
					if (colorMatch)
					{
						connections.set(dragging, target);
					}
					break;
				}
			}
			dragging = null;
		}

		for (i in 0...leftWires.length)
		{
			var line = wireLines[i];
			var gfx:Graphics = line.graphics;
			gfx.clear();

			var from = leftWires[i].getMidpoint();
			var to:FlxPoint = null;

			if (dragging == leftWires[i])
			{
				to = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
			}
			else if (connections.exists(leftWires[i]))
			{
				to = connections.get(leftWires[i]).getMidpoint();
			}

			if (to != null)
			{
				gfx.lineStyle(12, getColor(leftWires[i]), 1);
				gfx.moveTo(from.x, from.y);
				gfx.lineTo(to.x, to.y);
			}
		}

		var connectionsLength:Int = 0;
		for (i in connections.keys())
			connectionsLength++;
		if (connectionsLength == colors.length)
		{
			var allCorrect = true;
			for (left in connections.keys())
			{
				if (getColor(left) != getColor(connections.get(left)))
				{
					allCorrect = false;
					break;
				}
			}

			if (allCorrect)
			{
				end(true);
			}
		}
	}

	function getColor(spr:FlxSprite):Int
	{
		return spr.pixels.getPixel32(0, 0);
	}

	override public function destroy():Void
	{
		for (line in wireLines)
		{
			if (FlxG.stage.contains(line))
			{
				FlxG.stage.removeChild(line);
			}
		}
		super.destroy();
	}
}
