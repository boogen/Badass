package badass.engine {
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author krzyma
	 */
	public class DistributedXmlFontLoader extends FontLoader {
		public function DistributedXmlFontLoader(c:badass.engine.Context) {
			super(c);
		}
		
		override public function load(fontname:String):void {
			_name = fontname;
			
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, onDescriptionLoaded);
			xmlLoader.load(new URLRequest(path + _name + ".xml"));
		}
		
		private function onDescriptionLoaded(e:Event):void {
			var xml:XML = new XML(e.target.data);
			xml.ignoreWhitespace = true;
			
			getCommon(xml);
			getChars(xml);
			
			loaded = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function getCommon(xml:XML):void {
			var local_fontheight:int = xml.common.@font_height;
			if (local_fontheight == 0) {
				local_fontheight = 32;
			}
			var local_base:int = 32;
			var local_scalew:int = xml.common.@scaleW;
			var local_scaleh:int = xml.common.@scaleH;
			var local_pages:int = xml.common.@pages;
			var local_packed:int = 1;
			
			setCommonInfo(local_fontheight, local_base, local_scalew, local_scaleh, local_pages, local_packed > 0);
		}
		
		private function getChars(xml:XML):void {
			for each (var c:XML in xml.chars.char) {
				addChar(c.@id, c.@x, c.@y, c.@width, c.@height, c.@xoffset, c.@yoffset, c.@xadvance, c.@page, c.@chnl);
			}
		}
	}
}
