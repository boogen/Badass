package engine {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	
    public class Layer extends DisplayObject {

	private var _byteArray:ByteArray;
	private var _drawCalls:Dictionary;
	
	private const _vertexSize:int = 5;
	private var _vertexCount:int = 20;
	private var _indexSize:int = 6 * 5;	
	
	private var _vertexBuffer:VertexBuffer3D;
	private var _indexBuffer:IndexBuffer3D;

	private var _vertices:Vector.<Number>;
	private var _indices:Vector.<uint>;
	
	private var _context3D:Context3D;
	private var _renderer:Renderer;
	private var _lastAlpha:Number;

	public function Layer() {
	    super();
	    _byteArray = new ByteArray();
		_byteArray.endian = Endian.LITTLE_ENDIAN;
	}

	public function draw(renderer:Renderer):void {
		_context3D = renderer.getContext3D();
		_renderer = renderer;
		_drawCalls = new Dictionary();
		for each (var child:DisplayObject in _children) {
			child.render(this);
		}
		
		var count:int = 0;		
		_byteArray.position = 0;
		var batches:Vector.<DisplayObject>;
		for each (batches in _drawCalls) {					
			for (var i:int = 0; i < batches.length; ++i) {
				batches[i].writeToByteArray(_byteArray);						
			}
		}
		
	   if (_byteArray.position > 0) {
		checkSize();
		_vertexBuffer.uploadFromByteArray(_byteArray, 0, 0, _byteArray.position / (4 * _vertexSize));

		 for (var key:Object in _drawCalls) {
			var texture:Texture = key as Texture;
			batches = _drawCalls[texture];
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
		var texture:Texture = _renderer.getTexture(d.frame);

		if (!_drawCalls[texture]) {
		   _drawCalls[texture] = new Vector.<DisplayObject>();
		}

		_drawCalls[texture].push(d);
	}    
	}
}