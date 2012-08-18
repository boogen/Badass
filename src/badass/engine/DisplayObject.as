package badass.engine {
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class DisplayObject extends EventDispatcher {
		
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _alpha:Number;
		private var _parent:DisplayObject;
		protected var _children:Vector.<DisplayObject>;
		
		private var _visible:Boolean;
		private var _touchable:Boolean;
		
		public var rotation:Number;
		private var _color:uint;
		
		protected var _frame:Frame;		
		
		public function DisplayObject() {
			
			_x = 0.0;
			_y = 0.0;
			_z = 0.0;
			_scaleX = 1.0;
			_scaleY = 1.0;
			_alpha = 1.0;
			_parent = null;
			_visible = true;
			_touchable = true;
			_children = new Vector.<DisplayObject>();
			
			rotation = 0.0;
			color = 0xFFFFFF;
		}
		
		public function get frame():Frame {
			return _frame;
		}
		
		public function get globalX():Number {
			var value:Number = _x;
			if (_parent) {
				value += _parent.x;
			}
			return value;
		}
		
		public function get x():Number {
			return _x;
		}
		
		public function set x(value:Number):void {
			_x = value;
		}
		
		public function get globalY():Number {
			var value:Number = _y;
			if (_parent) {
				value += _parent.y;
			}
			return value;
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function set y(value:Number):void {
			_y = value;
		}
		
		public function get localX():Number {
			return _x;
		}
		
		public function get localY():Number {
			return _y;
		}
		
		public function get z():Number {
			return _z;
		}
		
		public function set z(value:Number):void {
			_z = value;
		}
		
		public function get scaleX():Number {
			var value:Number = _scaleX;
			if (_parent) {
				value *= _parent.scaleX;
			}
			
			return value;
		}
		
		public function set scaleX(value:Number):void {
			_scaleX = value;
		}
		
		public function get scaleY():Number {
			var value:Number = _scaleY;
			if (_parent) {
				value *= _parent.scaleY;
			}
			
			return value;
		}
		
		public function set scaleY(value:Number):void {
			_scaleY = value;
		}
		
		public function set scale(value:Number):void {
			_scaleX = value;
			_scaleY = value;
		}
		
		public function get color():uint {
			return _color;
		}
		
		public function set color(value:uint):void {
			_color = value;
		}
		
		public function get parent():DisplayObject {
			return _parent;
		}
		
		public function set parent(value:DisplayObject):void {
			_parent = value;
		}
		
		public function get width():Number {
			if (!_children.length) {
				return 0;
			}
			var minX:Number = Number.POSITIVE_INFINITY;
			var maxX:Number = Number.NEGATIVE_INFINITY;
			
			for (var i:int = 0; i < _children.length; ++i) {
				var cx:Number = _children[i].x;
				var cw:Number = _children[i].width;
				
				if (cx < minX) {
					minX = cx;
				}
				if (cx + cw > maxX) {
					maxX = cx + cw;
				}
			}
			
			return maxX - minX;
		}
		
		public function get height():Number {
			if (!_children.length) {
				return 0;
			}
			var minY:Number = Number.POSITIVE_INFINITY;
			var maxY:Number = Number.NEGATIVE_INFINITY;
			
			for (var i:int = 0; i < _children.length; ++i) {
				var cy:Number = _children[i].y;
				var ch:Number = _children[i].height;
				
				if (cy < minY) {
					minY = cy;
				}
				if (cy + ch > maxY) {
					maxY = cy + ch;
				}
			}
			
			return maxY - minY;
		}
		
		public function get alpha():Number {
			var value:Number = _alpha;
			if (_parent) {
				value *= _parent.alpha;
			}
			
			return value;
		}
		
		public function set alpha(value:Number):void {
			_alpha = value;
		}
		
		public function get visible():Boolean {
			return _visible;
		}
		
		public function set visible(value:Boolean):void {
			_visible = value;
		}
		
		public function get touchable():Boolean {
			return _touchable;
		}
		
		public function set touchable(value:Boolean):void {
			_touchable = value;
		}
				
		
		public function tick(dt:Number):void {
			for (var i:int = 0; i < _children.length; ++i) {
				_children[i].tick(dt);
			}
		}
		
		public function writeToByteArray(ba:ByteArray):void {
		}
		
		public function render(layer:Layer):void {
			if (visible) {
				for each (var child:DisplayObject in _children) {
					child.render(layer);
				}
			}
		}
		
		public function addChild(child:DisplayObject):void {
			addChildAt(child, _children.length);
		}
		
		public function addChildAt(child:DisplayObject, pos:int):void {
			for (var i:int = 0; i < _children.length; ++i) {
				if (child == _children[i]) {
					return;
				}
			}
			
			child.parent = this;
			if (pos >= _children.length) {
				_children.push(child);
			} else {
				_children.splice(pos, 0, [child]);
			}
		}
		
		public function removeChild(child:DisplayObject):void {
			child.parent = null;
			for (var i:int = 0; i < _children.length; ++i) {
				if (_children[i] == child) {
					_children.splice(i, 1);
					return;
				}
			}
		}
		
		public function get numChildren():int {
			return _children.length;
		}
		
		public function getChildAt(i:int):DisplayObject {
			return _children[i];
		}
		
		public function hitTest(pX:Number, pY:Number):DisplayObject {
			if (!visible || !touchable) {
				return null;
			}
			
			var result:DisplayObject;
			for (var i:int = _children.length - 1; i >= 0; --i) {
				result = _children[i].hitTest(pX, pY);
				if (result) {
					return result;
				}
			}
			
			var gX:Number = globalX;
			var gY:Number = globalY;
			
			if (pX >= gX && pX <= gX + width * scaleX &&
				pY >= gY && pY <= gY + height *scaleY) {
				return this;
			}
			
			return null;
		}
	
	}

}