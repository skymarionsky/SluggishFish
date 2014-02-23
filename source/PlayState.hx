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
import flixel.util.FlxCollision;
import flixel.group.FlxTypedGroup;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var layer:FlxTypedGroup<FlxSprite>;
	var lightEffect:LightEffects;
	var light:FlxSprite;
	var player:Player;
	var arrows:Array<FlxSprite>;
	var oceans:Array<FlxSprite>;
	var enemies:Array<Enemy>;
	var startText:FlxText;
	var gameoverText:FlxText;
	var scoreText:FlxText;
	var waitText:FlxText;
	
	var isPaused:Bool = true;
	var isGameoverWaiting:Bool = false;
	
	var _oceanSpeed:Float = -0.4;
	var _deadZone:Float = -4;
	var _nextEnemySpawn:Float = 0;
	var _nextEnemyInterval:Float = 80;
	
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
		
		// visual setup
		FlxG.cameras.bgColor = Reg.bgColor;
		lightEffect = new LightEffects();
		light = lightEffect.addLight128();
		
		// layer
		layer = new FlxTypedGroup<FlxSprite>();
		add(layer);
		
		// player
		player = new Player(FlxG.width / 3, FlxG.height / 2);
		player.toCenter();
		player.animation.play("sleep");
		layer.add(player);
		
		// enemy init
		enemies = new Array<Enemy>();
		
		// add light effect
		light.x = player.x + player.width/2 - light.width/2;
		light.y = player.y + player.width/2 - light.height/2;
		add(lightEffect);
		lightEffect.visible = false;
		
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
		startText = new FlxText(FlxG.width >> 1, FlxG.height >> 3, FlxG.width >> 2, "click or space to swim");
		//startText.setBorderStyle(FlxText.BORDER_OUTLINE);
		add(startText);
		// oceans
		oceans = new Array<FlxSprite>();
		for (i in 0...21) {
			var ocean:FlxSprite = new FlxSprite(i * 8,0);
			ocean.loadGraphic("assets/images/ocean.png", true, false, 8, 4);
			ocean.animation.add("wave", [0, 1, 2, 3], FlxRandom.intRanged(6,10), true);
			ocean.animation.play("wave");
			layer.add(ocean);
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
		gameoverText.setBorderStyle(FlxText.BORDER_OUTLINE);
		gameoverText.alignment = "center";
		add(gameoverText);
		scoreText = new FlxText(0, FlxG.height >> 1, FlxG.width, "Score: " + Reg.score);
		scoreText.setBorderStyle(FlxText.BORDER_OUTLINE);
		scoreText.alignment = "center";
		add(scoreText);
		waitText = new FlxText(0, FlxG.height -(FlxG.height >> 2), FlxG.width, "click or space to continue");
		waitText.setBorderStyle(FlxText.BORDER_OUTLINE);
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
		oceans = null;
		enemies = null;
		startText = null;
		gameoverText = null;
		scoreText = null;
		waitText = null;		
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
				lightEffect.visible = true;
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
				// move enemy
				var isHit = false;
				for (i in 0...enemies.length) {
					enemies[i].x += _oceanSpeed;
					// hit test
					if (player.x <= enemies[i].x + enemies[i].width && player.x + player.width >= enemies[i].x) {
						if (FlxCollision.pixelPerfectCheck(player, enemies[i])) {
							isHit = true;
							break;
						}
						if (!enemies[i].isScored && enemies[i].x+(enemies[i].width/2) < player.x+(player.width/2)) {
							Reg.score += 1;
							enemies[i].isScored = true;
						}
					}
				}
				if (isHit) {
					player.dead();
					onGameover();
					return;
				}
				if (enemies.length > 1 && enemies[0].x <= -32) {
					enemies[0].destroy();
					enemies.shift();
				}
				// spawn new enemy
				if (_nextEnemySpawn <= 0) {
					var ry:Int = FlxRandom.intRanged(5, 45);
					enemies.push(addEnemy(FlxG.width, ry));
					if (Reg.score >= 1 ) {
						var rnd:Int = (Reg.score > 10)?2:((Reg.score > 5)?3:4);
						if (FlxRandom.intRanged(0, rnd) == 0) {
							enemies.push(addEnemy(FlxG.width,FlxRandom.intRanged(ry+32, FlxG.height-32)));
						}
					}
					_nextEnemySpawn = _nextEnemyInterval;
				}
				_nextEnemySpawn += _oceanSpeed;
				if (player.y <= _deadZone) {
					player.dead();
					onGameover();
				}
				// swim
				if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justReleased) {
					if (player.y < FlxG.height - player.height) {
						player.swim();
					}
				}
			}
			light.x = player.x + player.width/2 - light.width/2;
			light.y = player.y + player.width/2 - light.height/2;
		}
	}
	
	function addEnemy(x:Int, y:Int):Enemy
	{
		var enemy = new Enemy(x, y);
		enemy.loadGraphic("assets/images/jellyfish.png", true, false, 32, 32);
		enemy.animation.add("idle", [0, 1], 5, true);
		enemy.animation.play("idle");
		layer.add(enemy);
		return enemy;
	}
}