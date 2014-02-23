package ;
import flixel.FlxSprite;

/**
 * ...
 * @author Yohei Marion Okuyama
 */
class Enemy extends FlxSprite
{

	public var isScored = false;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);
	}
	
}