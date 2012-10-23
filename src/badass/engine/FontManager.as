package badass.engine {
	import flash.utils.Dictionary;
	import badass.engine.Context;
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class FontManager {
		public static const TXT_FORMAT:String = "TXT_FORMAT";
		public static const XML_FORMAT:String = "XML_FORMAT";
		public static const DIST_XML_FORMAT:String = "DIST_XML_FORMAT";
		
		private static var _fonts:Dictionary = new Dictionary();
		private static var _context:badass.engine.Context;
		
		public static function init(context:badass.engine.Context):void {
			_context = context;
		}
		
		public static function getFont(name:String, format:String):FontLoader {
			if (_fonts[name]) {
				return _fonts[name];
			}
			var loader:FontLoader;
			switch (format) {
				case TXT_FORMAT:
					loader = new FontLoader(_context);
					break;
				case XML_FORMAT:
					loader = new XmlFontLoader(_context);
					break;
				case DIST_XML_FORMAT:
					loader = new DistributedXmlFontLoader(_context);
					break;
			}
			loader.load(name);
			_fonts[name] = loader;
			return loader;
		}
	}
}
