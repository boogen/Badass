package badass.engine {
    import flash.display.BitmapData;
    import flash.geom.Point;

    public class Frame {
	private var _texture:BitmapData;

	public var uLeft:Number;
	public var vTop:Number;
	public var uRight:Number;
	public var vBottom:Number;
	private var _width:Number;
	private var _height:Number;
	public var index:int;
	public var offset:Point;
	public var textureWidth:Number;
	public var textureHeight:Number;

	public function Frame(texture:BitmapData) {
	    _texture = texture;
	    width = _texture.width;
	    height = _texture.height;

		textureWidth = Utils.powerOfTwo(_texture.width);
		textureHeight = Utils.powerOfTwo(_texture.height);
		
	    uLeft = 0.0;
		uRight = _texture.width / textureWidth;		
	    vTop = 0.0;
		vBottom = _texture.height / textureHeight;		
		
	    offset = new Point(0, 0);
	}

	public function get width():Number {
		return _width;	
	}
	
	public function set width(value:Number):void {
		_width = value;
		uRight = uLeft + _width / textureWidth;		
	}
	
	public function get height():Number {
		return _height;
	}
	
	public function set height(value:Number):void {
		_height = value;
		vBottom = uRight + _height / textureHeight;
	}

	public function get texture():BitmapData {
	    return _texture;
	}

    }
}