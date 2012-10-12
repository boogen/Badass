package badass.engine {
	import badass.Mask;
	import flash.display3D.textures.Texture;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class DisplayListLayer extends Layer {
		
		private var _displayList:Array;
		private var _index:int;
		private var _maskEnds:Dictionary;
		
		public function DisplayListLayer(blendType:String, renderer:Renderer) {
			super(blendType, renderer)
			_displayList = new Array();
			_maskEnds = new Dictionary();
		}
		
		override public function draw(renderer:Renderer):void {
			super.draw(renderer);			
		}
		
		override protected function drawChildren():void {
			for (_index = 0; _index < _children.length; ++_index) {
				_children[_index].render(this);
			}
		}
		
		override public function turnOffMask():void {
			_maskEnds[_displayList.length] = true;
		}			
		
		override protected function clearContainer():void {		
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
				if (_maskEnds[i]) {
					_renderer.turnOffMask();
					_maskEnds[i] = false;
				}
				var d:DisplayObject = _displayList[i];
				var texture:Texture = d.frame.texture.nativeTexture;
				
				if (d is Mask) {					
					_renderer.setMask();
					_context3D.drawTriangles(_indexBuffer, count, 2);
					_renderer.endMask();
				}				
				else {
					_context3D.setTextureAt(0, texture);
					_context3D.drawTriangles(_indexBuffer, count, 2);
				}
				count += 6;					
			}			
		}
	}

}