package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.FlxG;
import flixel.system.scaleModes.FillScaleMode;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.MultiVarTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	var title:FlxSprite;
	var tween:FlxTween;
	var isEnableKeyInput:Bool = false;
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
		
		// setup
		FlxG.cameras.bgColor = Reg.bgColor;
		//FlxG.scaleMode = new FillScaleMode();
		
		// display title
		title = new FlxSprite(FlxG.width >> 1, FlxG.height >> 2, "assets/images/sluggishFishTitle.png");
		title.x -= title.width / 2;
		title.y -= title.height / 2;
		title.scale.x = 0.2;
		title.scale.y = 0.2;
		tween = FlxTween.multiVar(title.scale, { x:1, y:1 }, 1, { ease: FlxEase.quadOut, complete:onDisplayTitleEnd });
		add(title);
	}
	
	private function onDisplayTitleEnd(tween:FlxTween):Void
	{
		var startText:FlxText = new FlxText(0, Std.int(FlxG.height*0.75), FlxG.width, "click or space to start");
		startText.alignment = "center";
		tween = FlxTween.multiVar(startText, { alpha:0 }, 2.5, { type:FlxTween.LOOPING, ease: FlxEase.expoIn });
		add(startText);
		isEnableKeyInput = true;
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		
		title = null;
		tween = null;
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		// key check
		if (isEnableKeyInput && (FlxG.keys.justPressed.SPACE || FlxG.mouse.justReleased)) {
			FlxG.switchState(new PlayState());
		}else if(FlxG.keys.justPressed.SPACE || FlxG.mouse.justReleased){
			tween.finish();
			title.scale.x = title.scale.y = 1;
		}
	}
}