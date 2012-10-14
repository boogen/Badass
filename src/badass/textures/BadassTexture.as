package badass.textures {
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import badass.engine.Utils;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
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
		
		public static var size:Number = 1.0;
		public static var memory:int;
		private static var _matrices:Dictionary = new Dictionary();
		
		public function BadassTexture(context:Context3D, bd:BitmapData) {
			var bitmapData:BitmapData;
			var xScale:Number = size;
			var yScale:Number = size;	
			
			if (size != 1.0) {
				bitmapData = new BitmapData(Math.max(Math.floor(bd.width * size), 1), Math.max(Math.floor(bd.height * size), 1), true, 0);

				if (bd.width == bitmapData.width) {
					xScale = 1;
				}
				if (bd.height == bitmapData.height) {
					yScale = 1;
				}
				if (!_matrices[xScale]) {
					_matrices[xScale] = new Dictionary();
				}
				if (!_matrices[xScale][yScale]) {
					_matrices[xScale][yScale] = new Matrix(xScale, 0, 0, yScale);
				}
				bitmapData.draw(bd, _matrices[xScale][yScale]);
				bd.dispose();
			}
			else {
				bitmapData = bd;
			}
			
			_width = bitmapData.width;
			_height = bitmapData.height;
			
			_textureWidth = badass.engine.Utils.powerOfTwo(bitmapData.width);
			_textureHeight = badass.engine.Utils.powerOfTwo(bitmapData.height);
			_nativeTexture = context.createTexture(_textureWidth, _textureHeight, Context3DTextureFormat.BGRA, false);
			_nativeTexture.uploadFromBitmapData(bitmapData);
			bitmapData.dispose();
			memory += _textureWidth * _textureHeight * 4;
			_textureWidth /= xScale;
			_textureHeight /= yScale;
			_width /= xScale;
			_height /= yScale;
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
			memory -= _textureWidth * _textureHeight * 4 * size * size;
		}
	}

}
