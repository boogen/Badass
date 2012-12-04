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
		private var _lastDisplayObject:DisplayObject;
		private var _masks:Vector.<int>;
		
		public function DisplayListLayer(blendType:String, renderer:Renderer) {
			super(blendType, renderer)
			_displayList = new Array();
			_maskEnds = new Dictionary();
			_masks = new Vector.<int>();
		}
		
		override public function draw(renderer:Renderer):void {
			super.draw(renderer);			
		}
		
		override protected function drawChildren():void {
			for (var i:int = 0; i < _children.length; ++i) {
				_children[i].render(this);
			}
		}
		
		override public function turnOffMask():void {
			_maskEnds[_index + 1] = true;
		}			
		
		override protected function clearContainer():void {		
			for (var i:int = 0; i < _displayList.length; ++i) {
				_displayList[i].length = 0;
			}
			_index = -1;
			_lastDisplayObject = null;
			_stateChanges.length = 0;
		}
		
		override public function addBatch(d:DisplayObject):void {		
			if (!_lastDisplayObject || _lastDisplayObject.frame.texture != d.frame.texture) {
				_index++;		
				if (_displayList.length <= _index) {
					_displayList.push(new Array());
				}				
			}

			
			_displayList[_index].push(d);
			_lastDisplayObject = d;
		}
		
		override protected function fillByteArray():void {
			var currentState:Boolean = false;
			var counter:int = 0;			
			for (var i:int = 0; i < _displayList.length; ++i) {
				for (var j:int = 0; j < _displayList[i].length; ++j) {
					if (_displayList[i][j].alpha < 1 != currentState) {
						_stateChanges.push(counter);
						currentState = !currentState;
					}					
					_displayList[i][j].writeToByteArray(_byteArray);
					counter++;
				}
			}
		}
		
	
		
		override protected function renderDrawCalls():void {
			var count:int = 0;
			for (var i:int = 0; i < _displayList.length; ++i) {
				if (_maskEnds[i]) {
					_maskEnds[i] = false;
					var index:int = _masks.pop();
					_renderer.endMask(_masks.length);
				}
				if (_displayList[i].length) {
					var d:DisplayObject = _displayList[i][0];
					var texture:Texture = d.frame.texture.nativeTexture;
					checkProgram(d.frame.texture);
					if (texture) {
						_context3D.setTextureAt(0, texture);
						
						if (d is Mask) {		
							_masks.push(count);					
							_renderer.setMask(_masks.length - 1);			
							_context3D.drawTriangles(_indexBuffer, count, 2);										
							_renderer.endMask(_masks.length);
							
							count += 6;					
						}				
						else {											
							var batchEnd:int = count + _displayList[i].length * 6;
							while (_stateChanges.length > 0 && _stateChanges[0] * 6 < batchEnd && _stateChanges[0] * 6 >= count) {
								var diff:int = _stateChanges[0] * 6 - count;
								if (diff > 0) {
									_context3D.drawTriangles(_indexBuffer, count, (_stateChanges[0] * 6 - count) / 3);
								}							
								count += diff;
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
			_renderer.turnOffMask();
			_masks.length = 0;			
		}
	}

}