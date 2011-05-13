package FlxStates {
	import Commands.Command;
	import flash.utils.getTimer;
	import org.flixel.*;
	import playerio.Message;
	
	/**
	 * ...
	 * @author 
	 * 
	 * Merges commands into one datastructure and executes them in the primary update loop
	 */
	
	//still need to have multiply for speeding up game state
	//still need server to fix synchronizing start times
	public class GameLogicState extends FlxState {
		//server time values - milliseconds
		protected var turnLength:int; //how long a turn, affected by ping
		private var minUpdateTime:int; //how often update is called when no commands, affects framerate
		
		//real time - milliseconds
		protected var currentRealTime:int; //so getTimer() is only called once
		protected var turnStartRealTime:int; //for timestamp of to send commands
		
		//game time - milliseconds
		private var turnStartGameTime:int; //to calculate FlxG.elapsedTime
		private var lastUpdateGameTime:int; //to calculate FlxG.elapsedTime
		private var lastStoredGameTime:int; //for creation of command list - in full game time
		private var turnEndGameTime:int; //for the minimum update checks of creation of command list only
		
		//command datastructures
		protected var amP1:Boolean;
		protected var myCommands:Array; //array of commands to be merged
		protected var enemyCommands:Array; //array of messages to be merged
		private var commandsToExecute:Array; //came in
		
		public function GameLogicState(pAmP1:Boolean, pTurnLength:int, pMinUpdateTime:int) {
			//change update function
			Avatar.inGame = true;
			
			//initialize game engine and networking related variables
			amP1 = pAmP1;
			turnLength = pTurnLength;
			minUpdateTime = pMinUpdateTime;
			turnStartRealTime = getTimer();
			commandsToExecute = new Array();
			myCommands = new Array();
			enemyCommands = new Array();
			commandsToExecute.push( { command:Command.Turn } ); //default turn
			commandsToExecute.push( { command:Command.Turn } ); //default turn
		}
		
		protected function mergeCommands():void {
			//confirm possible to merge
			if(enemyCommands.length <= 0 || myCommands.length <= 0)
				return;
			
			//declare variables
			var pos1:int; //to loop through message
			var pos2:int; //to loop through message
			var m1:Message;
			var m2:Message;
			var m1Length:int; //to reduce calls to length
			var m2Length:int; //to reduce calls to length
			var p1GameTime:int; //to reduce calls to getInt
			var p1LastTime:int; //to check out of order
			var p2GameTime:int; //to reduce calls to getInt
			var p2LastTime:int; //to check out of order
			
			//init variables
			if (amP1) {
				m1 = myCommands.shift();
				m2 = enemyCommands.shift();
			}else {
				m1 = enemyCommands.shift();
				m2 = myCommands.shift();
			}
			m1Length = m1.length;
			m2Length = m2.length;
			
			//merge
			while (pos1 < m1Length || pos2 < m2Length) {
                if (pos1 >= m1Length) {
					p2GameTime = m2.getInt(pos2);
					if (!isValid(p2LastTime, p2GameTime))
						return;
					pos2 = addCommand(m2, false, p2GameTime, pos2);
					p2LastTime = p2GameTime;
                }else if (pos2 >= m2Length) {
					p1GameTime = m1.getInt(pos1);
					if (!isValid(p1LastTime, p1GameTime))
						return;
					pos1 = addCommand(m1, true, p1GameTime, pos1);
					p1LastTime = p1GameTime;
                }else {
                    //add command of smaller timestamp
					p1GameTime = m1.getInt(pos1);
					p2GameTime = m2.getInt(pos2);
					
                    if (p1GameTime < p2GameTime) {
						if (!isValid(p1LastTime, p1GameTime))
							return;
						pos1 = addCommand(m1, true, p1GameTime, pos1);
						p1LastTime = p1GameTime;
                    }else {
						if (!isValid(p2LastTime, p2GameTime))
							return;
						pos2 = addCommand(m2, false, p2GameTime, pos2);
						p2LastTime = p2GameTime;
					}
                }
            }
			
			//update with received turn
			minUpdateCheck(turnEndGameTime + turnLength);
			turnEndGameTime += turnLength;
			commandsToExecute.push({ command:Command.Turn });
		}
		
		private function addCommand(m:Message, isP1:Boolean, timestamp:int, position:int):int {
			try {
				//command info
				var totalTimestamp:int = timestamp + turnEndGameTime;
				var command:int = m.getInt(position + 1);
				
				//process command
				switch(command) {
					case Command.W:
					case Command.A:
					case Command.S:
					case Command.D:
						minUpdateCheck(totalTimestamp);
					
						lastStoredGameTime = totalTimestamp;
						commandsToExecute.push( { command:command, player:isP1, gameTime:timestamp } );
						return position+2;
				}
			}catch (err:Error) {
			}
			
			FlxG.log("cannot process command, breaking out");
			//cannot process command, break out
			return m.length;
		}
		
		private function isValid(lastTime:int, currentTime:int):Boolean {
			//return true;
			if (currentTime < 0) {
				FlxG.log("received negative time, invalid, breaking out");
				return false;
			}
			if (lastTime > currentTime) {
				FlxG.log("received commands out of order, invalid, breaking out");
				return false;
			}
			if (currentTime > turnLength) {
				FlxG.log("received too large a time, invalid, breaking out");
				return false;
			}
			return true;
		}
		
		private function minUpdateCheck(newGameTime:int):void {
			//loop and add update commands
			while (lastStoredGameTime + minUpdateTime < newGameTime) {
				lastStoredGameTime += minUpdateTime;
				commandsToExecute.push( { command:Command.Update, gameTime:lastStoredGameTime - turnEndGameTime } );
			}
		}
		
		override public function update():void {
			currentRealTime = getTimer();
			updateEngine();
		}
		
		protected function updateEngine():void {
			//command check
			if (commandsToExecute.length <= 0) {
				//nothing in commands, just wait to receive packets
				FlxG.log("nothing in commands, waiting");
				return;
			}
			
			//turn check
			if(commandsToExecute[0].command == Command.Turn) {
				if(currentRealTime > turnStartRealTime + turnLength) {
					//ready to execute next turn
					executeNewTurn();
					commandsToExecute.shift();
					turnStartRealTime = currentRealTime;
					turnStartGameTime += turnLength;
				}else
					return;
			}
			
			//loop through commands
			var current:Object;
			while (commandsToExecute.length > 0 && commandsToExecute[0].command != Command.Turn && commandsToExecute[0].gameTime + turnStartRealTime <= currentRealTime) {
				//pop command off queue
				current = commandsToExecute.shift();
				
				//execute
				executeCommand(current);
				
				//update
				if (commandsToExecute.length <= 0 || commandsToExecute[0].gameTime != current.gameTime) {
					updateState(turnStartGameTime + current.gameTime);
				}
			}
			
			//render
			processAndRender();
		}
		
		protected function executeNewTurn():void {
			
		}
		
		protected function executeCommand(command:Object):void {
			
		}
		
		private function updateState(newGameTime:int):void {
			FlxG.elapsed = (newGameTime - lastUpdateGameTime) / 1000;
			lastUpdateGameTime = newGameTime;
			super.update();
		}
		
		private function processAndRender():void {
			super.preProcess();
			super.render();
		}
	}
}