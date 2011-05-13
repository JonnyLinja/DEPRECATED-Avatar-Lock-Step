package FlxStates {
	import Commands.Command;
	import org.flixel.FlxG;
	import playerio.Message;
	import Networking.Net;
	import General.Utils;
	
	/**
	 * ...
	 * @author 
	 * 
	 * If user is currently playing a game
	 * Sends, receives, and stores commands
	 */
	
	//needs loss mouse focus check
	public class PlayState extends GameMechanicsState {
		//datastructures
		private var commandsToSend:Array; //outgoing
		
		//player commands
		private var w:Boolean;
		private var a:Boolean;
		private var s:Boolean;
		private var d:Boolean;
		
		public function PlayState(pAmP1:Boolean, pTurnLength:int, pMinUpdateTime:int) {
			super(pAmP1, pTurnLength, pMinUpdateTime);
			commandsToSend = new Array();
			Net.conn.addMessageHandler(Net.messageCommands, receiveCommands);
		}
		
		private function receiveCommands(m:Message):void {			
			//push message into queues
			enemyCommands.push(m);
			
			//merge
			mergeCommands();
		}
		
		public function updateInputs():void {
			//need to check in case a command missed
			if (FlxG.keys.pressed("W") != w) {
				w = !w;
				commandsToSend.push( { command:Command.W, gameTime:currentRealTime - turnStartRealTime } );
			}
			
			if(FlxG.keys.pressed("A") != a) {
				a = !a;
				commandsToSend.push( { command:Command.A, gameTime:currentRealTime - turnStartRealTime } );
			}
			
			if(FlxG.keys.pressed("S") != s) {
				s = !s;
				commandsToSend.push( { command:Command.S, gameTime:currentRealTime - turnStartRealTime } );
			}
			
			if(FlxG.keys.pressed("D") != d) {
				d = !d;
				commandsToSend.push( { command:Command.D, gameTime:currentRealTime - turnStartRealTime } );
			}
		}
		
		//send new commands
		protected override function executeNewTurn():void {			
			//create variables
			var m:Message = Net.conn.createMessage(Net.messageCommands);
			if (commandsToSend.length > 0) {
				//declare variables
				var current:Object;
				
				//determine ratio
				var ratio:Number = 1;
				var normalizedTime:int;
				
				if(commandsToSend.length > 0) {
					var lastGameTime:int = commandsToSend[commandsToSend.length - 1].gameTime;
					if (lastGameTime > turnLength) {
						//if command is longer than turn, then make ratio
						ratio = Utils.toFixed(turnLength / lastGameTime, 1000);
						//FlxG.log("ratio is " + ratio);
					}
				}
				
				//loop through commands
				while(commandsToSend.length > 0) {
					current = commandsToSend.shift();
					switch(current.command) {
						case Command.W:
						case Command.A:
						case Command.S:
						case Command.D:
							normalizedTime = current.gameTime * ratio;
							m.add(normalizedTime);
							m.add(current.command);
							break;
					}
				}
			}
			
			//send the message
			Net.conn.sendMessage(m);
			
			//push message into queue
			myCommands.push(m);
			
			//in case your game time is slower
			//should probably have a check and maybe force game clock to move faster so this never happens?
			mergeCommands();
		}
		
		protected override function updateEngine():void {
			updateInputs();
			super.updateEngine();
		}
	}
}