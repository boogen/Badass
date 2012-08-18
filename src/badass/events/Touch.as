package badass.events {
	import badass.engine.DisplayObject;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class Touch {
		private var _id:int;
		private var _globalX:Number;
		private var _globalY:Number;
		private var _previousGlobalX:Number;
		private var _previousGlobalY:Number;
		private var _tapCount:int;
		private var _phase:String;
		private var _target:DisplayObject;
		private var _timestamp:Number;
		
		public function Touch(id:int, globalX:Number, globalY:Number, phase:String, target:DisplayObject) {
			_id = id;
			_globalX = globalX;
			_globalY = globalY;
			_tapCount = 0;
			_phase = phase;
			_target = target;
		}
		
		public function getLocation():Point {
			var point:Point = new Point(_globalX, _globalY);
			return point;
		}
		
		public function getHorizontalMovement():Number {
			return (_globalX - _previousGlobalX);
		}
		
		public function getVerticalMovement():Number {
			return (_globalY - _previousGlobalY);
		}
		
		public function getMovement():Point {
			var result:Point = new Point(_globalX - _previousGlobalY, _globalY - _previousGlobalY);
			return result;
		}
		
		public function toString():String {
			return "Id=" + _id.toString() + ", globalX=" + _globalX.toString() + ", globalY=" + _globalY.toString() + ", phase=" + _phase.toString();
		}
		
		public function clone():Touch {
			var clone:Touch = new Touch(_id, _globalX, _globalY, _phase, _target);
			clone._previousGlobalX = _previousGlobalX;
			clone._previousGlobalY = _previousGlobalY;
			clone._tapCount = _tapCount;
			clone._timestamp = _timestamp;
			
			return clone;
		}
		
		public function get id():int {
			return _id;
		}
		
		public function get globalX():Number {
			return _globalX;
		}
		
		public function get globalY():Number {
			return _globalY;
		}
		
		public function get previousGlobalX():Number {
			return _previousGlobalX;
		}
		
		public function get previousGlobalY():Number {
			return _previousGlobalY;
		}
		
		public function get tapCount():int {
			return _tapCount;
		}
		
		public function get phase():String {
			return _phase;
		}
		
		public function get target():DisplayObject {
			return _target;
		}
		
		public function get timestamp():Number {
			return _timestamp;
		}
		
		public function setPosition(xValue:Number, yValue:Number):void {
			_previousGlobalX = _globalX;
			_previousGlobalY = _globalY;
			_globalX = xValue;
			_globalY = yValue;
		}
		
		public function setPhase(value:String):void {
			_phase = value;
		}
		
		public function setTapCount(value:int):void {
			_tapCount = value;
		}
		
		public function setTarget(value:DisplayObject):void {
			_target = value;
		}
		
		public function setTimestamp(value:Number):void {
			_timestamp = value;
		}
	}

}