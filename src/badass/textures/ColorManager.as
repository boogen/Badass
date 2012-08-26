package badass.textures {
	import badass.engine.Context;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class ColorManager {
		private static var _colors:Dictionary = new Dictionary();
		private static var _context:badass.engine.Context;
		
		public static function init(context:badass.engine.Context):void {
			_context = context;
		}		
		
		public static function getColor(value:uint):BadassTexture {
			if (!_colors[value]) {
				var bd:BitmapData = new BitmapData(1, 1, false, value);
				var texture:BadassTexture = _context.renderer.createTexture(bd);
				_colors[value] = texture;				
			}
			
			return _colors[value];
		}
	}

}