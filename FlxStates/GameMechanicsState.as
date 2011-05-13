package FlxStates {
	import Commands.Command;
	import FlxSprites.Bender;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author 
	 * 
	 * Deals with determining and executing gestures as well as sprites
	 */
	public class GameMechanicsState extends GameLogicState {
		//sprite groups
		private var sprite1:Bender;
		private var sprite2:Bender;
		
		//need player datastruct instead
		//this class should store stuff like sprite, cooldown, bender type, etc.
		
		public function GameMechanicsState(pAmP1:Boolean, pTurnLength:int, pMinUpdateTime:int) {
			super(pAmP1, pTurnLength, pMinUpdateTime);
		}
		
		override public function create():void {
			//background
			bgColor = 0xFFABCC7D;
			
			//p1
			sprite1 = new Bender(50, 50);
			add(sprite1);
			
			//p2
			sprite2 = new Bender(100, 100);
			add(sprite2);
			
			super.create();
		}
		
		protected override function executeCommand(command:Object):void {			
			var currentPlayer:Bender;
			
			if (command.player)
				currentPlayer = sprite1;
			else
				currentPlayer = sprite2;
			
			//update command is implied
			switch(command.command) {
				case Command.W:
					currentPlayer.wPressed = !currentPlayer.wPressed;
					break;
				case Command.A:
					currentPlayer.aPressed = !currentPlayer.aPressed;
					break;
				case Command.S:
					currentPlayer.sPressed = !currentPlayer.sPressed;
					break;
				case Command.D:
					currentPlayer.dPressed = !currentPlayer.dPressed;
					break;
			}
		}
	}
}