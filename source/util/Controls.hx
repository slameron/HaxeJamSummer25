package util;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;
// import flixel.ui.FlxVirtualPad;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.OneOfTwo;
import haxe.Json;

using StringTools;

#if sys
import sys.FileSystem;
#end

class Controls
{
	public var lastInput:String = #if mobile 'touch' #else 'keyboard' #end;

	public var controller(get, never):FlxGamepad;
	public var controllerType(get, never):String;

	// public var virtualPad:ControllerPad;
	var vpadCam:FlxCamera;

	function get_controllerType()
	{
		var type:Null<String> = null;

		if (controller != null)
			#if steam
			if (Steam.active)
				switch (Steam.controllers.getInputTypeForControllerIndex(0))
				{
					case 'PS4 Controller' | 'PS5 Controller':
						type = 'playstation';
					case 'Xbox 360 Controller' | 'Xbox One Controller' | 'Steam Deck':
						type = 'xbox';
					case 'Switch Pro':
						type = 'switch';
					default:
						type = 'xbox';
				}
			else
				switch (controller.detectedModel)
				{
					case PS4 | /*PS5 |*/ PSVITA:
						type = 'playstation';
					case XINPUT:
						type = 'xbox';
					case SWITCH_PRO:
						type = 'switch';

					default:
						type = 'xbox';
				}
			#else
			switch (controller.detectedModel)
			{
				case PS4 | /* PS5 |*/ PSVITA:
					type = 'playstation';
				case XINPUT:
					type = 'xbox';
				case SWITCH_PRO:
					type = 'switch';

				default:
					type = 'xbox';
			}
			#end
			return type;
	}

	function get_controller():FlxGamepad
	{
		return FlxG.gamepads.firstActive != null ? FlxG.gamepads.firstActive : FlxG.gamepads.getByID(0);
	}

	public var arrKeybinds = [
		'In Game:',
		'Up',
		'Left',
		'Down',
		'Right',
		'Jump',
		'Light_Attack',
		'Interact',
		'Menu:',
		'Menu_Up',
		'Menu_Left',
		'Menu_Down',
		'Menu_Right',
		'Menu_Last_Page',
		'Menu_Next_Page',
		'Menu_Accept',
		'Menu_Back',
		'Pause'
	];
	public var arrControllerBinds = [
		'In Game:',
		'Up',
		'Left',
		'Down',
		'Right',
		'Jump',
		'Light_Attack',
		'Interact',
		'Menu:',
		'Menu_Up',
		'Menu_Left',
		'Menu_Down',
		'Menu_Right',
		'Menu_Last_Page',
		'Menu_Next_Page',
		'Menu_Accept',
		'Menu_Back',
		'Pause'
	];

	var defaultBinds:Map<String, Array<OneOfTwo<FlxKey, FlxMouseButtonID>>> = [
		// In game
		'left' => [A, FlxKey.LEFT],
		'right' => [D, FlxKey.RIGHT],
		'up' => [W, UP],
		'down' => [S, DOWN],
		'jump' => [SPACE],
		'light_attack' => [FlxMouseButtonID.LEFT],
		'interact' => [E],
		// Menu
		'menu_left' => [A, FlxKey.LEFT],
		'menu_right' => [D, FlxKey.RIGHT],
		'menu_up' => [W, UP],
		'menu_down' => [S, DOWN],
		'menu_next_page' => [E],
		'menu_last_page' => [Q],
		'menu_accept' => [SPACE, ENTER],
		'menu_back' => [ESCAPE, BACKSPACE],
		'pause' => [ESCAPE],
	];
	var defaultControllerBinds:Map<String, Array<FlxGamepadInputID>> = [
		// In game
		'left' => [LEFT_STICK_DIGITAL_LEFT, DPAD_LEFT],
		'right' => [LEFT_STICK_DIGITAL_RIGHT, DPAD_RIGHT],
		'up' => [LEFT_STICK_DIGITAL_UP, DPAD_UP],
		'down' => [LEFT_STICK_DIGITAL_DOWN, DPAD_DOWN],
		'jump' => [A],
		'light_attack' => [X],
		'interact' => [Y],
		// Menu
		'menu_left' => [LEFT_STICK_DIGITAL_LEFT, DPAD_LEFT],
		'menu_right' => [LEFT_STICK_DIGITAL_RIGHT, DPAD_RIGHT],
		'menu_up' => [LEFT_STICK_DIGITAL_UP, DPAD_UP],
		'menu_down' => [LEFT_STICK_DIGITAL_DOWN, DPAD_DOWN],
		'menu_next_page' => [RIGHT_SHOULDER],
		'menu_last_page' => [LEFT_SHOULDER],
		'menu_accept' => [A],
		'menu_back' => [B],
		'pause' => [START],
	];

