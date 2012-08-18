package engine {
    public class Utils {
	public static function rotate(p:Array, degrees:Number):Array {
	    var res:Array = [0, 0];
	    var rad:Number = degrees / 180.0 * Math.PI;
	    var c:Number = Math.cos(rad);
	    var s:Number = Math.sin(rad);

	    res[0] = c * p[0] - s * p[1];
	    res[1] = s * p[0] + c * p[1];
	    return res;
	}

	public static function powerOfTwo(value:uint):uint {
		value--;
		value |= value >> 1;
		value |= value >> 2;
		value |= value >> 4;
		value |= value >> 8;
		value |= value >> 16;
		value++;
		return value;
	}
    }
}