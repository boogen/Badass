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
			m = new Vector.<Matrix>();
			for (var i:int = 0; i < 13; ++i) {
				m.push(new Matrix());
				m[m.length - 1].translate(200 + i * 30, 480);
			}
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
			
			for (i = 0; i < Math.min(1, _displayList.length); ++i) {
				_displayList[i].setFrame(framecount % _displayList[i].totalFrames);
				//_displayList[i].currentMatrix.copyFrom(m[i % m.length]);
				_displayList[i].draw(_context3D, _renderer, _renderer.getWorldMatrix());
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