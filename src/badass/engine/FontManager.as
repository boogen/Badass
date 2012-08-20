package badass.engine {
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class FontManager {
		private static var _fonts:Dictionary = new Dictionary();
		
		public static function getFont(name:String):FontLoader {
			if (_fonts[name]) {
				return _fonts[name];
			}
			
			var loader:FontLoader = new FontLoader();
			loader.load(name);
			_fonts[name] = loader;
			return loader;
		}
	
	}

}