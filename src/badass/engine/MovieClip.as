package badass.engine {
	import flash.utils.ByteArray;
	
	public class MovieClip extends Sprite {
		private var _frames:Vector.<Frame>;
		private var _animationSpeed:int;
		private var _frameNr:int;
		private var _playing:Boolean;
		public var ready:Boolean;
		
		public function MovieClip() {
			super();
			_animationSpeed = 4;
		}
		
		public function setFrames(value:Vector.<Frame>):void {
			_frames = value;
			if (_frames && _frames.length) {
				_frame = _frames[0];
			}
		}
		
		public function play():void {
			_playing = true;
		}
		
		public function stop():void {
			_playing = false;
		}
		
		public function set animationSpeed(value:int):void {
			if (value > 0) {
				_animationSpeed = value;
			}
		}
		
		override public function writeToByteArray(ba:ByteArray):void {
			this.x -= _frame.offset.x;
			this.y -= _frame.offset.y;
			super.writeToByteArray(ba);
			this.x += _frame.offset.x;
			this.y += _frame.offset.y;			
		}
		
		override public function render(layer:badass.engine.Layer):void {
			if (visible && _frames && _frames.length) {
				var currentFrame:int = (_frameNr / _animationSpeed) % _frames.length;
				_frame = _frames[currentFrame];
				super.render(layer);
				if (_playing) {
					_frameNr++;
				}
			}
		}
	}
}