	public var userBinds:Map<String, Array<OneOfTwo<FlxKey, FlxMouseButtonID>>> = [];
	public var userControllerBinds:Map<String, Array<FlxGamepadInputID>> = [];

	// var blocking:Map<String, Bool> = [];
	var holdTime:Map<String, Float> = [];
	var lastHoldTime:Map<String, Float> = [];

	var releaseTime:Map<String, Float> = [];
	var lastReleaseTime:Map<String, Float> = [];
	var blockControls:Bool = false;
	var blockTime:Float = 0;

	var lastGameX:Float;
	var lastGameY:Float;

	var _timeSinceJustPressed:Map<String, Float> = [];

	public function new()
	{
		if (Save.exists('controls'))
			loadBinds();
		else
			resetBinds();
		#if sys
		trace(Sys.getCwd());
		trace(FileSystem.exists('${Sys.getCwd()}/save/controls.json'));
		#end

		FlxG.gamepads.deviceConnected.add(gamepad -> trace('new gamepad connected! ${gamepad.name} - model ${gamepad.model}'));
		FlxG.signals.preStateSwitch.add(() -> freezeControls());
	}

	public function freezeControls()
	{
		blockControls = true;
		blockTime = 0;
	}

	/*public function setupVirtualPad(context:String = 'menu'):ControllerPad
		{
			if (virtualPad != null)
			{
				virtualPad.destroy();
				virtualPad = null;
			}

			if (vpadCam != null)
			{
				FlxG.cameras.remove(vpadCam);
				vpadCam = null;
			}

			vpadCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
			vpadCam.bgColor = FlxColor.TRANSPARENT;
			FlxG.cameras.add(vpadCam, false);
			switch (context)
			{
				case 'menu':
					virtualPad = new ControllerPad('menu');
				case 'game':
					virtualPad = new ControllerPad('game');

				default:
					virtualPad = new ControllerPad('menu');
			}

			virtualPad.cameras = [vpadCam];

			return virtualPad;
	}*/
	public function update(elapsed:Float)
	{
		FlxG.watch.addQuick('Controller Variety', controller != null ? 'model ${controller.detectedModel} name 
		${controller.name}' : 'null');

		#if steam
		if (Steam.active)
		{
			if (FlxG.keys.justPressed.J)
				trace(Steam.controllers.getConnectedControllers());
			FlxG.watch.addQuick('controller steam handle', Steam.controllers.getInputTypeForControllerIndex(0));
		}
		#end

		if (blockControls)
			if ((blockTime += elapsed) >= .2)
				blockControls = false;

		#if FLX_KEYBOARD
		if (FlxG.keys.getIsDown().length > 0 #if FLX_MOUSE || lastGameX != FlxG.mouse.gameX || lastGameY != FlxG.mouse.gameY #end)
			lastInput = 'keyboard';
		#end

		lastGameX = FlxG.mouse.gameX;
		lastGameY = FlxG.mouse.gameY;

		// if (controller != null)
		//	if (controller.anyInput())
		//	lastInput = 'controller';
		// Sorry Don't Feel Like Implementing Controller Support for using the keyboard stuff

		FlxG.watch.addQuick('lastInput', lastInput);

		for (bind in _timeSinceJustPressed.keys())
			_timeSinceJustPressed.set(bind, _timeSinceJustPressed.get(bind) + elapsed);

		for (bind in userBinds.keys())
			if (pressed(bind))
			{
				if (holdTime.exists(bind))
					holdTime.set(bind, holdTime[bind] + elapsed);
				else
					holdTime.set(bind, elapsed);

				if (justPressed(bind))
				{
					lastReleaseTime.set(bind, releaseTime.get(bind));
					releaseTime.set(bind, 0);

					_timeSinceJustPressed.set(bind, 0);
				}
			}
			else if (justReleased(bind))
			{
				lastHoldTime.set(bind, holdTime.get(bind));
				holdTime.remove(bind);

				releaseTime.set(bind, 0);
			}
			else
			{
				if (releaseTime.exists(bind))
					releaseTime.set(bind, releaseTime[bind] + elapsed);
				else
					releaseTime.set(bind, elapsed);
			}

		for (input in pauseTime.keys())
		{
			pauseTime.set(input, pauseTime.get(input) + elapsed);
			if (pauseTime.get(input) >= paused.get(input))
			{
				pauseTime.remove(input);
				paused.remove(input);
			}
		}
	}

	/**
	 * Gets the amount of time in seconds that the input was previously held down.
	 * @param input The name of the control you want to check, i.e. `'sneak'`
	 * @return The amount of time (in seconds) the control was held down since being released. 
	 */
	public function getLastHeldTime(input:String):Float
	{
		if (lastHoldTime.exists(input))
			return lastHoldTime.get(input);
		return 0;
	}

	/**
	 * Checks how long the given input has been held down.
	 * @param input The name of the control you want to check, i.e. `'sneak'`
	 * @return Returns the amount of time (in seconds) the control has been held down. Will return 0 if the control is wrong or not currently being held down.
	 */
	public function heldTime(input:String):Float
	{
		if (blockControls)
			return 0;
		if (holdTime.exists(input))
			return holdTime.get(input);
		return 0;
	}

	/**
	 * Gets the amount of time in seconds that the input was previously released.
	 * @param input The name of the control you want to check, i.e. `'sneak'`
	 * @return The amount of time (in seconds) the control was released since being held.
	 */
	public function getLastReleasedTime(input:String):Float
	{
		if (lastReleaseTime.exists(input))
			return lastReleaseTime.get(input);
		return 999;
	}

	/**
	 * Checks how long the given input has been released.
	 * @param input The name of the control you want to check, i.e. `'sneak'`
	 * @return Returns the amount of time (in seconds) the control has been released. Will return 999 if the control is wrong or is currently being held down.
	 */
	public function releasedTime(input:String):Float
	{
		if (blockControls)
			return 999;
		if (releaseTime.exists(input))
			return releaseTime.get(input);
		return 999;
	}

	public function timeSinceJustPressed(bind:String):Float
	{
		if (_timeSinceJustPressed.exists(bind))
			return _timeSinceJustPressed.get(bind);
		return 999;
	}

	/**
	 * How long the input should be paused for.
	 */
	var paused:Map<String, Float> = [];

	/*How long the input has been paused for.
	 */
	var pauseTime:Map<String, Float> = [];

	/**
	 * Pause an input from returning true for `pauseTime` in seconds.
	 * @param input The name of the input you want to lock, i.e. `'back'`
	 * @param pauseTime How long, in seconds, you want to lock the input for.
	 */
	public function pause(input:String, pauseTime:Float)
	{
		paused.set(input, pauseTime);
		this.pauseTime.set(input, 0);
	}

	public function justPressed(input:String):Bool
	{
		/*if (blocking.exists(input))
			{
				blocking.remove(input);
				return false;
		}*/
		if (blockControls)
			return false;
		if (paused.exists(input))
			return false;
		#if FLX_KEYBOARD
		if (userBinds.exists(input))
		{
			if (userBinds.get(input).contains(FlxMouseButtonID.LEFT)
				|| userBinds.get(input).contains(FlxMouseButtonID.RIGHT)
				|| userBinds.get(input).contains(FlxMouseButtonID.MIDDLE))
			{
				var justPressedMouseButton:Bool = false;

				if (userBinds.get(input).contains(FlxMouseButtonID.LEFT))
					if (FlxG.mouse.justPressed)
						justPressedMouseButton = true;

				if (userBinds.get(input).contains(FlxMouseButtonID.RIGHT))
					if (FlxG.mouse.justPressedRight)
						justPressedMouseButton = true;

				if (userBinds.get(input).contains(FlxMouseButtonID.MIDDLE))
					if (FlxG.mouse.justPressedMiddle)
						justPressedMouseButton = true;

				if (justPressedMouseButton)
				{
					// blocking.set(input, true);
					// new FlxTimer().start(.01, tmr -> blocking.remove(input));
					return true;
				}
			}
			if (FlxG.keys.anyJustPressed(userBinds.get(input).filter(k -> cast(k, Int) >= 0)))
			{
				// blocking.set(input, true);
				// new FlxTimer().start(.01, tmr -> blocking.remove(input));
				return true;
			}
		}
		#end
		if (userControllerBinds.exists(input))
		{
			if (controller != null)
				if (controller.anyJustPressed(userControllerBinds.get(input)))
				{
					// blocking.set(input, true);
					// new FlxTimer().start(.01, tmr -> blocking.remove(input));
					return true;
				}
		}
		return false;
	}

	public function pressed(input:String):Bool
	{
		if (blockControls)
			return false;
		var ret = false;
		if (paused.exists(input))
			return false;
		#if FLX_KEYBOARD
		if (userBinds.exists(input))
		{
			if (userBinds.get(input).contains(FlxMouseButtonID.LEFT)
				|| userBinds.get(input).contains(FlxMouseButtonID.RIGHT)
				|| userBinds.get(input).contains(FlxMouseButtonID.MIDDLE))
			{
				var pressedMouseButton:Bool = false;

				if (userBinds.get(input).contains(FlxMouseButtonID.LEFT))
					if (FlxG.mouse.pressed)
						pressedMouseButton = true;

				if (userBinds.get(input).contains(FlxMouseButtonID.RIGHT))
					if (FlxG.mouse.pressedRight)
						pressedMouseButton = true;

				if (userBinds.get(input).contains(FlxMouseButtonID.MIDDLE))
					if (FlxG.mouse.pressedMiddle)
						pressedMouseButton = true;

				if (pressedMouseButton)
				{
					// blocking.set(input, true);
					// new FlxTimer().start(.01, tmr -> blocking.remove(input));
					ret = true;
				}
			}
			if (!ret)
				ret = FlxG.keys.anyPressed(userBinds.get(input).filter(k -> cast(k, Int) >= 0));
		}
		#end

		if (controller != null)
			if (userControllerBinds.exists(input))
				ret = ret == true ? true : controller.anyPressed(userControllerBinds.get(input));
		return ret;
	}

	public function justReleased(input:String):Bool
	{
		if (blockControls)
			return false;
		var ret = false;
		if (paused.exists(input))
			return false;
		#if FLX_KEYBOARD
		if (userBinds.exists(input))
		{
			if (userBinds.get(input).contains(FlxMouseButtonID.LEFT)
				|| userBinds.get(input).contains(FlxMouseButtonID.RIGHT)
				|| userBinds.get(input).contains(FlxMouseButtonID.MIDDLE))
			{
				var justReleasedMouseButton:Bool = false;

				if (userBinds.get(input).contains(FlxMouseButtonID.LEFT))
					if (FlxG.mouse.justReleased)
						justReleasedMouseButton = true;

				if (userBinds.get(input).contains(FlxMouseButtonID.RIGHT))
					if (FlxG.mouse.justReleasedRight)
						justReleasedMouseButton = true;

				if (userBinds.get(input).contains(FlxMouseButtonID.MIDDLE))
					if (FlxG.mouse.justReleasedMiddle)
						justReleasedMouseButton = true;

				if (justReleasedMouseButton)
				{
					// blocking.set(input, true);
					// new FlxTimer().start(.01, tmr -> blocking.remove(input));
					ret = true;
				}
			}
			if (!ret)
				ret = FlxG.keys.anyJustReleased(userBinds.get(input).filter(k -> cast(k, Int) >= 0));
		}
		#end

		if (controller != null)
			if (userControllerBinds.exists(input))
				ret = ret == true ? true : controller.anyJustReleased(userControllerBinds.get(input));
		return ret;
	}

	public function any():Bool
	{
		if (blockControls)
			return false;
		#if FLX_KEYBOARD
		for (bind in userBinds.keys())
			if (FlxG.keys.anyPressed(userBinds.get(bind)))
				return true;
		#end
		for (bind in userBinds.keys())
			if (controller != null)
				if (controller.anyPressed(userControllerBinds.get(bind)))
					return true;
		return false;
	}

	public function anyCtrl():Bool
	{
		if (blockControls)
			return false;
		for (bind in userControllerBinds.keys())
			if (controller != null)
				if (controller.anyPressed(userControllerBinds.get(bind)))
					return true;
		return false;
	}

	public function allOf(inputs:Array<String>):Bool
	{
		if (blockControls)
			return false;
		var ret = true;
		#if FLX_KEYBOARD
		if (lastInput == 'keyboard')
			for (input in inputs)
				if (userBinds.exists(input))
					if (!FlxG.keys.anyPressed(userBinds.get(input)))
					{
						ret = false;
						break;
					}
		#end
		if (lastInput == 'controller')
			if (controller != null)
				for (input in inputs)
					if (userControllerBinds.exists(input))
						if (!controller.anyPressed(userControllerBinds.get(input)))
						{
							ret = false;
							break;
						}

		return ret;
	}

	public function noneOf(inputs:Array<String>):Bool
	{
		if (blockControls)
			return false;
		var ret = true;
		#if FLX_KEYBOARD
		if (lastInput == 'keyboard')
			for (input in inputs)
				if (userBinds.exists(input))
					if (FlxG.keys.anyPressed(userBinds.get(input)))
					{
						ret = false;
						break;
					}
		#end
		if (lastInput == 'controller')
			if (controller != null)
				for (input in inputs)
					if (userControllerBinds.exists(input))
						if (controller.anyPressed(userControllerBinds.get(input)))
						{
							ret = false;
							break;
						}

		return ret;
	}

	#if FLX_KEYBOARD
	public function changeBind(input:String, index:Int = 0, newKey:OneOfTwo<FlxKey, FlxMouseButtonID>)
	{
		if (userBinds.exists(input))
			userBinds.get(input)[index] = newKey;
		saveBinds();
	}
	#end

	public function changeControllerBind(input:String, index:Int = 0, newBind:FlxGamepadInputID)
	{
		if (userControllerBinds.exists(input))
			userControllerBinds.get(input)[index] = newBind;
		saveBinds();
	}

	public function resetBinds()
	{
		userBinds = defaultBinds;
		userControllerBinds = defaultControllerBinds;
		saveBinds();
	}

	public function saveBinds()
		Save.save(bindsToJson(), 'controls', false);

	public function loadBinds()
	{
		var json = Save.load('controls');
		var binds:Array<Dynamic> = json.binds;
		#if FLX_KEYBOARD
		for (bind in binds)
		{
			var input:String = bind.input;
			var keys:Array<String> = bind.keys;
			var daKeys:Array<OneOfTwo<FlxKey, FlxMouseButtonID>> = [];

			for (key in keys)
				if (key.contains('_MOUSE'))
					daKeys.push(switch (key.replace('_MOUSE', ''))
					{
						case 'LEFT':
							FlxMouseButtonID.LEFT;
						case 'RIGHT':
							FlxMouseButtonID.RIGHT;
						case 'MIDDLE':
							FlxMouseButtonID.MIDDLE;

						default:
							null;
					});
				else
					daKeys.push(FlxKey.fromString(key));
			userBinds.set(input, daKeys);
		}

		for (key in defaultBinds.keys())
			if (!userBinds.exists(key))
				userBinds.set(key, defaultBinds[key]);
		#end

		var ctrlbinds:Array<Dynamic> = json.ctrlbinds;
		for (bind in ctrlbinds)
		{
			var input:String = bind.input;
			var keys:Array<String> = bind.keys;
			var daKeys:Array<FlxGamepadInputID> = [for (key in keys) FlxGamepadInputID.fromString(key)];
			userControllerBinds.set(input, daKeys);
		}
		for (key in defaultControllerBinds.keys())
			if (!userControllerBinds.exists(key))
				userControllerBinds.set(key, defaultControllerBinds[key]);
		saveBinds();
	}

	public function bindsToJson():Dynamic
	{
		var binds = [];
		var ctrlbinds = [];
		#if FLX_KEYBOARD
		for (bind in userBinds.keys())
		{
			var keys = [];
			for (key in userBinds[bind])
				keys.push(cast(key, Int) >= 0 ? cast(key, FlxKey).toString() : switch (cast(key, FlxMouseButtonID))
				{
					case LEFT: 'LEFT_MOUSE';
					case RIGHT: 'RIGHT_MOUSE';
					case MIDDLE: 'MIDDLE_MOUSE';
				});
			binds.push({
				input: bind,
				keys: keys
			});
		}
		#end

		for (bind in userControllerBinds.keys())
		{
			var keys = [];
			for (key in userControllerBinds[bind])
				keys.push(key.toString());
			ctrlbinds.push({
				input: bind,
				keys: keys
			});
		}
		var json:{binds:Array<{input:String, keys:Array<String>}>, ctrlbinds:Array<{input:String, keys:Array<String>}>} = {
			binds: binds,
			ctrlbinds: ctrlbinds
		};
		return json;
	}

	public function getPrompt(control:String = 'default', ?font:Bool = false, ?index:Int = 0)
	{
		var data = {keyboard: 'mouse', controller: 'rstick_neutral'}
		if (control == 'default')
			return data;

		if (userBinds.exists(control))
			if (userBinds[control].length - 1 >= index)
			{
				if (cast(userBinds[control][index], Int) >= 0)
					data.keyboard = cast(userBinds[control][index], FlxKey).toString().toLowerCase().replace('numpad', '');
				else
					data.keyboard = switch (cast(userBinds[control][index], FlxMouseButtonID))
					{
						case LEFT: 'click_left';
						case RIGHT: 'click_right';
						case MIDDLE: 'click_middle';
					}
			}
			else
				data.keyboard = 'empty';
		if (userControllerBinds.exists(control))
			if (userControllerBinds[control].length - 1 >= index)
				data.controller = userControllerBinds[control][index].toString()
					.replace('LEFT_STICK_', 'lstick_')
					.replace('RIGHT_STICK_', 'rstick_')
					.replace('DIGITAL_', '')
					.toLowerCase();
			else
				data.controller = 'empty';

		if (controllerType == 'playstation' && font)
		{
			data.controller = switch (data.controller)
			{
				case 'a': '£';
				case 'b': '¢';
				case 'x': '¤';
				case 'y': '€';
				default: data.controller;
			}
		}

		if (FlxG.onMobile)
		{
			data.controller = switch (data.controller)
			{
				case 'a': '¥';
				case 'b': 'X';

				default: data.controller;
			}
		}
		return data;
	}
}
