package badass.engine {
	import badass.textures.BadassTexture;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Frame {
		private var _texture:BadassTexture;
		
		public var uLeft:Number;
		public var vTop:Number;
		public var uRight:Number;
		public var vBottom:Number;
		private var _width:Number;
		private var _height:Number;
		public var index:int;
		public var offset:Point;
		public var baseWidth:int;
		public var baseHeight:int;
		
		public function Frame(texture:BadassTexture) {
			_texture = texture;
			_width = texture.width;
			_height = texture.height;
			baseWidth = _width;
			baseHeight = _height;
			
			uLeft = 0.0;
			uRight = _texture.width / textureWidth;
			vTop = 0.0;
			vBottom = _texture.height / textureHeight;
			
			offset = new Point(0, 0);
		}
		
		public function setRegion(region:Rectangle):void {
			uLeft = region.left / textureWidth;
			uRight = region.right / textureWidth;
			vTop = region.top / textureHeight;
			vBottom = region.bottom / textureHeight;
			_width = region.width;
			_height = region.height;
			baseWidth = _width;
			baseHeight = _height;
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
			vBottom = vTop + _height / textureHeight;
		}
		
		public function get texture():BadassTexture {
			return _texture;
		}
		
		public function get textureWidth():Number {
			return _texture.textureWidth;
		}
		
		public function get textureHeight():Number {
			return _texture.textureHeight;
		}
		
		public function dispose():void {
			_texture.dispose();
		}
	
	}
}