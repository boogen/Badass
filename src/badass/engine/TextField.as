package badass.engine {
    import flash.events.Event;

    public class TextField extends DisplayObject {
	private var _text:String;
	private var _font:FontLoader;
	private var _letters:Vector.<Sprite>;
	public var hAlign:String;

	public function TextField(width:int, height:int, text:String, f:String="Verdana",
                                  fontSize:Number=12, color:uint=0x0, bold:Boolean=false) {	    
	    _text = text;
	    _letters = new Vector.<Sprite>();
	    var font:FontLoader = new FontLoader();
	    font.addEventListener(Event.COMPLETE, onFontLoaded);
	  //  font.load(f);
	}

	public function get text():String {
	    return _text;
	}

	public function set text(value:String):void {
	    _text = value;
	    if (_font) {
		createLetters();
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

	    for (i = 0; i < n; ++i) {
		var charid:int = _text.charCodeAt(i);
		var ch:CharDescr = _font.getChar(charid);
				

		if (ch) {
		    var u1:Number = ch.srcX / _font.scalew;
		    var v1:Number = ch.srcY / _font.scaleh;

		    var u2:Number = u1 + ch.srcW / _font.scalew;
		    var v2:Number = v1 + ch.srcH / _font.scaleh;

		    var a:Number = ch.xAdv;
		    var w:Number = ch.srcW;
		  /*  if (charid == ' ') {
			w += 10;
		    }*/

		    var s:Sprite = new Sprite();
		    s.setTexture(new Frame(_font.bitmapData));
		    s.x = dx + ch.xOff;
		    s.y = ch.yOff;
		    s.uLeft = u1;
		    s.vTop = v1;
		    s.width = ch.srcW;
		    s.height = ch.srcH;

		    s.color = color;
		    _letters.push(s);
		    addChild(s);
		    
		    dx += ch.xOff + ch.srcW + 1;
		}
	    }
	    
	}

	private function onFontLoaded(e:Event):void {
	    _font = e.target as FontLoader;
	    createLetters();
	}

	
    }
}