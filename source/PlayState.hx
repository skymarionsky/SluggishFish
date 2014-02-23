package ;

import flixel.animation.FlxAnimation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var player:Player;
	var arrows:Array<FlxSprite>;
	var oceans:Array<FlxSprite>;
	var startText:FlxText;
	var gameoverText:FlxText;
	var scoreText:FlxText;
	var waitText:FlxText;
	var isPaused:Bool = true;
	var isGameoverWaiting:Bool = false;
	
	private var _oceanSpeed = -0.2;
	private var _deadZone = 0;
	
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
		
		// setup
		FlxG.cameras.bgColor = Reg.bgColor;
		
		// player
		player = new Player(FlxG.width / 3, FlxG.height / 2);
		player.toCenter();
		player.animation.play("sleep");
		add(player);
		
		// wait for start
		waitForStart();
	}
	
	function waitForStart():Void
	{
		isPaused = true;
		player.isMoving = false;
		// arrows
		arrows = new Array<FlxSprite>();
		for (i in 0...3) {
			var arrow:FlxSprite = new FlxSprite((FlxG.width >> 1)+(i*9), FlxG.height >> 1);
			arrow.loadGraphic("assets/images/arrow.png", true, false, 9, 16);
			arrow.animation.add("idle", [0, 1, 2], 5, true);
			arrow.animation.play("idle");
			add(arrow);
			arrows.push(arrow);
		}
		// text
		startText = new FlxText(FlxG.width>>1, FlxG.height>>3, FlxG.width>>2, "click or space to swim");
		add(startText);
		// oceans
		oceans = new Array<FlxSprite>();
		for (i in 0...21) {
			var ocean:FlxSprite = new FlxSprite(i * 8,0);
			ocean.loadGraphic("assets/images/ocean.png", true, false, 8, 4);
			ocean.animation.add("wave", [0, 1, 2, 3], FlxRandom.intRanged(6,10), true);
			ocean.animation.play("wave");
			add(ocean);
			oceans.push(ocean);
		}
		
	}
	
	function onGameover():Void
	{
		FlxTimer.start(0.5,onGameoverReady);
	}
	
	function onGameoverReady(timer:FlxTimer):Void
	{
		isGameoverWaiting = true;
		gameoverText = new FlxText(0, FlxG.height >> 2, FlxG.width, "Game Over");
		gameoverText.alignment = "center";
		add(gameoverText);
		scoreText = new FlxText(0, FlxG.height >> 1, FlxG.width, "Score: " + Reg.score);
		scoreText.alignment = "center";
		add(scoreText);
		waitText = new FlxText(0, FlxG.height -(FlxG.height >> 2), FlxG.width, "click or space to continue");
		waitText.alignment = "center";
		add(waitText);
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		player = null;
		arrows = null;
		startText = null;
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		if (isPaused) {
			// click or space to start
			if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justReleased) {
				isPaused = false;
				player.isMoving = true;
				player.swim();
				startText.kill();
				for (i in 0...arrows.length) {
					arrows[i].kill();
				}
			}
		}else {
			if (isGameoverWaiting) {
				// click or space to continue
				if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justReleased) {
					FlxG.resetState();
				}
			}
			// move ocean
			if (player.isMoving) {
				for (i in 0...oceans.length) {
					oceans[i].x += _oceanSpeed;
					if (oceans[i].x <= -8) {
						oceans[i].x = FlxG.width;
					}
				}
				if (player.y <= _deadZone) {
					player.dead();
					onGameover();
				}
				// swim
				if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justReleased) {
					player.swim();
				}
			}
		}
	}
}