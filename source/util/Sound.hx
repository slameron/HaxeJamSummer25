package util;

import flixel.FlxG;
import flixel.FlxObject;
#if (flixel <= version('5.3.0'))
import flixel.system.FlxSound;
#else
import flixel.sound.FlxSound;
#end

class Sound
{
	public static var panRadius:Float = 150;

	/**
	 * Access sound objects via their filename. They are automatically removed from the map when they are completed.
	 */
	public static var sounds:Map<String, SoundObject> = [];

	/**
	 * Access music objects via their filename.
	 */
	public static var musics:Map<String, SoundObject> = [];

	public static function init()
	{
		FlxG.signals.preStateSwitch.add(() ->
		{
			for (sound in sounds)
				sound.fadeOut(.5, 0, twn ->
				{
					if (sounds.exists(sound.filename)) // prevent null if sound finishes during fadeout
					{
						sounds.remove(sound.filename);
						sound.destroy();
					}
				});

			for (music in musics)
				if (!music.persist)
					music.fadeOut(.5, 0, twn ->
					{
						if (musics.exists(music.filename)) // prevent null if sound finishes during fadeout
						{
							musics.remove(music.filename);
							music.destroy();
						}
					});
		});
	}

	public static function play(key:String, ?source:FlxObject, ?playa:FlxObject):SoundObject
	{
		var newSound = new SoundObject();
		newSound.loadEmbedded(RetPath.sound(key));
		newSound.filename = key;
		newSound.volume = FlxG.save.data.soundVolume * FlxG.save.data.masterVolume;
		if (key == 'fire_shotgun')
			newSound.volume *= .4;

		newSound.targetVolume = newSound.volume;
		if (source != null)
			newSound.proximity(source.x + source.width / 2, source.y + source.height / 2, playa, panRadius, true);

		newSound.autoDestroy = true;
		newSound.onComplete = () -> if (sounds.exists(key) && !sounds.get(key).looped) sounds.remove(newSound.filename);
		newSound.play();

		sounds.set(key, newSound);

		updateSounds(0);

		return newSound;
	}

	public static function playMusic(key:String, persist:Bool = true):SoundObject
	{
		var newSound = new SoundObject();
		newSound.filename = key;
		newSound.loadEmbedded(RetPath.music(key), true);
		newSound.volume = FlxG.save.data.musicVolume * FlxG.save.data.masterVolume;
		newSound.targetVolume = newSound.volume;
		newSound.play();
		newSound.update(0);
		newSound.persist = persist;

		musics.set(key, newSound);

		return newSound;
	}

	public static function updateSounds(elapsed:Float)
	{
		for (sound in sounds)
			sound.update(elapsed);

		for (sound in musics)
			if (sound != null)
			{
				sound.targetVolume = FlxG.save.data.musicVolume * FlxG.save.data.masterVolume;
				sound.update(elapsed);
			}
	}
}

class SoundObject extends FlxSound
{
	public var targetVolume:Float;
	public var filename:String;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (fadeTween != null)
			if (fadeTween.active)
				return;

		volume = Helpers.lerp(volume, targetVolume, .1);
	}
}
