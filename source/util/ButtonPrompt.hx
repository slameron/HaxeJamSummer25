package util;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import lime.math.Rectangle;
import lime.utils.Assets;

class ButtonPrompt extends FlxSprite
{
	public var keyboard:FlxSprite;
	public var controller:FlxSprite;

	public var curKeyboard:String;
	public var curController:String;

	public var visibleByLastInput:Bool = true;
	public var text:Text;

	public var bound:FlxPoint;
	public var useClipRect:Bool = false;

	var controls(get, never):Controls;

	function get_controls():Controls
		return Init.controls;

	var iconScale:Float = 4;

	public var w(get, never):Float;

	function get_w():Float
	{
		if (text != null)
			if (controller.visible)
				return text.width + controller.width + 5;
			else
				return text.width + keyboard.width + 5;

		return keyboard.visible ? keyboard.width : controller.width;
	}

	public var h(get, never):Float;

	function get_h():Float
	{
		if (text != null)
			if (keyboard.visible)
				return keyboard.height > text.height ? keyboard.height : text.height;
			else
				return controller.height > text.height ? controller.height : text.height;

		return keyboard.visible ? keyboard.height : controller.height;
	}

	var parent:FlxObject;
	var parentOffset:FlxPoint;
	var centerAboveParent:Bool;

	override function set_cameras(cameras:Array<FlxCamera>):Array<FlxCamera>
	{
		super.set_cameras(cameras);

		if (text != null)
			text.cameras = cameras;
		keyboard.cameras = cameras;
		controller.cameras = cameras;
		return cameras;
	}

	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;
		keyboard.clipRect = rect;
		controller.clipRect = rect;
		return rect;
	}

	override function set_alpha(value:Float):Float
	{
		if (alpha == value)
		{
			return value;
		}

		alpha = FlxMath.bound(value, 0, 1);
		controller.alpha = value;
		keyboard.alpha = value;
		if (text != null)
			text.alpha = value;
		updateColorTransform();
		return value;
	}

	public function new(x:Int, y:Int, data:{keyboard:String, controller:String}, ?iconScale = 4, ?text:String, ?textSize:Int = 8, ?textScale:Float = 1,
			?textColor:FlxColor = FlxColor.WHITE, textBorderColor:FlxColor = FlxColor.BLACK, ?parent:FlxObject, ?parentOffset:FlxPoint, ?centerAboveParent:Bool)
	{
		super(x, y);
		if (text != null)
		{
			this.text = new Text(x, y, 0, text, textSize, true, SHADOW, textBorderColor);
			this.text.scale.set(textScale, textScale);
			this.text.updateHitbox();
			this.text.color = textColor;
		}
		this.parent = parent;
		this.parentOffset = parentOffset;
		this.centerAboveParent = centerAboveParent;

		this.iconScale = iconScale;

		makeGraphic(16, 16, FlxColor.TRANSPARENT);
		scale.set(iconScale, iconScale);
		updateHitbox();

		keyboard = new FlxSprite(x, y);
		if (data.keyboard == 'null')
			keyboard.makeGraphic(16, 16, FlxColor.TRANSPARENT);
		else
			keyboard.loadGraphic('assets/images/prompts/${data.keyboard}.png');
		keyboard.scale.set(iconScale, iconScale);
		keyboard.updateHitbox();

		var controllerPath = 'assets/images/prompts/${controls.controllerType != null ? controls.controllerType + '_' : ''}${data.controller}.png';
		if (!Assets.exists(controllerPath))
			controllerPath = 'assets/images/prompts/xbox_${data.controller}.png';
		if (!Assets.exists(controllerPath))
			controllerPath = 'assets/images/prompts/${data.controller}.png';
		controller = new FlxSprite(x, y, controllerPath);
		controller.scale.set(iconScale, iconScale);
		controller.updateHitbox();

		curKeyboard = data.keyboard;
		curController = data.controller;

		keyboard.visible = controls.lastInput == 'keyboard';
		controller.visible = controls.lastInput == 'controller';

		// this.text.origin.set(width / 2, height / 2);
		// origin.set(x - width / 2, height / 2);
		// controller.origin.set(controller.x - width / 2, height / 2);

		FlxG.gamepads.deviceConnected.add(gamepad ->
		{
			var controllerPath = 'assets/images/prompts/${controls.controllerType != null ? controls.controllerType + '_' : ''}${curController}.png';
			if (!Assets.exists(controllerPath))
				controllerPath = 'assets/images/prompts/${curController}.png';
			controller.loadGraphic(controllerPath);
			controller.scale.set(iconScale, iconScale);
			controller.updateHitbox();
		});
	}

	public function changeGraphic(?keyboard:String, ?controller:String)
	{
		if (keyboard != null && keyboard != curKeyboard)
		{
			curKeyboard = keyboard;
			this.keyboard.loadGraphic('assets/images/prompts/$keyboard.png');
			this.keyboard.scale.set(iconScale, iconScale);
			this.keyboard.updateHitbox();
		}

		if (controller != null && controller != curController)
		{
			curController = controller;
			var controllerPath = 'assets/images/prompts/${controls.controllerType != null ? controls.controllerType + '_' : ''}${controller}.png';
			if (!Assets.exists(controllerPath))
				controllerPath = 'assets/images/prompts/xbox_${controller}.png';
			if (!Assets.exists(controllerPath))
				controllerPath = 'assets/images/prompts/${controller}.png';
			this.controller.loadGraphic(controllerPath);
			this.controller.scale.set(iconScale, iconScale);
			this.controller.updateHitbox();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (visibleByLastInput)
		{
			keyboard.visible = controls.lastInput == 'keyboard';
			controller.visible = controls.lastInput == 'controller';
		}

		if (parent != null && parentOffset != null)
			if (centerAboveParent)
				setPosition(parent.x + parent.width / 2 - w / 2, parent.y + -h - parentOffset.y);
			else
				setPosition(parent.x + parent.width + parentOffset.x, parent.y + parentOffset.y + parent.height / 2 - h / 2);

		if (!useClipRect)
			return;
		var topBound:Float = 0;
		var bottomBound:Float = FlxG.height;
		if (bound != null)
		{
			topBound = bound.x;
			bottomBound = bound.y;
		}
		if (clipRect != null)
		{
			clipRect.put();
			clipRect = null;
		}
		if (y < topBound)
		{
			var yDiff = topBound - y;
			clipRect = FlxRect.get(0, yDiff, width, height - yDiff);
		}
		else if (y + height > bottomBound)
		{
			var yDiff = y + height - bottomBound;
			clipRect = FlxRect.get(0, 0, width, height - yDiff);
		}
	}

	override function draw()
	{
		if (text != null)
			text.setPosition(x, y);

		keyboard.setPosition(x, y #if !web + (text != null ? text.height / 2 - keyboard.height / 2 : 0) #end);
		controller.setPosition(x, y #if !web + (text != null ? text.height / 2 - controller.height / 2 : 0) #end);

		if (text != null)
		{
			keyboard.x += text.width;
			controller.x += text.width;
		}

		super.draw();
		if (controller.visible)
			controller.draw();
		if (keyboard.visible)
			keyboard.draw();
		if (text != null)
			if (text.visible)
				text.draw();
	}
}
