package badass.events {
	import badass.engine.EventDispatcher;
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class Event {        
        public static const ADDED:String = "ADDED";        
        public static const ADDED_TO_STAGE:String = "ADDED_TO_STAGE";        
        public static const ENTER_FRAME:String = "ENTER_FRAME";        
        public static const REMOVED:String = "REMOVED";
        public static const REMOVED_FROM_STAGE:String = "REMOVED_FROM_STAGE";
        public static const COMPLETE:String = "COMPLETE";
		public static const TWEEN_END:String = "TWEEN_END";
		public static const RESIZE:String = "RESIZE";
		public static const LOADED:String = "LOADED";
		
		
		public var type:String;
		public var target:EventDispatcher;
		public var currentTarget:EventDispatcher;
		public var stopsImmediatePropagation:Boolean;
		public var bubbles:Boolean;
		
		public function Event(t:String, bubbles:Boolean = false) {
			type = t;
			this.bubbles = bubbles;
		}
		
        public function stopImmediatePropagation():void {
            stopsImmediatePropagation = true;
        }		
		
	}

}