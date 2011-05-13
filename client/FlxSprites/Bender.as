package FlxSprites {
	import org.flixel.*;
	/**
	 * ...
	 * @author 
	 */
	public class Bender extends FlxSprite {
		[Embed(source = "../../images/aang.jpg")] private var ImgBender:Class;
		
		public var wPressed:Boolean;
		public var aPressed:Boolean;
		public var sPressed:Boolean;
		public var dPressed:Boolean;
		
		public function Bender(x: Number, y: Number):void {
			super(x, y, ImgBender);
		}
		
		override public function update():void {			
			if ((wPressed && sPressed) || (!wPressed && !sPressed))
				velocity.y = 0;
			else if (wPressed)
				velocity.y = -50;
			else
				velocity.y = 50;
			
			if ((aPressed && dPressed) || (!aPressed && !dPressed))
				velocity.x = 0;
			else if (aPressed)
				velocity.x = -50;
			else
				velocity.x = 50;
				
			super.update();
			
			/*
			if(x > FlxG.width-width-16)
				x = FlxG.width-width-16;
			else if(x < 16)
				x = 16;

			if(y > FlxG.height-height-16)
				y = FlxG.height-height-16;
			else if(y < 16)
				y = 16;			
			*/
		}
	}
}