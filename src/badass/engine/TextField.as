package badass.engine {
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import badass.events.Event;
	
	public class TextField extends DisplayObject {
		private var _text:String;
		private var _font:FontLoader;
		private var _letters:Vector.<Sprite>;
		private var _hAlign:String;
		
		private var _fontSize:int;
		private var _containerWidth:int;
		private var _containerHeight:int;
		
		public var breaks:Boolean = true;
		
		public function TextField(w:int, h:int, text:String, f:String = "verdanaSmall", fontSize:Number = 12, color:uint = 0xffffffff, bold:Boolean = false, xmlFont:Boolean = false) {
			_text = text;
			_fontSize = fontSize;
			_letters = new Vector.<Sprite>();
			_containerWidth = w;
			_containerHeight = h;
			super.color = color;
			var font:FontLoader;
			if (xmlFont) {
				font = FontManager.getXmlFont(f);
			} else {
				font = FontManager.getFont(f);
			}
			if (font.loaded) {
				_font = font;
				createLetters();
			} else {
				font.addEventListener(flash.events.Event.COMPLETE, onFontLoaded);
			}
		}
		
		override public function get index():int {
			return super.index;
		}
		
		override public function set index(value:int):void {
			super.index = value;
			if (_letters) {
				for (var i:int = 0; i < _letters.length; ++i) {
					_letters[i].index = value;
				}
			}
		}
		
		public function get offsetY():Number {
			var value:Number = 0;
			if (_letters && _letters.length) {
				var space:String = " ";
				var dash:String = "^";
				var minY:Number = Number.POSITIVE_INFINITY;
				for (var i:int = 0; i < _letters.length; ++i) {
					if (text.charAt(i) != space.charAt(0) && text.charAt(i) != dash.charAt(0)) {
						if (_letters[i].y < minY) {
							minY = _letters[i].y;
						}
					}
				}
				
				if (minY < Number.POSITIVE_INFINITY) {
					value = minY;
				}
			}
			
			return value;
		}
		
		public function get text():String {
			return _text;
		}
		
		public function get fontSize():int {
			return _fontSize;
		}
		
		public function set text(value:String):void {
			if (_text != value) {
				_text = value;
				if (_font) {
					createLetters();
				}
			}
						
		}
		
		override public function set color(value:uint):void {
			super.color = value;
			for (var i:int = 0; i < _children.length; ++i) {
				_children[i].color = value;
			}
		}
		
		private function createLetters():void {
			var i:int;
			for (i = 0; i < _letters.length; ++i) {
				removeChild(_letters[i]);
			}
			
			_letters.length = 0;
			
			var n:int = _text.length;
			var dx:Number = 0;
			var dy:Number = 0;
			
			var break_line:Boolean = false;
			var space:String = " ";
			
			var breaks:Vector.<int> = new Vector.<int>();
			var space_index:int = 0;
			var charid:int;
			var ch:CharDescr;			
			if (this.breaks) {
				for (i = 0; i < n; ++i) {
					charid = _text.charCodeAt(i);
					ch = _font.getChar(charid);
					
					if (ch) {
						
						dx += ch.xOff + ch.srcW + 1;
						
						if (_containerWidth && dx > _containerWidth) {
							breaks.push(space_index);
							dx = 0;
						}
						
						if (charid == space.charCodeAt(0)) {
							space_index = i;
						}
					}
				}
			}
			
			dx = 0;
			
			for (i = 0; i < n; ++i) {
				charid = _text.charCodeAt(i);
				ch = _font.getChar(charid);
				
				if (ch) {
					var u1:Number = ch.srcX / _font.scalew;
					var v1:Number = ch.srcY / _font.scaleh;
					
					var u2:Number = u1 + ch.srcW / _font.scalew;
					var v2:Number = v1 + ch.srcH / _font.scaleh;
					
					var a:Number = ch.xAdv;
					var w:Number = ch.srcW;
					
					var s:Sprite = new Sprite();
					var frame:Frame = new Frame(_font.texture);							
					s.color = color;
					frame.setRegion(new Rectangle(ch.srcX, ch.srcY, ch.srcW, ch.srcH));
					s.setTexture(frame);
					s.x = dx + ch.xOff;
					s.y = dy + ch.yOff;
					
					s.color = color;
					_letters.push(s);
					addChild(s);
					
					dx += ch.xOff + ch.srcW + 1;
					
					if (breaks.length && breaks[0] == i) {
						dx = 0;
						dy += _font.font_height;
						breaks.shift();
					}
				}
				
			}
		
		}
		
		public function set hAlign(value:String):void {
			_hAlign = value;
		}
		
		public function get hAlign():String {
			return _hAlign;
		}
		
		private function onFontLoaded(e:flash.events.Event):void {
			_font = e.target as FontLoader;
			createLetters();
			dispatchEvent(new badass.events.Event(badass.events.Event.LOADED));
		}
	
	}
}
