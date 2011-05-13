package General 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class Utils
	{
		public static function toFixed(number:Number, factor:int):Number {
			return (Math.round(number * factor)/factor);
		}
		
		public static function toByteArray(value:int):ByteArray {
			var result:ByteArray = new ByteArray();
			result.writeByte(value);
			return result;
		}
		
		public function Utils() 
		{
			
		}
		
	}

}