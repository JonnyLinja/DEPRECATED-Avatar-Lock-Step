package {
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.ui.Mouse;
	import FlxStates.TitleState;
	import org.flixel.*; //Allows you to refer to flixel objects in your code
	//[SWF(width="640", height="480", backgroundColor="#000000")] //Set the size and color of the Flash file

	public class Avatar extends FlxGame {
		public static var inGame:Boolean;
		public function Avatar() {
			super(640, 480, TitleState, 1); //Create a new FlxGame object at 320x240 with 1x zoom, then load PlayState
			flash.ui.Mouse.show();
			FlxG.mouse.show();
		}
		
		//note, sounds have not been tested with my special update
		//overriden to reduce clutter, especially with getTimer()
		protected override function update(event:Event):void {
			if (inGame) {	
				//update
				FlxG.updateInput();
				//FlxG.updateSounds(); //commenting out doesn't stop sound tray
				_state.update();
				
				//mouse
				if(FlxG.mouse.cursor != null) {
					if(FlxG.mouse.cursor.active)
						FlxG.mouse.cursor.update();
					if(FlxG.mouse.cursor.visible)
						FlxG.mouse.cursor.render();
				}
			}else
				super.update(event);
		}
	}
}