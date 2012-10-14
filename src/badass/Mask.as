package badass {
	import badass.engine.DisplayObject;
	import badass.engine.Frame;
	import badass.engine.Quad;
	import badass.engine.Sprite;
	import badass.textures.BadassTexture;
	import badass.textures.ColorManager;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class Mask extends Sprite {
		
		public function Mask(w:int, h:int, c:uint) {	
			var f:Frame = new Frame(ColorManager.getMask());
			f.width = w;
			f.height = h;
			setTexture(f);	
		}
		
	}

}