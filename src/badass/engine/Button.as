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
		private var _scaleWhenDown:Number = 0.9;
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
			
			if (touch.phase == TouchPhase.BEGAN && !_isDown) {
				_frame = _downState;
				scale = _scaleWhenDown;
				
				x += (1 - _scaleWhenDown) / 2 * _frame.width;
				y += (1 - _scaleWhenDown) / 2 * _frame.height;
				_isDown = true;
			} else if (touch.phase == TouchPhase.ENDED && _isDown) {
				x -= (1 - _scaleWhenDown) / 2 * _frame.width;
				y -= (1 - _scaleWhenDown) / 2 * _frame.height;
				_frame = _upState;
				scale = 1;
				_isDown = false;
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