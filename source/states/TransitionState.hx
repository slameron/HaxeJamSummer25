package states;

class TransitionState extends DefaultState
{
	var winner:Bool;
	var next:() -> Void;

	public function new(winner:Bool, next:() -> Void)
	{
		super();
		this.winner = winner;
		this.next = next;
	}

	override public function create()
	{
		super.create();

		var resultText = new Text(0, FlxG.height / 2 - 20, 0, winner ? "SUCCESS!" : "FAILED!", 32, true);
		resultText.screenCenter();
		resultText.color = winner ? 0xFF00FF00 : 0xFFFF0000;
		add(resultText);

		new FlxTimer().start(2.5, (tmr) ->
		{
			if (next != null)
			{
				next();
			}
		});
	}
}
