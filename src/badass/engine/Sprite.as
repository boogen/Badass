package badass.engine {
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class Sprite extends DisplayObject {
		
		private var _pivotX:Number = 0;
		private var _pivotY:Number = 0;
		private var _clipTop:Number = 0;
		
		public function Sprite() {
		}
		
		public function setTexture(frame:Frame):void {
			_frame = frame;
		}
		
		public function set uLeft(value:Number):void {
			_frame.uLeft = value;
		}
		
		public function set uRight(value:Number):void {
			_frame.uRight = value;
		}
		
		public function set vTop(value:Number):void {
			_frame.vTop = value;
		}
		
		public function set vBottom(value:Number):void {
			_frame.vBottom = value;
		}
		
		public function set width(value:Number):void {
			_frame.width = value;
		}
		
		public function set height(value:Number):void {
			_frame.height = value;
		}
		
		override public function set clipTop(value:Number):void {
			_clipTop = value;
			_frame.vTop = value;
			_frame.height = (1 - value) * _frame.baseHeight;
		}
		
		override public function get clipTop():Number {
			return _clipTop;
		}
		
		override public function get width():Number {
			if (_frame) {
				return _frame.width;
			} else {
				return super.width;
			}
			
			return 0;
		}
		
		override public function get height():Number {
			if (_frame) {
				return _frame.height;
			} else {
				return super.height;
			}
			
			return 0;
		}
		
		public function get textureWidth():Number {
			return _frame.textureWidth;
		}
		
		public function get textureHeight():Number {
			return _frame.textureHeight;
		}
		
		override protected function collision(pX:Number, pY:Number):Boolean {
			var gX:Number = globalX;
			var gY:Number = globalY;
			
			if (pX >= gX && pX <= gX + width * scaleX && pY >= gY && pY <= gY + height * scaleY) {
				return true;
			}
			
			return false;
		}
		
		override public function writeToByteArray(ba:ByteArray):void {
			if (_frame && visible) {
				var w:Number = width * scaleX;
				var h:Number = height * scaleY;
				
				var gx:Number = globalX + _pivotX;
				var gy:Number = globalY + _pivotY;
				
				var s:Number;
				var c:Number;
				if (rotation != 0) {
					s = Math.sin(rotation);
					c = Math.cos(rotation);
				} else {
					s = 0;
					c = 1;
				}
				
				var u:Number = s * h * 0.5 - c * w * 0.5;
				var v:Number = s * w * 0.5 + c * h * 0.5;
				var p:Number = s * -h * 0.5 - c * w * 0.5;
				var q:Number = s * w * 0.5 - c * h * 0.5;
				
				var a:Number = alpha;
				
				ba.writeFloat(gx + p + w / 2);
				ba.writeFloat(gy + q + h / 2);
				ba.writeFloat(_frame.uLeft);
				ba.writeFloat(_frame.vTop + _clipTop);
				ba.writeFloat(a);
				
				ba.writeFloat(gx - u + w / 2);
				ba.writeFloat(gy - v + h / 2);
				ba.writeFloat(_frame.uRight);
				ba.writeFloat(_frame.vTop);
				ba.writeFloat(a);
				
				ba.writeFloat(gx - p + w / 2);
				ba.writeFloat(gy - q + h / 2);
				ba.writeFloat(_frame.uRight);
				ba.writeFloat(_frame.vBottom);
				ba.writeFloat(a);
				
				ba.writeFloat(gx + u + w / 2);
				ba.writeFloat(gy + v + h / 2);
				ba.writeFloat(_frame.uLeft);
				ba.writeFloat(_frame.vBottom);
				ba.writeFloat(a);
				
			}
		}
		
		public function set pivotX(value:Number):void {
			_pivotX = value
		}
		
		public function get pivotX():Number {
			return _pivotX;
		}
		
		public function set pivotY(value:Number):void {
			_pivotY = value;
		}
		
		public function get pivotY():Number {
			return _pivotY;
		}
		
		override public function render(layer:badass.engine.Layer):void {
			if (visible) {
				if (_frame) {
					layer.addBatch(this);
				}
				super.render(layer);
			}
		}
	
	}
}