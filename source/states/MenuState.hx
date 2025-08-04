package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class MenuState extends DefaultState
{
	var menuList:SelectionList;

	override public function create()
	{
		super.create();

		var bg = new FlxBackdrop(FlxGridOverlay.createGrid(16, 16, 32, 32, true, 0xFF4661A0, 0xFF5335A1), XY);

		bg.velocity.set(25, 25);
		add(bg);

		var defY = FlxG.height / 2 - 15;
		var spacing = 35;
		var borderStyle:FlxTextBorderStyle = SHADOW;

		menuList = new SelectionList(defY, spacing, borderStyle);

		menuList.addCallback('Hello World', f ->
		{
			FlxG.switchState(() -> new PlayState());
		});

		menuList.addCallback('Options', f -> {});

		#if desktop
		menuList.addCallback('Quit', f ->
		{
			Sys.exit(0);
		});
		#end

		add(menuList);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.justPressed('menu_back'))
			if (menuList.parentMenu != null)
				trace('nothing'); // FlxG.switchState(() -> new IntroScene());
			else
				menuList.focusedMenu.select(0, 'Back');

		if (controls.justPressed('menu_up'))
			change(-1);
		if (controls.justPressed('menu_down'))
			change(1);

		menuList.focusedMenu.forEach(spr ->
		{
			if (spr.ID == menuList.focusedMenu.curSelected)
				spr.color = 0xFFffcc26;
			else
				spr.color = FlxColor.WHITE;
		});
		menuList.setAllRight();
		menuList.focusedMenu.targetX = 30;
		var topMenu:objects.SelectionList = menuList.focusedMenu;
		var submenus:Int = 0;
		while (topMenu.parentMenu != null)
		{
			submenus++;
			topMenu = topMenu.parentMenu;
			topMenu.targetX = 0 - FlxG.width * submenus;
		}

		if (controls.justPressed('menu_accept') && !selected)
			menuList.focusedMenu.select();
		if (controls.justPressed('menu_left') && !selected)
			menuList.focusedMenu.select(-1);
		if (controls.justPressed('menu_right') && !selected)
			menuList.focusedMenu.select(1);
	}

	var selected:Bool = false;

	function change(by:Int = 0)
	{
		menuList.focusedMenu.curSelected = retSel(menuList.focusedMenu.curSelected + by);
		menuList.focusedMenu.scroll(by);
		Sound.play('menuChange');
	}

	function retSel(sel:Int, online = false):Int
	{
		return Std.int(FlxMath.bound(sel, 0, menuList.focusedMenu.length - 1));
		/*return if (sel >= menuList.focusedMenu.length) retSel(sel - menuList.focusedMenu.length) else if (sel < 0) retSel(menuList.focusedMenu.length +
			sel) else sel; */
	}
}
