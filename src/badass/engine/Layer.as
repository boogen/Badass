package badass.engine {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	public class Layer extends DisplayObject {
		
		protected var _byteArray:ByteArray;
		private var _drawCalls:Array;
		
		private const _vertexSize:int = 5;
		private var _vertexCount:int = 2 * 20;
		private var _indexSize:int = 2 * 6 * 5;
		
		protected var _vertexBuffer:VertexBuffer3D;
		protected var _indexBuffer:IndexBuffer3D;
		
		private var _vertices:Vector.<Number>;
		private var _indices:Vector.<uint>;
		
		protected var _context3D:Context3D;
		private var _renderer:Renderer;
		private var _lastAlpha:Number;
		
		public function Layer() {
			super();
			_byteArray = new ByteArray();
			_byteArray.endian = Endian.LITTLE_ENDIAN;
		}
		
		public function draw(renderer:Renderer):void {
			if (!visible) {
				return;
			}
			_context3D = renderer.getContext3D();
			_renderer = renderer;
			clearContainer();
			var i:int;
			for (i = _children.length - 1; i >= 0; --i) {
				_children[i].render(this);
			}
			
			var count:int = 0;
			
			_byteArray.position = 0;
			fillByteArray();
			
			if (_byteArray.position > 0) {
				checkSize();
				_context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				_context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
				_context3D.setVertexBufferAt(2, _vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_1);
				
				_vertexBuffer.uploadFromByteArray(_byteArray, 0, 0, _byteArray.position / (4 * _vertexSize));
				
				renderDrawCalls();
				
			}
		}
		
		protected function clearContainer():void {
			_drawCalls = new Array();
		}
		
		protected function fillByteArray():void {
			var i:int;
			var batches:Vector.<DisplayObject>;
			for (i = 0; i < _drawCalls.length; ++i) {
				for each (batches in _drawCalls[i]) {
					for (var j:int = 0; j < batches.length; ++j) {
						batches[j].writeToByteArray(_byteArray);
					}
				}
			}
		}
		
		protected function renderDrawCalls():void {
			var count:int = 0;
			var i:int;
			var batches:Vector.<DisplayObject>;
			for (i = 0; i < _drawCalls.length; ++i) {
				for (var key:Object in _drawCalls[i]) {
					var texture:Texture = key as Texture;
					batches = _drawCalls[i][texture];
					_context3D.setTextureAt(0, texture);
					_context3D.drawTriangles(_indexBuffer, count, batches.length * 2);
					count += batches.length * 6;
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
			var texture:Texture = d.frame.texture.nativeTexture;
			
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