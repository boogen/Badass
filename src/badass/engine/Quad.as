package badass.engine {
	import badass.textures.BadassTexture;
	import badass.textures.ColorManager;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class Quad extends Sprite {
		public function Quad(w:int, h:int, c:uint) {
			var texture:BadassTexture = ColorManager.getColor(c);
			var f:Frame = new Frame(texture);
			f.width = w;
			f.height = h;
			setTexture(f);	
		}
		
		
	
	}

}