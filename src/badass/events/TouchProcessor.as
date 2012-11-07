package badass.events {
	import badass.engine.DisplayObject;
	import badass.engine.Layer;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class TouchProcessor {
		private static const MULTITAP_TIME:Number = 0.3;
		private static const MULTITAP_DISTANCE:Number = 25;
		
		private var _offsetTime:Number;
		private var _elapsedTime:Number;
		
		private var _queue:Vector.<Array>;
		private var _lastTaps:Vector.<Touch>;
		private var _currentTouches:Vector.<Touch>;
		private var _helperVector:Vector.<Touch>;
		private var _tutorialMode:Boolean = false;
		private var _touchEvent:TouchEvent;
		private var _touchPool:Vector.<Touch>;
		
		private static var _processedTouchIds:Vector.<int> = new Vector.<int>();
		
		private var _layers:Vector.<Layer>;
		
		public function TouchProcessor(layers:Vector.<badass.engine.Layer>) {
			_layers = layers;
			_queue = new Vector.<Array>();
			_lastTaps = new Vector.<Touch>();
			_currentTouches = new Vector.<Touch>();
			_helperVector = new Vector.<Touch>();
			_touchEvent = new TouchEvent(TouchEvent.TOUCH, new Vector.<Touch>());
			_touchPool = new Vector.<Touch>();
		}
		
		public function set tutorialMode(value:Boolean):void {
			_tutorialMode = value;
		}
		
		public function tick(dt:Number):void {
			var i:int;
			var touchId:int;
			var touch:Touch;
			
			_elapsedTime += dt;
			_offsetTime = 0;
			
			for (i = _lastTaps.length - 1; i >= 0; --i) {
				if (_elapsedTime - _lastTaps[i].timestamp > MULTITAP_TIME) {
					_lastTaps[i].free = true;
					_lastTaps.splice(i, 1);
				}
			}
			
			while (_queue.length > 0) {
				_processedTouchIds.length = 0;
				
				for each (touch in _currentTouches) {
					if (touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED) {
						touch.setPhase(TouchPhase.STATIONARY);
					}
					
					if (touch.target == null) {
						findTarget(touch);
					}
				}
				
				while (_queue.length > 0 && _processedTouchIds.indexOf(_queue[_queue.length - 1][0] == -1)) {
					var touchArgs:Array = _queue.shift();
					processTouch.apply(this, touchArgs);
					_processedTouchIds.push(touchId);
					
				}
				
				for each (touchId in _processedTouchIds) {
					touch = getCurrentTouch(touchId);
					if (touch.target) {
						_touchEvent.reset(_currentTouches);
						touch.target.dispatchEvent(_touchEvent);
					}
				}
				
				_helperVector.length = 0;
				for (i = _currentTouches.length - 1; i >= 0; --i) {
					if (_currentTouches[i].phase == TouchPhase.ENDED) {
						_currentTouches[i].free = true;
						_currentTouches.splice(i, 1);
					}
				}
				
				_offsetTime += 0.00001;
				
			}
		}
		
		private function getTouch():Touch {
			var result:Touch;
			for (var i:int = 0; i < _touchPool.length; ++i) {
				if (_touchPool[i].free) {
					result = _touchPool[i];
					break;
				}
			}
			
			if (!result) {
				result = new Touch();
				_touchPool.push(result);				
			}
			
			result.free = false;
			return result;
		}
		
		private function processTouch(touchId:int, phase:String, globalX:Number, globalY:Number):void {
			var touch:Touch = getCurrentTouch(touchId);
			
			if (touch == null) {
				touch = getTouch();
				touch.reset(touchId, globalX, globalY, phase, null);
				addCurrentTouch(touch);
			}
			
			touch.setPosition(globalX, globalY);
			touch.setPhase(phase);
			touch.setTimestamp(_elapsedTime + _offsetTime);
			
			if (phase == TouchPhase.HOVER || phase == TouchPhase.BEGAN) {
				findTarget(touch);
			}
			
			if (phase == TouchPhase.BEGAN) {
				processTap(touch);
			}
		}
		
		private function processTap(touch:Touch):void {
			var nearbyTap:Touch = null;
			var minSqDist:Number = MULTITAP_DISTANCE * MULTITAP_DISTANCE;
			
			for each (var tap:Touch in _lastTaps) {
				var sqDist:Number = Math.pow(tap.globalX - touch.globalX, 2) + Math.pow(tap.globalY - touch.globalY, 2);
				if (sqDist <= minSqDist) {
					nearbyTap = tap;
					break;
				}
			}
			
			if (nearbyTap) {
				touch.setTapCount(nearbyTap.tapCount + 1);
				var index:int = _lastTaps.indexOf(nearbyTap)
				_lastTaps[index].free = true;
				_lastTaps.splice(index, 1);
			} else {
				touch.setTapCount(1);
			}
			

		}
		
		private function addCurrentTouch(touch:Touch):void {
			for (var i:int = _currentTouches.length - 1; i >= 0; --i) {
				if (_currentTouches[i].id == touch.id) {
					_currentTouches[i].free = true;
					_currentTouches.splice(i, 1);
				}
			}
			
			_currentTouches.push(touch);
		}
		
		private function findTarget(touch:Touch):void {
			var result:DisplayObject
			for (var i:int = _layers.length - 1; i >= 0; --i) {
				result = _layers[i].hitTest(touch.globalX, touch.globalY, _tutorialMode);
				if (result) {
					touch.setTarget(result);
					return;
				}
			}
		}
		
		public function enqueue(touchId:int, phase:String, globalX:Number, globalY:Number):void {
			_queue.push(arguments);
		}
		
		private function getCurrentTouch(touchId:int):Touch {
			for each (var touch:Touch in _currentTouches) {
				if (touch.id == touchId) {
					return touch;
				}
			}
			
			return null;
		}
	
	}

}