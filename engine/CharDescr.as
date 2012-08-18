package engine {
    
    public class CharDescr {
	public var srcX:Number;
	public var srcY:Number;
	public var srcW:Number;
	public var srcH:Number;
	public var xOff:Number;
	public var yOff:Number;
	public var xAdv:Number;
	public var page:int;
	public var chnl:int;

	public var kerning_pairs:Vector.<int>;

	public function CharDescr() {
	    srcX = 0;
	    srcY = 0;
	    srcW = 0;
	    srcH = 0;
	    xOff = 0;
	    yOff = 0;
	    xAdv = 0;
	    page = 0;
	    kerning_pairs = new Vector.<int>();
	}
    }
}