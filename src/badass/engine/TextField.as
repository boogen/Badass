package badass.engine {
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import badass.events.Event;
	
	public class TextField extends DisplayObject {
		private var _text:String;
		private var _font:FontLoader;
		private var _letters:Vector.<Vector.<Sprite>>;
		private var _hAlign:String = HAlign.CENTER;
		private var _vAlign:String = VAlign.TOP;
		
		private var _fontStyle:String;
		private var _fontSize:int;
		private var _containerWidth:int;
		private var _containerHeight:int;
		private var _baseX:Number = 0;
		private var _baseY:Number = 0;
		private var _offsetsX:Vector.<Number>;
		private var _offsetsY:Vector.<Number>;
		private var _breaks:Vector.<int>;
		
		public var breaks:Boolean = true;
		
		public function TextField(w:int, h:int, text:String, f:String = "verdanaSmall", fontSize:Number = 12, color:uint = 0xffffffff, bold:Boolean = false, xmlFont:Boolean = false) {
			//_text = text;
			_fontSize = fontSize;
			_letters = new Vector.<Vector.<Sprite>>();
			_offsetsX = new Vector.<Number>();
			_offsetsY = new Vector.<Number>();
			_breaks = new Vector.<int>();
			//_containerWidth = w;
			//_containerHeight = h;
			/*_fontStyle = f;
			   var font:FontLoader;
			   if (xmlFont) {
			   font = FontManager.getXmlFont(f);
			   } else {
			   font = FontManager.getFont(f);
			 }*/
			reset(w, h, f, text);
		/*if (font.loaded) {
		   _font = font;
		   createLetters();
		   } else {
		   font.addEventListener(flash.events.Event.COMPLETE, onFontLoaded);
		 }*/
		}
		
		override public function setColor(r:Number, g:Number, b:Number):void {
			super.setColor(r, g, b);
			
			for (var i:int = 0; i < _letters.length; ++i) {
				for (var j:int = 0; j < _letters[i].length; ++j) {
					_letters[i][j].setColor(r, g, b);
				}
			}
		}
		
		public function setWidth(w:Number):void {
			reset(w, _containerHeight, _fontStyle, _text);
		}
		
		override public function set x(value:Number):void {
			_baseX = value;
			super.x = value;
		}
		
		override public function set y(value:Number):void {
			_baseY = value;
			super.y = value;
		}
		
		override public function get index():int {
			return super.index;
		}
		
		override public function set index(value:int):void {
			super.index = value;
			if (_letters) {
				for (var i:int = 0; i < _letters.length; ++i) {
					for (var j:int = 0; j < _letters[i].length; ++j) {
						_letters[i][j].index = value;
					}
				}
			}
		}
		
		private function getRowWidth(row:int):Number {
			var value:Number = 0;
			if (_letters && _letters.length > row && _letters[row].length) {
				var lastIndex:int = _letters[row].length - 1;
				var txtLastIndex:int = 0;
				for (var i:int = 0; i < row; i++) {
					txtLastIndex += _letters[i].length;
				}
				if (text.charAt(txtLastIndex + lastIndex) == " " && lastIndex != 0) {
					lastIndex--;
				}
				
				var breaksCharIndex:int = 0;
				if (row != 0) {
					breaksCharIndex = _breaks[row - 1];
				}
				var char:int = _text.charCodeAt(breaksCharIndex);
				var firstCharDesc:CharDescr = _font.getChar(char);
				
				var last:int = txtLastIndex + lastIndex;
				var lastCharDesc:CharDescr
				while (!lastCharDesc) {
					char = _text.charCodeAt(last);
					lastCharDesc = _font.getChar(char);
					last--;
				}
				
				value = _letters[row][lastIndex].x - _letters[row][0].x + firstCharDesc.xOff + lastCharDesc.srcW;
			}
			return value;
		}
		
		public function get text():String {
			return _text;
		}
		
		public function get fontSize():int {
			return _fontSize;
		}
		
		public function reset(w:int, h:int, fontStyle:String, text:String):void {
			
			_containerWidth = w;
			_containerHeight = h;
			
			_text = text;
			
			if (_fontStyle != fontStyle) {
				_fontStyle = fontStyle;
				_font = null;
				var font:FontLoader;
				if (_fontStyle != "verdanaSmall") {
					font = FontManager.getXmlFont(fontStyle);
				} else {
					font = FontManager.getFont(fontStyle);
				}
				if (font.loaded) {
					_font = font;
					createLetters();
				} else {
					font.addEventListener(flash.events.Event.COMPLETE, onFontLoaded);
				}
			} else {
				if (_font) {
					createLetters();
				}
			}
			
			if (_containerHeight) {
				vAlign = _vAlign;
			}
			if (_containerWidth) {
				hAlign = _hAlign;
			}
		
		}
		
		public function set text(value:String):void {
			reset(_containerWidth, _containerHeight, _fontStyle, value);
		}
		
		private function createLetters():void {
			var i:int;
			for (i = 0; i < _letters.length; ++i) {
				for (var j:int = 0; j < _letters[i].length; ++j) {
					removeChild(_letters[i][j]);
				}
				_letters[i].length = 0;
			}
			
			_letters.length = 0;
			_offsetsX.length = 0;
			_offsetsY.length = 0;
			
			var n:int = _text.length;
			var dx:Number = 0;
			var dy:Number = 0;
			
			var space:String = " ";
			
			_breaks.length = 0;
			_breaks = new Vector.<int>();
			var space_index:int = 0;
			var charid:int;
			var ch:CharDescr;
			if (this.breaks) {
				var forceBreak:Boolean;
				for (i = 0; i < n; ++i) {
					charid = _text.charCodeAt(i);
					ch = _font.getChar(charid);
					
					if (ch) {
						
						dx += ch.xOff + ch.srcW + 1;
						
						if (_containerWidth && dx > _containerWidth) {
							if (_breaks.length && space_index == _breaks[_breaks.length - 1]) {
								forceBreak = true;
							} else {
								_breaks.push(space_index);
							}
							dx = 0;
						}
						
						if (charid == space.charCodeAt(0) || forceBreak) {
							space_index = i;
							forceBreak = false;
						}
					}
				}
			}
			
			var row:int = 0;
			_letters[row] = new Vector.<Sprite>();
			_offsetsX.push(0);
			_offsetsY.push(0);
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
					frame.setRegion(new Rectangle(ch.srcX, ch.srcY, ch.srcW, ch.srcH));
					s.setTexture(frame);
					s.x = dx + ch.xOff;
					s.y = dy + ch.yOff;
					
					_letters[row].push(s);
					s.setColor(_r, _g, _b);
					s.index = index;
					addChild(s);
					
					dx += ch.xOff + ch.srcW + 1;
					
					if (_breaks.length > row && _breaks[row] == i) {
						row++;
						_letters[row] = new Vector.<Sprite>();
						_offsetsX.push(0);
						_offsetsY.push(0);
						dx = 0;
						dy = row * _font.font_height;
					}
				}
				
			}
		
		}
		
		public function set hAlign(v:String):void {
			_hAlign = v;
			if (_letters && _letters.length) {
				for (var i:int = 0; i < _letters.length; ++i) {
					var offsetX:int = 0;
					switch (v) {
						case HAlign.CENTER: 
							offsetX = Math.floor((_containerWidth - getRowWidth(i)) * 0.5)
							break;
						case HAlign.LEFT: 
							offsetX = 0;
							break;
						case HAlign.RIGHT: 
							offsetX = _containerWidth - getRowWidth(i);
							break;
					}
					for (var j:int = 0; j < _letters[i].length; j++) {
						_letters[i][j].x += offsetX - _offsetsX[i];
					}
					_offsetsX[i] = offsetX;
				}
			}
		}
		
		public function set vAlign(v:String):void {
			_vAlign = v;
			if (_letters && _letters.length) {
				for (var i:int = 0; i < _letters.length; ++i) {
					var offsetY:int = 0;
					switch (v) {
						case VAlign.CENTER: 
							offsetY = (_containerHeight - (_font.font_height * _letters.length)) / 2;
							break;
						case VAlign.TOP: 
							offsetY = 0;
							break;
						case VAlign.BOTTOM: 
							offsetY = _containerHeight - (_font.font_height * _letters.length);
							break;
					}
					for (var j:int = 0; j < _letters[i].length; j++) {
						_letters[i][j].y += offsetY - _offsetsY[i];
					}
					_offsetsY[i] = offsetY;
				}
			}
		}
		
		private function onFontLoaded(e:flash.events.Event):void {
			_font = e.target as FontLoader;
			reset(_containerWidth, _containerHeight, _fontStyle, _text);
			dispatchEvent(new badass.events.Event(badass.events.Event.LOADED));
		}
	
	}
}
