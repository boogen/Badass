package badass.engine {
	import badass.types.BlendType;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class GPUMovieClipLayer extends Layer {
		
		private var _displayList:Vector.<GPUMovieClip>
		private var m:Vector.<Matrix>;
		
		public function GPUMovieClipLayer() {
			super();
			_displayList = new Vector.<GPUMovieClip>();

		}
		
		override protected function clearContainer():void {
			_displayList.length = 0;
		}
				
		
		override public function draw(renderer:Renderer):void {
			if (!visible) {
				return;
			}
			renderer.setGPUMovieClipProgram();
			renderer.setBlendType(BlendType.ONE_MINUS_SOURCE_ALPHA);
			
			_context3D = renderer.getContext3D();
			_renderer = renderer;
			clearContainer();
			var i:int;
			for (i = _children.length - 1; i >= 0; --i) {
				_children[i].render(this);
			}
			
			for (i = 0; i < _displayList.length; ++i) {
				_displayList[i].setFrame(framecount / 2);
				_displayList[i].draw(_context3D, _displayList[i].globalX, _displayList[i].globalY, _displayList[i].scaleX, _displayList[i].scaleY);
			}
			
			renderer.setStandardProgram();
			framecount++;
		}
		
		private var framecount:int = 0;
		
		override public function addBatch(d:DisplayObject):void {
			if (d is GPUMovieClip) {
				_displayList.push(d as GPUMovieClip);
			}
		}
	
	}

}