package badass.events {
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class ResizeEvent extends Event {
		private var _width:int;
		private var _height:int;
		
		public function ResizeEvent(type:String, w:int, h:Number, bubbles:Boolean = false) {
			super(type, bubbles);
			_width = w;
			_height = h;
		}
		
		public function get width():int {
			return _width;
		}
		
		public function get height():int {
			return _height;
		}
	
	}

}