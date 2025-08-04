package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import objects.PopUpUI;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import util.Sound;

class DefaultState extends FlxTransitionableState
{
	var controls(get, null):util.Controls;
	var transitioning:Bool = false;
	var shouldRet:Bool;

	function get_controls()
		return Init.controls;

	override function update(elapsed:Float)
	{
		shouldRet = false;
		Sound.updateSounds(elapsed);
		controls.update(elapsed);
		for (popup in PopUpUI.popups)
			popup.update(elapsed);
		if (PopUpUI.popups.length > 0)
			shouldRet = true;

		super.update(elapsed);
	}

	override public function draw()
	{
		super.draw();
		for (popup in PopUpUI.popups)
			popup.draw();
	}

	// set the false to true when it works
	override public function new(transition:Bool = false)
	{
		super();

		if (transition)
		{
			tempSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
			tempSprite.pixels.draw(FlxG.camera.canvas);

			tempSprite2 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
			tempSprite2.pixels.draw(tempSprite.pixels, new Matrix(1, 0, 0, 1, 0, -FlxG.height / 2));
		}
	}

	override public function create()
	{
		if (tempSprite != null)
		{
			transitioning = true;
			var top = new FlxSprite(0, 0).makeGraphic(FlxG.camera.width, Std.int(FlxG.camera.height / 2), FlxColor.TRANSPARENT);
			top.pixels.draw(tempSprite.pixels, null, null, null, new Rectangle(0, 0, FlxG.width, FlxG.height / 2));
			add(top);

			var bottom = new FlxSprite(0, Std.int(FlxG.height / 2)).makeGraphic(FlxG.camera.width, Std.int(FlxG.camera.height / 2), FlxColor.TRANSPARENT);
			bottom.pixels.draw(tempSprite2.pixels, null, null, null, new Rectangle(0, 0, FlxG.width, FlxG.height / 2));
			add(bottom);

			tempSprite = tempSprite2 = null;
		}
	}

	var tempSprite:FlxSprite;
	var tempSprite2:FlxSprite;
}
