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
	}

	override public function end(success:Bool)
	{
		if (ended)
			return;

		super.end(success);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
		{
			var wireGroup = FlxG.mouse.x >= FlxG.width / 2 ? rightWires : leftWires;
			for (wire in wireGroup)
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
			var wireGroup = rightWires.contains(dragging) ? leftWires : rightWires;
			for (target in wireGroup)
			{
				if (FlxMath.distanceToMouse(target) <= 30)
				{
					var colorMatch = getColor(dragging) == getColor(target);
					if (colorMatch)
					{
						if (rightWires.contains(dragging))
							connections.set(target, dragging);
						else
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

			var from = dragging != null ? rightWires[i] == dragging ? rightWires[i].getMidpoint() : leftWires[i].getMidpoint() : leftWires[i].getMidpoint();
			var to:FlxPoint = null;

			if (dragging == leftWires[i] || dragging == rightWires[i])
			{
				to = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
			}
			else if (connections.exists(leftWires[i]))
			{
				to = connections.get(leftWires[i]).getMidpoint();
			}

			if (to != null)
			{
				gfx.lineStyle(12, getColor(dragging != null ? rightWires[i] == dragging ? rightWires[i] : leftWires[i] : leftWires[i]), 1);
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
