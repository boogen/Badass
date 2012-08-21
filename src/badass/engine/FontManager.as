package badass.engine {
	import flash.utils.Dictionary;
	import badass.engine.Context;
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class FontManager {
		private static var _fonts:Dictionary = new Dictionary();
		private static var _context:badass.engine.Context;
		
		public static function init(context:badass.engine.Context):void {
			_context = context;
		}
		
		public static function getFont(name:String):FontLoader {
			if (_fonts[name]) {
				return _fonts[name];
			}
			
			var loader:FontLoader = new FontLoader(_context);
			loader.load(name);
			_fonts[name] = loader;
			return loader;
		}
	
	}

}