package badass.animations {
	
	import avmplus.getQualifiedClassName;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.getDefinitionByName;
	import engine.Frame;
	
	 /* ...
	 * @author Marcin Bugala
	 */
	public class AnimationLoader extends EventDispatcher {
		private var _frames:Vector.<Frame>;
		private var _bitmapData:BitmapData;
		
		public var name:String;
		
		
		public function AnimationLoader() {
		}
		
		public function load(value:String):void {
		    name = value;
		    loadSpriteSheet(name);
		}
		
		
		
		private function frameSorter(lhs:Frame, rhs:Frame):Number {
			return lhs.index - rhs.index;
		}
		
		
		private function loadSpriteSheet(name:String):void {
			var spritesheetLoader:Loader = new Loader();
			spritesheetLoader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onSpriteSheetLoaded);
			spritesheetLoader.load(new URLRequest("assets/" + name + ".png"));
		}
		
		private function onXmlLoaded(e:Object):void {			
			_frames = new Vector.<Frame>();
			var xml:XML = new XML(e.target.data);
			for (var i:int = 0; i < xml.frame.length(); i++) {
				var f:Object = xml.frame[i];
				var index:int = f.@index;
				var dim:Rectangle = new Rectangle(f.dimension.@x, f.dimension.@y, f.dimension.@width, f.dimension.@height);
				var off:Point = new Point(f.offset.@x, f.offset.@y);
				var frame:Frame = new Frame(_bitmapData); //index, dim, off);
				frame.index = index;
				frame.uLeft = dim.x / _bitmapData.width;
				frame.vTop = dim.y / _bitmapData.height;
				frame.width = dim.width;
				frame.height = dim.height;
				frame.offset = off;
				_frames.push(frame);
			}			
			_frames.sort(frameSorter);

			dispatchEvent(new flash.events.Event(Event.COMPLETE));
		}
		
		private function onSpriteSheetLoaded(e:Object):void {
		    _bitmapData = (e.target.content as Bitmap).bitmapData;
		    
		    var xmlloader:URLLoader = new URLLoader();
		    xmlloader.addEventListener(flash.events.Event.COMPLETE, onXmlLoaded);
		    xmlloader.load(new URLRequest("assets/" + name + ".xml"));
		    
		}
		
		public function get bitmapData():BitmapData {
			return _bitmapData;
		}
		
		public function get frames():Vector.<Frame> {
			return _frames;
		}
	
	}

}