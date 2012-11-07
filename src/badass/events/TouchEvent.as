package badass.events {
	import badass.engine.DisplayObject;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class TouchEvent extends Event {
		public static const TOUCH:String = "touch";
		
		private var _touches:Vector.<Touch>;
		private var _timestamp:Number;
		
		public function TouchEvent(type:String, touches:Vector.<Touch>, bubbles:Boolean = true) {
			super(type, bubbles);
			
			reset(touches);
		}
		
		public function reset(touches:Vector.<Touch>):void {
			_touches = touches;
			_timestamp = 0;
			if (_touches) {
				for (var i:int = 0; i < _touches.length; ++i) {
					if (_touches[i].timestamp > _timestamp) {
						_timestamp = _touches[i].timestamp;
					}
				}
			}			
		}
		
		public function getTouch(target:DisplayObject):Touch {
			if (_touches) {
				for (var i:int = 0; i < _touches.length; ++i) {
					var touch:Touch = _touches[i];
					if (touch.target == target) {
						return _touches[i];
					}
				}
			}
			
			if (_touches && _touches.length) {
				return _touches[0];
			}
			
			return null;
		}
	
	}

}