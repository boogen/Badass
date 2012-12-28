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
		private var _defaultXScale:Number = 1;
		private var _defaultYScale:Number = 1;
		private var _enabled:Boolean = true;
		
		public function Button(up:Frame, text:String = null, down:Frame = null) {
			_frame = up;
			_upState = up;
			_downState = down;
			_isDown = false;
			
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function disablePress():void {
			removeEventListener(TouchEvent.TOUCH, onTouch);
			if (_isDown) {
				var obj:DisplayObject;
				_isDown = false;
				pivotX -= (_defaultXScale - _scaleWhenDown) / 2 * _frame.width;
				pivotY -= (_defaultYScale - _scaleWhenDown) / 2 * _frame.height;
				_frame = _upState;
				scaleX = _defaultXScale;
				scaleY = _defaultYScale;
				
				for each(obj in _children) {
					if(_scaleWhenDown/_defaultXScale < 0) {
						obj.scaleX = -obj.baseScaleX;
					}
					if(_scaleWhenDown/_defaultYScale < 0) {
						obj.scaleY = -obj.baseScaleY;
					}
				}				
			}
		}

		public function enablePress():void {
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
				
				_defaultXScale = baseScaleX;
				_defaultYScale = baseScaleY;
				
				scale = _scaleWhenDown;
				
				pivotX += (_defaultXScale - _scaleWhenDown) / 2 * _frame.width;
				pivotY += (_defaultYScale - _scaleWhenDown) / 2 * _frame.height;
				
				for each(obj in _children) {
					if(_scaleWhenDown/_defaultXScale < 0) {
						obj.scaleX = -obj.baseScaleX;
						obj.x = -obj.x;
					}
					if(_scaleWhenDown/_defaultYScale < 0) {
						obj.scaleY = -obj.baseScaleY;
						obj.y = -obj.y;
					}
				}
				
			} else if (touch.phase == TouchPhase.ENDED && _isDown) {
				_isDown = false;
				pivotX -= (_defaultXScale - _scaleWhenDown) / 2 * _frame.width;
				pivotY -= (_defaultYScale - _scaleWhenDown) / 2 * _frame.height;
				_frame = _upState;

				
				for each(obj in _children) {
					if(_scaleWhenDown/_defaultXScale < 0) {
						obj.scaleX = -obj.baseScaleX;
						obj.x = -obj.x;
					}
					if(_scaleWhenDown/_defaultYScale < 0) {
						obj.scaleY = -obj.baseScaleY;
						obj.y = -obj.y;
					}
				}
				
				scaleX = _defaultXScale;
				scaleY = _defaultYScale;				
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