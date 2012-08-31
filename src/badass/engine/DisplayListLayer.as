package badass.engine {
	import flash.display3D.textures.Texture;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class DisplayListLayer extends Layer {
		
		private var _displayList:Array;
		
		public function DisplayListLayer(blendType:String) {
			super(blendType)
			_displayList = new Array();
		}
		
		override public function draw(renderer:Renderer):void {
			super.draw(renderer);			
		}
		
		override protected function clearContainer():void 
		{
			_displayList.length = 0;
		}
		
		override public function addBatch(d:DisplayObject):void {
			_displayList.push(d);
		}
		
		override protected function fillByteArray():void {
			for (var i:int = 0; i < _displayList.length; ++i) {
				_displayList[i].writeToByteArray(_byteArray);
			}
		}
		
		override protected function renderDrawCalls():void {
			var count:int = 0;
			for (var i:int = 0; i < _displayList.length; ++i) {
				var texture:Texture = _displayList[i].frame.texture.nativeTexture;
				_context3D.setTextureAt(0, texture);
				_renderer.setColor(_displayList[i].color);
				_context3D.drawTriangles(_indexBuffer, count,  2);
				count += 6;					
			}			
		}
	}

}