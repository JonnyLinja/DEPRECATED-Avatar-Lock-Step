package FlxStates {
	import Networking.Net;
	import org.flixel.*;
	import playerio.*;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	//import playerio.Message;

	public class TitleState extends FlxState {
		private var pokeStart:int;
		
		public override function create():void {	
			//Connect and join the room
			//PlayerIO.connect(stage,	gameID,	"public", "User" + Math.floor(Math.random() * 1000).toString(),	"",	handleConnect,	function():void { trace("connect error") }	);   //This connects us to our game server
			
			PlayerIO.connect(
				FlxG.stage,								//Referance to stage
				"",		//Game id (Get your own at playerio.com. 1: Create user, 2:Goto admin pannel, 3:Create game, 4: Copy game id inside the "")
				"public",							//Connection id, default is public
				"GuestUser",						//Username
				"",									//User auth. Can be left blank if authentication is disabled on connection
				handleConnect,						//Function executed on successful connect
				handleError							//Function executed if we recive an error
			);
		}
	
		public function handleConnect(client:Client) : void { // Called on successful connection
			client.multiplayer.developmentServer = "localhost:8184";
			FlxG.log("Connected to server")
			//client.multiplayer.createJoinRoom("test", "MyGame",	false, { },	{ },	handleJoin,	function(error:PlayerIOError):void { FlxG.log(error) }	); //Makes us join or create the room "test"
			client.multiplayer.createJoinRoom(
				"test",								//Room id. If set to null a random roomid is used
				"Avatar",							//The game type started on the server
				true,								//Should the room be visible in the lobby?
				{},									//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				{},									//User join data
				handleJoin,							//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
			Net.client = client;
		}

		//called when a user joins the room
		public function handleJoin(conn:Connection):void {
			FlxG.log("joined")
			Net.conn = conn;
			
			//message handlers
			Net.conn.addMessageHandler(Net.messagePing, function(m:Message):void { Net.conn.send("Ping"); } );
			Net.conn.addMessageHandler(Net.messageReceiveStart, handleStart);
			Net.conn.addMessageHandler(Net.messagePoke, handlePoke);
			
			//send
			pokeStart = getTimer();
			Net.conn.send(Net.messagePoke);
			Net.conn.send(Net.messageSendReady);
		}
		
		private function handleError(error:PlayerIOError):void {
			FlxG.log("ERROR TIME");
		}
		
		//should not be in title state, move it later
		private function handleStart(m:Message):void {
			FlxG.log("Start");
			
			//should have a faster check for isPlaying, but may not matter as shouldn't get start again
			if (flash.utils.getQualifiedClassName( FlxG.state ) == "FlxStates::TitleState")
				FlxG.state = new PlayState(m.getBoolean(0), m.getInt(1), m.getInt(2));
			else
				FlxG.log("Received Start, but is already playing");
		}
		
		private function handlePoke(m:Message):void {
			var currentTime:int = getTimer();
			FlxG.log("Ping is: " + (currentTime - pokeStart) + " ms");
			
			//maybe redo it
			if (flash.utils.getQualifiedClassName( FlxG.state ) == "FlxStates::TitleState") {
				pokeStart = currentTime;
				Net.conn.send(Net.messagePoke);
			}
		}
	}
}