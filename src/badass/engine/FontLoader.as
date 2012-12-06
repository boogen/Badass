package badass.engine {
	import badass.textures.BadassTexture;
	import com.cantstopgames.utils.ImageLoader;
	import com.cantstopgames.utils.XmlLoader;
	import flash.events.IOErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
	import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.events.EventDispatcher;
    import flash.display.Loader;
	import badass.engine.Context;

    public class FontLoader extends EventDispatcher {
	protected var _name:String;
	public var texture:BadassTexture;

	public var font_height:int;
	public var base:int;
	public var scalew:int;
	public var scaleh:int;
	public var outline_thickness:int;

	public var def_char:CharDescr;
	public var has_outline:Boolean;
	public var scale:Number;
	public var encoding:int;

	public var chars:Dictionary;
	public var fx_file:String;

	public var loaded:Boolean = false;
	protected var _context:badass.engine.Context;
	
	protected const path:String = "images_mobile/fonts/";
	
	public function FontLoader(context:badass.engine.Context) {
	    chars = new Dictionary();
	    def_char = new CharDescr();
		_context = context;
	}

	public function load(fontname:String):void {
	    _name = fontname;
	    loadSpriteSheet(_name);
	}

	private function loadSpriteSheet(name:String):void {
		var spritesheetLoader:ImageLoader = new ImageLoader();		
	    spritesheetLoader.addEventListener(Event.COMPLETE, onSpriteSheetLoaded);
		spritesheetLoader.addEventListener(IOErrorEvent.IO_ERROR, loadingIoError);
	    spritesheetLoader.load(path + name + ".png");
	}
	
	private function loadingIoError(e:IOErrorEvent):void
	{
		trace("error");
	}

	protected function onSpriteSheetLoaded(e:Event):void {
	    var bitmapData:BitmapData = (e.target.content as Bitmap).bitmapData;
		
		texture = _context.renderer.createTexture(bitmapData);
		
	    var fntLoader:URLLoader = new URLLoader();
	    fntLoader.addEventListener(Event.COMPLETE, onDescriptionLoaded);
	    fntLoader.load(new URLRequest(path + _name + ".fnt"));
	}

	private function onDescriptionLoaded(e:Event):void {
		var data:String = e.target.data;
	    var lines:Array = data.split(/\n/);

	    for (var i:int = 0; i < lines.length; ++i) {
		var line:String = lines[i];
		var pos:int = skipWhiteSpace(line, 0);
		var pos2:int = findEndOfToken(line, pos);

		var token:String = line.substr(pos, pos2 - pos);

		if (token == "info") {
		    interpretInfo(line, pos2);
		}
		else if (token == "common") {
		    interpretCommon(line, pos2);
		}
		else if (token == "char") {
		    interpretChar(line, pos2);
		}
		
	    }

		loaded = true;
	    dispatchEvent(new Event(Event.COMPLETE));
	}

	public function getChar(id:int):CharDescr {
	    return chars[id];
	}

	private function skipWhiteSpace(line:String, start:int):int {
	    var n:int = start;

	    while (n < line.length) {
		if (line.charAt(n) != ' ' && line.charAt(n) != '\t' && line.charAt(n) != '\r' && line.charAt(n) != '\n') {
		    break;
		}

		++n;
	    }

	    return n;
	}

	private function findEndOfToken(str:String, start:int):int {
	    var n:int = start;

	    if (str.charAt(n) == '"') {
		n++;
		while (n < str.length) {
		    if (str.charAt(n) == '"') {
			++n;
			break;
		    }
		    ++n;
		}
	    }
	    else {
		while (n < str.length) {
		    if (str.charAt(n) == ' ' || str.charAt(n) == '\t' || str.charAt(n) == '\r' || str.charAt(n) == '\n' || str.charAt(n) == '=') {
			break;
		    }
		    ++n;
		}
	    }

	    return n;
	}

	private function interpretChar(str:String, start:int):void {
	    var id:int = 0;
	    var x:int = 0;
	    var y:int = 0;
	    var width:int = 0;
	    var height:int = 0;
	    var xoffset:int = 0;
	    var yoffset:int = 0;
	    var xadvance:int = 0;
	    var page:int = 0;
	    var chnl:int = 0;

	    var pos:int = start;
	    var pos2:int = start;

	    while (true) {
		pos = skipWhiteSpace(str, pos2);
		pos2 = findEndOfToken(str, pos);

		var token:String = str.substr(pos, pos2 - pos);

		pos = skipWhiteSpace(str, pos2);
		if (pos == str.length || str.charAt(pos) != '=') {
		    break;
		}

		pos = skipWhiteSpace(str, pos + 1);
		pos2 = findEndOfToken(str, pos);

		var value:int = parseInt(str.substr(pos, pos2 - pos), 10);

		
		if (token == "id") {
		    id = value;
		}
		else if (token == "x") {
		    x = value;
		}
		else if (token == "y") {
		    y = value;
		}
		else if (token == "width") {
		    width = value;
		}
		else if (token == "height") {
		    height = value;
		}
		else if (token == "xoffset") {
		    xoffset = value;
		}
		else if (token == "yoffset") {
		    yoffset = value;
		}
		else if (token == "xadvance") {
		    xadvance = value;
		}
		else if (token == "page") {
		    page = value;
		}
		else if (token == "chnl") {
		    chnl = value;
		}

		if (pos == str.length) {
		    break;
		}
	    }

	    addChar(id, x, y, width, height, xoffset, yoffset, xadvance, page, chnl);
	}

	
	private function interpretInfo(str:String, start:int):void {
	    var ot:int;

	    var pos:int = start;
	    var pos2:int = start;

	    while (true) {
		pos = skipWhiteSpace(str, pos2);
		pos2 = findEndOfToken(str, pos);
		
		var token:String = str.substr(pos, pos2 - pos);

		pos = skipWhiteSpace(str, pos2);
		if (pos == str.length || str.charAt(pos) != '=') {
		    break;
		}

		pos = skipWhiteSpace(str, pos + 1);
		pos2 = findEndOfToken(str, pos);

		var value:int = parseInt(str.substr(pos, pos2 - pos), 10);

		if (token == "outline") {
		    ot = value;
		}
		if (pos == str.length) {
		    break;
		}
	    }

	    outline_thickness = ot;
	}

	private function interpretCommon(str:String, start:int):void {
	    var local_fontheight:int;
	    var local_base:int;
	    var local_scalew:int;
	    var local_scaleh:int;
	    var local_pages:int;
	    var local_packed:int;

	    var pos:int = start;
	    var pos2:int = start;

	    while(true) {
		pos = skipWhiteSpace(str, pos2);
		pos2 = findEndOfToken(str, pos);
		
		var token:String = str.substr(pos, pos2 - pos);
		pos = skipWhiteSpace(str, pos2);
		if (pos == str.length || str.charAt(pos) != '=') {
		    break;
		}

		pos = skipWhiteSpace(str, pos + 1);
		pos2 = findEndOfToken(str, pos);

		var value:String = str.substr(pos, pos2 - pos);
		

		if (token == "lineHeight") {
		    local_fontheight = parseInt(value, 10);
		}
		else if (token == "base") {
		    local_base = parseInt(value, 10);
		}
		else if (token == "scaleW") {
		    local_scalew = parseInt(value, 10);
		}
		else if (token == "scaleH") {
		    local_scaleh = parseInt(value, 10);
		}
		else if (token == "pages") {
		    local_pages = parseInt(value, 10);
		}
		else if (token == "packed") {
		    local_packed = parseInt(value, 10);
		}

		if (pos == str.length) {
		    break;
		}
	    }

	    setCommonInfo(local_fontheight, local_base, local_scalew, local_scaleh, local_pages, local_packed > 0);
	
	}

	protected function setCommonInfo(fh:int, b:int, sw:int, sh:int, pag:int, pack:Boolean):void {
	    font_height = fh;
	    base = b;
	    scalew = sw;
	    scaleh = sh;
	
	    if (pack && outline_thickness) {
		has_outline = true;
	    }
	}

	protected function addChar(id:int, x:int, y:int, w:int, h:int, xoffset:int, yoffset:int, xadvance:int, page:int, chnl:int):void {
	    if (chnl == 1) {
		chnl = 0x00010000;
	    }
	    else if (chnl == 2) {
		chnl = 0x00000100;
	    }
	    else if (chnl == 4) {
		chnl = 0x00000001;
	    }
	    else if (chnl == 8) {
		chnl = 0x01000000;
	    }
	    else {
		chnl = 0;
	    }

	    if (id >= 0) {
		var ch:CharDescr = new CharDescr();
		ch.srcX = x;
		ch.srcY = y;
		ch.srcW = w;
		ch.srcH = h;
		ch.xOff = xoffset;
		ch.yOff = yoffset;
		ch.xAdv = xadvance;
		ch.page = page;
		ch.chnl = chnl;

		chars[id] = ch;
	    }

	    if (id == -1) {
		def_char.srcX = x;
		def_char.srcY = y;
		def_char.srcW = w;
		def_char.srcH = h;
		def_char.xOff = xoffset;
		def_char.yOff = yoffset;
		def_char.xAdv = xadvance;
		def_char.page = page;
		def_char.chnl = chnl;

	    }
	}
	
    }
}
