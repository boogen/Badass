package badass.engine {
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class Quad extends Sprite{
		
		private static var _colors:Dictionary = new Dictionary();
		
		
		public function Quad(w:int, h:int, c:uint) {
			if (!_colors[c]) {
				_colors[c] = new BitmapData(1, 1, false, c);
			}
			
			var f:Frame = new Frame(_colors[c]);
			f.width = w;
			f.height = h;
			setTexture(f);
		}
	
	}

}