package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.system.FlxAssets;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.PosInfos;
import lime.app.Application;
import lime.system.System;
import openfl.Assets;
import util.Controls;

using StringTools;

#if sys
import sys.FileSystem;
#end

class Init extends FlxState
{
	public static var controls:Controls;

	public static var bmFont:FlxBitmapFont;

	public static var logs:Array<String> = [];
	public static var logsStored:Int = 8;

	public static function initStuff()
	{
		FlxG.log.redirectTraces = true;
		FlxG.fixedTimestep = false;
		FlxG.save.bind("haxesummer25", "slameron");

		FlxG.mouse.load('assets/images/mouseHand.png', 1);

		controls = new Controls();

		Sound.init();

		FlxG.sound.muteKeys = null;

		Application.current.meta.set('nightly', '');
		Application.current.meta.set('version', '0.0.1');
		Application.current.meta.set('title', ' Summer HaxeJam 2025');

		FlxG.game.soundTray.volumeUpSound = 'assets/sounds/volUp';
		FlxG.game.soundTray.volumeDownSound = 'assets/sounds/volDown';

		// if the player hasn't chosen to be in fullscreen via options. default to windowed mode
		if (FlxG.save.data.fullscreen == null)
		{
			FlxG.save.data.fullscreen = false;
			FlxG.save.flush();
		}

		FlxG.fullscreen = FlxG.save.data.fullscreen;

		if (FlxG.save.data.volume == null)
			FlxG.save.data.volume = .3;

		if (FlxG.save.data.highscore == null)
			FlxG.save.data.highscore = 0;

		if (FlxG.save.data.masterVolume == null)
			FlxG.save.data.masterVolume = 1;

		if (FlxG.save.data.soundVolume == null)
			FlxG.save.data.soundVolume = .75;
		if (FlxG.save.data.musicVolume == null)
			FlxG.save.data.musicVolume = .5;
		FlxG.save.flush();

		FlxG.sound.volume = FlxG.save.data.volume;

		var textBytes = Assets.getText("assets/fonts/slackey-font.fnt");
		var XMLData = Xml.parse(textBytes);
		bmFont = FlxBitmapFont.fromAngelCode("assets/fonts/slackey-font.png", XMLData);

		#if (!mobile && !webmobile)
		setExitHandler(function()
		{
			trace("Quit!");
			FlxG.save.data.volume = FlxG.sound.volume;
			FlxG.save.flush();
		});
		#end
	}

	override public function create()
	{
		initStuff();

		#if (desktop || (web && !webmobile))
		FlxG.mouse.visible = false;
		#end
		FlxG.switchState(() -> new states.MainMenuState());

		super.create();
	}

	static function setExitHandler(func:Void->Void):Void
	{
		#if openfl_legacy
		openfl.Lib.current.stage.onQuit = function()
		{
			func();
			openfl.Lib.close();
		};
		#else
		openfl.Lib.current.stage.application.onExit.add(function(code)
		{
			func();
		});
		#end
	}
}
