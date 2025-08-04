package;

import flixel.FlxGame;
import flixel.FlxState;
import lime.app.Application;
import openfl.display.Sprite;

class Main extends Sprite
{
	private static inline var DES_W:Int = 640;
	private static inline var DES_H:Int = 360;

	public function new()
	{
		super();
		var init:Class<FlxState> = Init;

		var framerate:Int = 999;
		#if web
		// pixel perfect render fix!
		Application.current.window.element.style.setProperty("image-rendering", "pixelated");
		#end

		var game = new FlxGame(DES_W, DES_H, init, framerate, framerate, true);

		// @:privateAccess
		// game._customSoundTray = SoundTray;

		addChild(game);
	}
}
