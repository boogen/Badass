package badass.tweens {
	///////////////////////////////
	/** from Starling Framework **/
	//////////////////////////////
	
	import badass.events.Event;
	
	public class Tweener {
		private var _objects:Vector.<Tween>;
		private var _elapsedTime:Number;
		
		public function Tweener() {
			_objects = new Vector.<Tween>();
			_elapsedTime = 0;
		}
		
		public function add(object:Tween):void {
			if (object != null) {
				_objects.push(object);
			}
			
			object.addEventListener(Event.TWEEN_END, onRemove);
		
		}
		
		public function remove(object:Tween):void {
			if (object == null) {
				return;
			}
			
			object.removeEventListener(Event.TWEEN_END, onRemove);
			
			var index:int = _objects.indexOf(object);
			if (index >= 0) {
				_objects.splice(index, 1);
			}
		}
		
		public function removeTweens(target:Object):void {
			if (target == null) {
				return;
			}
			
			var count:int = _objects.length;
			
			for (var i:int = count - 1; i >= 0; --i) {
				var tween:Tween = _objects[i];
				if (tween && tween.target == target) {
					_objects.splice(i, 1);
				}
			}
		}
		
		public function purge():void {
			_objects.length = 0;
		}
		
		public function advanceTime(time:Number):void {
			_elapsedTime += time;
			if (_objects.length == 0) {
				return;
			}
			
			// since 'advanceTime' could modify the juggler (through a callback), we iterate
			// over a copy of 'mObjects'.			
			var numObjects:int = _objects.length;
			var objectsCopy:Vector.<Tween> = _objects.concat();
			
			for (var i:int = 0; i < numObjects; ++i) {
				objectsCopy[i].advanceTime(time);
			}
		}
		
		private function onRemove(event:Event):void {
			remove(event.target as Tween);
		}
		
		public function get elapsedTime():Number {
			return _elapsedTime;
		}
	}
}