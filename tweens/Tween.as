package tweens {
	import events.Event;
	import engine.EventDispatcher;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class Tween extends EventDispatcher {
		
		private var _target:Object;
		private var _transition:String;
		
		private var _currentTime:Number;
		private var _totalTime:Number;
		private var _delay:Number;
		
		private var _onComplete:Function;
		
		private var _onCompleteArgs:Array;
		
		private var _properties:Vector.<String>;
		private var _startValues:Vector.<Number>;
		private var _endValues:Vector.<Number>;
		
		public function Tween(target:Object, time:Number, transition:String = "linear") {
			reset(target, time, transition);
		}
		
		public function reset(target:Object, time:Number, transition:String = "linear"):void {
			_target = target;
			_currentTime = 0;
			_totalTime = Math.max(0.0001, time);
			_delay = 0;
			_transition = transition;
			_onComplete = null;
			_onCompleteArgs = null;
			
			if (_properties) {
				_properties.length = 0;
			} else {
				_properties = new Vector.<String>();
			}
			
			if (_startValues) {
				_startValues.length = 0;
			} else {
				_startValues = new Vector.<Number>();
			}
			
			if (_endValues) {
				_endValues.length = 0;
			} else {
				_endValues = new Vector.<Number>();
			}
		}
		
		public function animate(property:String, targetValue:Number):void {
			if (_target == null) {
				return;
			}
			
			_properties.push(property);
			_startValues.push(Number.NaN);
			_endValues.push(targetValue);
		}
		
		public function advanceTime(time:Number):void {
			if (time == 0)
				return;
			
			var previousTime:Number = _currentTime;
			_currentTime += time;
			
			if (_currentTime < 0 || previousTime >= _totalTime)
				return;
			
			var ratio:Number = Math.min(_totalTime, _currentTime) / _totalTime;
			var numAnimatedProperties:int = _startValues.length;
			
			for (var i:int = 0; i < numAnimatedProperties; ++i) {
				if (isNaN(_startValues[i]))
					_startValues[i] = _target[_properties[i]] as Number;
				
				var startValue:Number = _startValues[i];
				var endValue:Number = _endValues[i];
				var delta:Number = endValue - startValue;
				
				//  var transitionFunc:Function = Transitions.getTransition(_transition);                
				//var currentValue:Number = startValue + transitionFunc(ratio) * delta;
				var currentValue:Number = startValue + ratio * delta;
				_target[_properties[i]] = currentValue;
			}
			
			if (previousTime < _totalTime && _currentTime >= _totalTime) {
				dispatchEvent(new Event(Event.TWEEN_END));
				if (_onComplete != null) {
					_onComplete.apply(null, _onCompleteArgs);
				}
			}
		}
		
		public function get target():Object {
			return _target;
		}
		
		public function set onComplete(value:Function):void {
			_onComplete = value;
		}
		
		public function get onComplete():Function {
			return _onComplete;
		}
		
		public function set onCompleteArgs(value:Array):void {
			_onCompleteArgs = value;
		}
		
		public function get onCompleteArgs():Array {
			return _onCompleteArgs;
		}		
	}

}