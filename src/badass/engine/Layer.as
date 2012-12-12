package badass.engine {
	import badass.textures.BadassTexture;
	import badass.types.BlendType;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	public class Layer extends DisplayObject {
		
		protected var _byteArray:ByteArray;
		private var _drawCalls:Array;
		
		private const _vertexSize:int = 8;
		private var _vertexCount:int = 2 * 20;
		private var _indexSize:int = 2 * 6 * 5;
		
		protected var _vertexBuffer:VertexBuffer3D;
		protected var _indexBuffer:IndexBuffer3D;
		
		private var _vertices:Vector.<Number>;
		private var _indices:Vector.<uint>;
		
		protected var _context3D:Context3D;
		protected var _renderer:Renderer;
		private var _lastAlpha:Number;
		
		private var _blendType:String;
		
		protected var _program:int;	
		
		private var _hitTest:Function;
		
		private var _compressed:Boolean = false;
		
		protected var _stateChanges:Array;
		
		public function Layer(blendType:String = BlendType.ALPHA, renderer:Renderer = null, compressed:Boolean = false) {
			super();
			_blendType = blendType;
			_byteArray = new ByteArray();
			_byteArray.endian = Endian.LITTLE_ENDIAN;
			_drawCalls = new Array();
			_stateChanges = new Array();
			_renderer = renderer;
			setStandardMode();
		}
		
		override public function hitTest(pX:Number, pY:Number, onlyHighlighted:Boolean = false):DisplayObject {		
			if (_hitTest != null) {
				return _hitTest(pX, pY, onlyHighlighted);
			}
			
			return super.hitTest(pX, pY, onlyHighlighted);
		}
		
		public function setHitTest(value:Function):void {		
			_hitTest = value;
		}
		
		public function setTutorialMode():void {
			_program = badass.engine.Renderer.COLOR;
		}
		
		public function setStandardMode():void {
			_program = badass.engine.Renderer.STANDARD;
		}	
		
		public function setLinearMode():void {		
			_program = badass.engine.Renderer.LINEAR;
		}
		
		protected function drawChildren():void {
			var i:int;
			for (i = _children.length - 1; i >= 0; --i) {
				_children[i].render(this);
			}		
		}
		
		public function turnOffMask():void {		
		}

		public function draw(renderer:Renderer):void {
			if (!visible) {
				return;
			}
			_context3D = _renderer.getContext3D();
			_renderer.changeState(_program, false, false);
			_renderer.setBlendType(_blendType);
			clearContainer();
			drawChildren();
			
			var count:int = 0;
			
			_byteArray.position = 0;
			fillByteArray();
			
			if (_byteArray.position > 0) {
				checkSize();
				_context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				_context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
				_context3D.setVertexBufferAt(2, _vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);
				
				_vertexBuffer.uploadFromByteArray(_byteArray, 0, 0, _byteArray.position / (4 * _vertexSize));
				
				renderDrawCalls();
				
			}
		}
		
		protected function clearContainer():void {
			for (var i:int = 0; i < _drawCalls.length; ++i) {
				for each (var batches:Vector.<DisplayObject> in _drawCalls[i]) {
					batches.length = 0;
				}
			}
			_stateChanges.length = 0;
		}
		
		protected function fillByteArray():void {
			var i:int;
			var batches:Vector.<DisplayObject>;
			var currentState:Boolean = false;
			var counter:int = 0;
			for (i = 0; i < _drawCalls.length; ++i) {
				for each (batches in _drawCalls[i]) {
					for (var j:int = 0; j < batches.length; ++j) {
						if (batches[j].alpha < 1 != currentState) {
							_stateChanges.push(counter);
							currentState = !currentState;
						}
						batches[j].writeToByteArray(_byteArray);
						counter++;
					}
				}
			}
		}
		
		protected function onSwitchProgram():void {
			_context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			_context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			_context3D.setVertexBufferAt(2, _vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);			
		}
		
		protected function checkProgram(texture:BadassTexture):void {
			if (texture.compressed) {
				if (_renderer.changeState(_program, true, _renderer.getAlphaState())) {
					onSwitchProgram();
				}
			}
			else if (!texture.compressed) {
				if (_renderer.changeState(_program, false, _renderer.getAlphaState())) {
					onSwitchProgram();
				}
			}
		}
		
		protected function renderDrawCalls():void {
			var count:int = 0;
			var i:int;
			var batches:Vector.<DisplayObject>;
			for (i = 0; i < _drawCalls.length; ++i) {
				for (var key:Object in _drawCalls[i]) {
					var texture:BadassTexture = key as BadassTexture;
					checkProgram(texture);
					
					batches = _drawCalls[i][texture];
					if (batches.length) {
						_renderer.setTexture(texture);
						
						var batchEnd:int = count + batches.length * 6;
						while (_stateChanges.length > 0 && _stateChanges[0] * 6 < batchEnd && _stateChanges[0] * 6 >= count) {
							var d:int = _stateChanges[0] * 6 - count;
							if (d > 0) {
								_context3D.drawTriangles(_indexBuffer, count, (_stateChanges[0] * 6 - count) / 3);
							}							
							count += d;
							_stateChanges.shift();
							_renderer.changeState(_program, _renderer.getCompressedState(), !_renderer.getAlphaState());
							onSwitchProgram();
						}
						if (count < batchEnd) {
							_context3D.drawTriangles(_indexBuffer, count, (batchEnd - count) / 3);
						}
						count = batchEnd;
					}
				}
			}
		}
		
		private function checkSize():void {
			if (!_vertexBuffer || !_indexBuffer) {
				createVertexBuffer();
				createIndexBuffer();
			}
			if (_byteArray.length / 4 >= _vertexSize * _vertexCount) {
				
				while (_byteArray.length / 4 >= _vertexSize * _vertexCount) {
					_vertexCount = 2 * _vertexCount;
					_indexSize = 2 * _indexSize;
				}
				createVertexBuffer();
				createIndexBuffer();
			}
		}
		
		private function createVertexBuffer():void {
			if (_vertexBuffer) {
				_vertexBuffer.dispose();
			}
			_vertexBuffer = _context3D.createVertexBuffer(_vertexCount, _vertexSize);
			var empty:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < _vertexCount * _vertexSize; ++i) {
				empty.push(0);
			}
			_vertexBuffer.uploadFromVector(empty, 0, empty.length / _vertexSize);
			_context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			_context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			_context3D.setVertexBufferAt(2, _vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_1);
		}
		
		private function createIndexBuffer():void {
			if (_indexBuffer) {
				_indexBuffer.dispose();
			}
			_indexBuffer = _context3D.createIndexBuffer(_indexSize);
			var indices:Vector.<uint> = new Vector.<uint>();
			var index:int = 0;
			for (var i:int = 0; i < _indexSize; i += 6) {
				indices.push(index, index + 3, index + 1, index + 3, index + 2, index + 1);
				index += 4;
			}
			_indexBuffer.uploadFromVector(indices, 0, indices.length);
		}
		
		public function addBatch(d:DisplayObject):void {
			var texture:BadassTexture = d.frame.texture;
			
			if (!_drawCalls[d.renderIndex]) {
				_drawCalls[d.renderIndex] = new Dictionary();
			}
			if (!_drawCalls[d.renderIndex][texture]) {
				_drawCalls[d.renderIndex][texture] = new Vector.<DisplayObject>();
			}
			
			_drawCalls[d.renderIndex][texture].push(d);
		
		}
	}
}