package badass.engine {
	import flash.display3D.textures.Texture;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class DisplayListLayer extends Layer {
		
		private var _displayList:Array;
		
		public function DisplayListLayer() {
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
			if (!_displayList[d.renderIndex]) {
				_displayList[d.renderIndex] = new Array();
			}
			
			_displayList[d.renderIndex].push(d);
		}
		
		override protected function fillByteArray():void {
			for each (var layer:Array in _displayList) {				
				for (var i:int = layer.length - 1; i >= 0; --i) {
					layer[i].writeToByteArray(_byteArray);
				}				
			}
		}
		
		override protected function renderDrawCalls():void {
			var count:int = 0;
			for each (var layer:Array in _displayList) {				
				for (var i:int = layer.length - 1; i >= 0; --i) {
					var texture:Texture = layer[i].frame.texture.nativeTexture;
					_context3D.setTextureAt(0, texture);
					_context3D.drawTriangles(_indexBuffer, count,  2);
					count += 6;					
				}
			}			
		}
	}

}