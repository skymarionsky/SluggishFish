package ;

import flixel.FlxSprite;
import flixel.FlxG;
import flash.display.BlendMode;

/**
 * ...
 * @author Yohei Marion Okuyama
 */
class LightEffects extends FlxSprite
{
	var lights:Array<FlxSprite>;
	var darkness:FlxSprite;
	
	public function new()
	{
		super(0, 0);
		lights = new Array<FlxSprite>();
		darkness = makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		blend = BlendMode.MULTIPLY;
	}
	
	public function addLight32(x:Int=0, y:Int=0)
	{
		trace("addLight32");
		var light:FlxSprite;
		light = new FlxSprite(x, y, "assets/images/light32.png");
		trace(x);
		trace(y);
		light.blend = BlendMode.SCREEN;
		var id = lights.push(light) - 1;
		return light;
	}
	
	public function addLight64(x:Int=0, y:Int=0)
	{
		var light:FlxSprite;
		light = new FlxSprite(x, y, "assets/images/light32.png");
		light.blend = BlendMode.SCREEN;
		var id = lights.push(light) - 1;
		return light;
	}

	
	override public function update()
	{
		super.update();
		resetFrameBitmapDatas();
		stamp(darkness, 0, 0);
		for (i in 0...lights.length) {
			stamp(lights[i], Std.int(lights[i].x), Std.int(lights[i].y));
		}
	}
	
}