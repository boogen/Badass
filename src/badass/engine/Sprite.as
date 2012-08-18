package badass.engine {

    import flash.display.BitmapData;
    import flash.utils.ByteArray;
    
    public class Sprite extends DisplayObject {
	

	public function Sprite() {
	}

	public function setTexture(texture:BitmapData):void {
	    _frame = new Frame(texture);
	}

	public function set uLeft(value:Number):void {
	    _frame.uLeft = value;
	}

	public function set vTop(value:Number):void {
	    _frame.vTop = value;
	}

	public function set width(value:Number):void {
	    _frame.width = value;
	}

	public function set height(value:Number):void {
	    _frame.height = value;
	}

	override public function get width():Number {
	    return _frame.width;
	}

	override public function get height():Number {
	    return _frame.height;
	}

	public function get textureWidth():Number {
	    return _frame.textureWidth;
	}

	public function get textureHeight():Number {
	    return _frame.textureHeight;
	}


	override public function writeToByteArray(ba:ByteArray):void {
	    if (_frame) {
		var w:Number = width * scaleX;
		var h:Number = height * scaleY;
		
		var gx:Number = globalX;
		var gy:Number = globalY;

		var s:Number = Math.sin(rotation);
		var c:Number = Math.cos(rotation);			
		
		var u:Number = s * h * 0.5 - c * w * 0.5;
		var v:Number = s * w * 0.5 + c * h * 0.5;
		var p:Number = s * -h * 0.5 - c * w * 0.5;
		var q:Number = s * w * 0.5 - c * h * 0.5;

		var a:Number = alpha;
	   
		ba.writeFloat(gx + p + w /2);
		ba.writeFloat(gy + q + h / 2);
		ba.writeFloat(_frame.uLeft);
		ba.writeFloat(_frame.vTop);
		ba.writeFloat(a);

		ba.writeFloat(gx - u + w / 2);
		ba.writeFloat(gy - v + h / 2);
		ba.writeFloat(_frame.uRight);
		ba.writeFloat(_frame.vTop);
		ba.writeFloat(a);
		
		ba.writeFloat(gx - p + w / 2);
		ba.writeFloat(gy - q + h / 2);
		ba.writeFloat(_frame.uRight);
		ba.writeFloat(_frame.vBottom);
		ba.writeFloat(a);

		ba.writeFloat(gx + u + w / 2);
		ba.writeFloat(gy + v + h / 2);
		ba.writeFloat(_frame.uLeft);
		ba.writeFloat(_frame.vBottom);
		ba.writeFloat(a);

	    }
	}

	override public function render(layer:Layer):void {
	    if (_frame && visible) {
			layer.addBatch(this);
			super.render(layer);
	    }
	}

    }
}