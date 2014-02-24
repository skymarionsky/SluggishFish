package ;

import flixel.FlxSprite;
import flixel.FlxG;

/**
 * ...
 * @author Yohei Marion Okuyama
 */
class Player extends FlxSprite
{
	private var _speed:Float = 80.0;
	private var _maxSpeed:Float = 80.0;
	private var _buoyancy:Float = -3.0;
	private var _maxBuoyancy:Float = -80.0;
	private var _sleepAnimeTiming:Float = -20.0;
	
	public var isMoving = false;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);
		loadGraphic("assets/images/fishPlayer.png", true, false, 16, 16);
		animation.add("swim", [0, 1, 2, 3], 10, true);
		animation.add("sleep", [4, 5, 6, 7], 5, true);
		animation.add("dead", [8, 9, 10, 11], 15, false);
		width = 12;
		height = 8;
		offset.x = 1;
		offset.y = 6;
	}
	
	public function toCenter():Void
	{
		x -= width / 2;
		y -= height / 2;
	}
	
	public function swim():Void
	{
		FlxG.sound.play("assets/sounds/jump.wav");
		
		if (velocity.y < 0) {
			velocity.y = _speed;
		}else {
			velocity.y += _speed;
		}		
		if (velocity.y > _maxSpeed) {
			velocity.y = _maxSpeed;
		}
		if (velocity.y > 0 ) {
			animation.play("swim");
		}
		
		//trace(y);
	}
	
	public function dead():Void
	{
		animation.play("dead");
		velocity.y = 0;
		isMoving = false;
		
		// camera action
		FlxG.camera.shake(0.01, 0.5);
		FlxG.camera.flash(0xF0FF0000, 0.5);
		
		// sound
		FlxG.sound.play("assets/sounds/hit.wav");
		
	}
	
	public override function update():Void
	{
		super.update();
		if (isMoving) {
			velocity.y += _buoyancy;
			if (velocity.y < _maxBuoyancy) {
				velocity.y = _maxBuoyancy;
			}
			if (velocity.y <= _sleepAnimeTiming) {
				animation.play("sleep");
			}
		}		
	}
	
	public override function kill():Void
	{
		super.kill();
	}
}