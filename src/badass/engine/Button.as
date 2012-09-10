package badass.engine {
	import badass.events.Touch;
	import badass.events.TouchEvent;
	import badass.events.TouchPhase;
	import flash.display.BitmapData;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class Button extends Sprite {
		private var _upState:Frame;
		private var _downState:Frame;
		public var fontSize:int;
		private var _isDown:Boolean;
		private var _scaleWhenDown:Number = -1;
		private var _enabled:Boolean = true;
		
		public function Button(up:Frame, text:String = null, down:Frame = null) {
			_frame = up;
			_upState = up;
			_downState = down;
			_isDown = false;
			
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function set enabled(value:Boolean):void {
			_enabled = value;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set scaleWhenDown(value:Number):void {
			_scaleWhenDown = value;
		}
		
		public function get scaleWhenDown():Number {
			return _scaleWhenDown;
		}
		
		private function onTouch(e:TouchEvent):void {
			if (!_downState || !_enabled) {
				return;
			}
			var touch:Touch = e.getTouch(this);
			if (touch == null) {
				return;
			}
			
			var obj:DisplayObject;
			if (touch.phase == TouchPhase.BEGAN && !_isDown) {
				_isDown = true;
				_frame = _downState;
				scale = _scaleWhenDown;
				
				pivotX += (1 - _scaleWhenDown) / 2 * _frame.width;
				pivotY += (1 - _scaleWhenDown) / 2 * _frame.height;
				
				for each(obj in _children) {
					obj.scaleX = -obj.baseScaleX;
					obj.scaleY = -obj.baseScaleY;
				}
				
			} else if (touch.phase == TouchPhase.ENDED && _isDown) {
				_isDown = false;
				pivotX -= (1 - _scaleWhenDown) / 2 * _frame.width;
				pivotY -= (1 - _scaleWhenDown) / 2 * _frame.height;
				_frame = _upState;
				scale = 1;
				
				for each(obj in _children) {
					obj.scaleX = -obj.baseScaleX;
					obj.scaleY = -obj.baseScaleY;
				}
			}
		}
		
		public function get upState():Frame {
			return _upState;
		}
		
		public function set upState(value:Frame):void {
			_upState = value;
			_frame = value;
		}
		
		public function get downState():Frame {
			return _downState
		}
		
		public function set downState(value:Frame):void {
			_downState = value;
		}
	
	}

}