package engine {
	import flash.utils.Dictionary;
	import events.Event;
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class EventDispatcher {
		private var _observers:Dictionary;
		
		public function EventDispatcher() {			
		}
		
		public function dispatchEvent(event:Event):void {		
			if (_observers && _observers[event.type]) {
				var observers:Dictionary = _observers[event.type];
				
				event.currentTarget = this;
				if (!event.target) {
					event.target = this;
				}
				
				for (var k:Object in observers) {
					var key:Function = k as Function;
					key(event);
					if (event.stopsImmediatePropagation) {
						break;
					}
				}
				
				if (!event.stopsImmediatePropagation) {
					var displayObject:DisplayObject = this as DisplayObject;
					if (displayObject && displayObject.parent) {
						displayObject.parent.dispatchEvent(event);
					}
				}
			}
		}
		
		public function addEventListener(type:String, observer:Function):void {
			if (!_observers) {
				_observers = new Dictionary();
			}
			if (!_observers[type]) {
				_observers[type] = new Dictionary();
			}
			
			_observers[type][observer] = true;
		}
		
		public function removeEventListener(type:String, observer:Function):void {
			if (_observers && _observers[type]) {
				delete _observers[type][observer];
			}
		}
		
		public function removeEventListeners(type:String = null):void {
			if (_observers) {
				if (type && _observers[type]) {
					delete _observers[type];
				}
			}
			else if (type == null) {
				_observers = null;
			}			
		}
		
	}

}