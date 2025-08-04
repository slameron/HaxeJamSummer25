package objects;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;

class Text extends FlxBitmapText
{
	public var originalText:String;
	public var labelBounds:FlxPoint;
	public var center:Bool = false;

	public var sizeScale:Float;

	var labelText:Text;
	var labelTop:Bool;
	var size:Int;

	override public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, useBorder:Bool = false,
			borderStyle:FlxTextBorderStyle = SHADOW, colorBorder:FlxColor = FlxColor.BLACK)
	{
		super(X, Y, Text, Init.bmFont);
		originalText = Text;

		size = Size;

		sizeScale = size / 64;

		set_fieldWidth(Std.int(fieldWidth));
		if (useBorder)
			setBorderStyle(borderStyle, colorBorder, 8 * sizeScale, 8 * sizeScale);

		/*	#if web
			var htmlDiff:Int = Math.floor(height - size) - 4;
			height -= htmlDiff;
			offset.y = htmlDiff;
			#end */

		scale.set(sizeScale, sizeScale);

		updateHitbox();

		setPosition(Std.int(x), Std.int(y)); // Round the position to prevent weird tearing
	}

	public function addLabel(text:String, size:Int = 8, top:Bool = true)
	{
		labelText = new Text(0, 0, 0, text, size, false, borderStyle);
		labelText.alignment = CENTER;
		labelText.color = FlxColor.fromRGB(200, 200, 200);
		labelTop = top;
	}

	public function removeLabel()
	{
		labelText.destroy();
		labelText = null;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (labelText != null)
		{
			var yOff = labelText.size - 16;
			labelText.setPosition(center ? x + width / 2 - labelText.width / 2 : x + 5, labelTop ? y - labelText.height + yOff : y + height - yOff);
			labelText.alpha = alpha;
			var topBound:Float = labelBounds?.x ?? 223;
			topBound -= labelText.height;
			var bottomBound:Float = labelBounds?.y ?? 570;
			if (labelText.clipRect != null)
			{
				labelText.clipRect.put();
				labelText.clipRect = null;
			}
			if (labelText.y < topBound)
			{
				var yDiff = topBound - labelText.y;
				labelText.clipRect = FlxRect.get(0, yDiff, labelText.width, labelText.height - yDiff);
			}
			else if (labelText.y + labelText.height > bottomBound)
			{
				var yDiff = labelText.y + labelText.height - bottomBound;
				labelText.clipRect = FlxRect.get(0, 0, labelText.width, labelText.height - yDiff);
			}
		}
	}

	override public function draw()
	{
		super.draw();
		if (labelText != null)
			labelText.draw();
	}
}
