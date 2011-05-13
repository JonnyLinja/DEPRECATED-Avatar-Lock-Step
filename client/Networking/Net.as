package Networking {
	import playerio.Client;
	import playerio.Connection;

	/**
	 * ...
	 * @author 
	 */
	public class Net {
		//connection variables
		public static var conn:Connection;
		public static var client:Client;

		//receive message constants
		public static const messageReceiveStart:String = "Start";
		
		//send message constants
		public static const messageSendReady:String = "Ready";
		
		//two way message constants
		public static const messageCommands:String = "C";
		public static const messagePing:String = "Ping";
		public static const messagePoke:String = "Poke";
		
		public function Net() {}
	}
}