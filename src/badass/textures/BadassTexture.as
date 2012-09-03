package badass.textures {
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import badass.engine.Utils;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class BadassTexture {
		
		private var _nativeTexture:Texture;
		private var _width:int;
		private var _height:int;
		private var _textureWidth:Number;
		private var _textureHeight:Number;
		
		public function BadassTexture(context:Context3D, bitmapData:BitmapData) {
			_width = bitmapData.width;
			_height = bitmapData.height;
			
			_textureWidth = badass.engine.Utils.powerOfTwo(bitmapData.width);
			_textureHeight = badass.engine.Utils.powerOfTwo(bitmapData.height);
			_nativeTexture = context.createTexture(_textureWidth, _textureHeight, Context3DTextureFormat.BGRA, false);
			_nativeTexture.uploadFromBitmapData(bitmapData);
			bitmapData.dispose();
		
		}
		
		public function get nativeTexture():Texture {
			return _nativeTexture;
		}
		
		public function set nativeTexture(texture:Texture):void {
			_nativeTexture = texture;
		}
		
		public function get width():int {
			return _width;
		}
		
		public function get height():int {
			return _height;
		}
		
		public function get textureWidth():Number {
			return _textureWidth;
		}
		
		public function get textureHeight():Number {
			return _textureHeight;
		}
		
		public function dispose():void {
			_nativeTexture.dispose();
		}
	}

}