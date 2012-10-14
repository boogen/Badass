package badass.engine {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author krzyma
	 */
	public class XmlFontLoader extends FontLoader {
		
		public function XmlFontLoader(c:badass.engine.Context) {
			super(c);
		}
		
		override protected function onSpriteSheetLoaded(e:Event):void {
			var bitmapData:BitmapData = (e.target.content as Bitmap).bitmapData;
		
			texture = _context.renderer.createTexture(bitmapData, false);

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
				//trace(">>>", char.@id);
				addChar(c.@id, c.@x, c.@y, c.@width, c.@height, c.@xoffset, c.@yoffset, c.@xadvance, c.@page, c.@chnl);
			}
		}
	}
}
