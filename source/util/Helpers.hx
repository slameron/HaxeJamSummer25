package util;

import flixel.FlxSprite;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

enum RetType
{
	SPRITE;
	PLAYER;
	PLAYERMP;
	ENEMY;
}

typedef Frame =
{
	animation:String,
	index:Int,
	looped:Bool,
	flipX:Bool,
	frameRate:Int
}

typedef AnimationData =
{
	animation:String,
	indices:Array<Int>,
	looped:Bool,
	flipX:Bool,
	frameRate:Int
}

class Helpers
{
	public static inline function lerp(a:Float, b:Float, ratio:Float):Float
	{
		return a + ((ratio * FlxG.elapsed) / (1 / 60)) * (b - a);
	}

	/**Take a string and return a bool from it, true or false. WARNING: returns true by default! If it does, make sure to check your spelling.**/
	public static function boolFromString(string:String):Bool
	{
		var daBool:Bool = true;
		switch (string)
		{
			case 'false':
				daBool = false;
			case 'true':
				daBool = true;
		}

		return (daBool);
	}

	public static var runFramerates:Map<String, Int> = ["Pickle Frickle" => 10, "Fire Pickle" => 24];

	public static function loadCharacterJson(json:String, ?frames:Bool = true):Array<Dynamic>
	{
		var frameData = cast Json.parse(json).frames;

		return (frameData);
	}

	public static function getMetadata(json:String):Dynamic
	{
		var meta = cast Json.parse(json).meta;

		return (meta);
	}

	public static function parseFrame(frame:Dynamic, _spritesheetWidth:Int, ?defLoop:Bool = true):Frame
	{
		var framePoint = frame.frame;
		var animName:String = frame.filename;

		var loop:Bool = defLoop;
		var flip:Bool = false;
		var frameRate:Int = 10;

		var split:Array<String> = animName.split('-');
		for (string in split)
			string = string.trim();

		animName = split[0];

		for (p in 1...split.length)
			if (split[p] != null && split[p] != '' && split[p] != " ")
			{
				var param:Array<String> = split[p].split('=');
				// trace(param);
				for (parameter in param)
					parameter = parameter.trim();

				if (param[1] != null)
				{
					// trace(param[0] + ', ' + param[1]);
					// The parameter from the Aseprite tag
					switch (param[0].toLowerCase())
					{
						case 'looped':
							loop = Helpers.boolFromString(param[1]);
						case 'flipx':
							flip = Helpers.boolFromString(param[1]);
						case 'framerate':
							frameRate = Std.parseInt(param[1]);

						default:
							FlxG.log.warn('Trying to parse unhandled parameter ${param[0]}');
					}
				}
			}

		var parsedFrame:Frame = {
			animation: animName,
			index: Std.int((framePoint.x / framePoint.w) + ((framePoint.y / framePoint.h) * (_spritesheetWidth / framePoint.w))),
			looped: loop,
			flipX: flip,
			frameRate: frameRate
		};

		return (parsedFrame);
	}

	public static function retEnemy(x:Float, y:Float, char:String):FlxSprite
	{
		var enemy:FlxSprite = new FlxSprite(x, y);
		retChar(enemy, char);
		return enemy;
	}

	public static function retChar(c:FlxSprite, char:String, folder:String = 'characters/', ?defLoop:Bool = true):FlxSprite
	{
		// trace(c);
		// c.setFacingFlip(LEFT, true, false);
		// c.setFacingFlip(RIGHT, false, false);
		c.facing = RIGHT;

		if (openfl.Assets.exists('assets/images/$folder$char.json'))
		{
			var json:String = Assets.getText('assets/images/$folder$char.json').trim();

			var frameInfo:Array<Dynamic> = loadCharacterJson(json);
			var metadata:Dynamic = getMetadata(json);

			c.loadGraphic('assets/images/$folder$char.png', true, frameInfo[0].sourceSize.w, frameInfo[0].sourceSize.h);

			var _SSW:Int = metadata.size.w;

			var animationsList:Map<String, AnimationData> = [];

			for (i in 0...frameInfo.length)
			{
				var parsedFrame = parseFrame(frameInfo[i], _SSW, defLoop);

				// it's not a blank frame
				if (parsedFrame.animation != null && parsedFrame.animation != "" && parsedFrame.animation != " ")
				{
					// the map already has the animation
					if (animationsList.exists(parsedFrame.animation))
					{
						animationsList[parsedFrame.animation].indices.push(parsedFrame.index);
					}
					// the map doesn't have this anim yet
					else
					{
						var animationData:AnimationData = {
							animation: parsedFrame.animation,
							indices: [parsedFrame.index],
							looped: parsedFrame.looped,
							flipX: parsedFrame.flipX,
							frameRate: parsedFrame.frameRate
						};
						animationsList.set(parsedFrame.animation, animationData);
					}
				}
			}

			json = null;
			frameInfo = null;
			metadata = null;

			var framerate:Int = 0;

			if (runFramerates.exists(char))
				framerate = runFramerates[char];
			else
				framerate = runFramerates['Pickle Frickle'];

			for (key in animationsList.keys())
				c.animation.add(key, animationsList[key].indices, animationsList[key].frameRate, animationsList[key].looped, animationsList[key].flipX);

			// trace(animationsList);
		}
		else
		{
			trace('Didn\'t find an animation json for $char. Make sure to export it in Aseprite');
			// playAnims = false;
		}

		// trace(Std.isOfType(c, FlxSprite) + 'its a flxsptite');
		return c;
	}
}
