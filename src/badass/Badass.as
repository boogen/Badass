package badass {
	import badass.engine.Context;
	import badass.engine.DisplayListLayer;
	import badass.engine.EventDispatcher;
	import badass.engine.FontManager;
	import badass.engine.GPUMovieClipLayer;
	import badass.engine.MovieClip;
	import badass.engine.Layer;
	import badass.engine.Sprite;
	import badass.engine.TextField;
	import badass.events.ResizeEvent;
	import badass.events.TouchPhase;
	import badass.events.TouchProcessor;
	import badass.textures.BadassTexture;
	import badass.textures.ColorManager;
	import badass.types.LayerType;
	import flash.display.BitmapData;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;
	import badass.tweens.Tween;
	import badass.tweens.Tweener;
	import badass.engine.Context;
	
	public class Badass extends EventDispatcher {
		private var _context:badass.engine.Context;
		private var _zombie:MovieClip;
		private var _time:int;
		public var fps:int;
		private var _tweener:Tweener;
		private var _touchProcessor:TouchProcessor;
		private var _lastTime:int;
		private var _layers:Vector.<badass.engine.Layer>;
		private var _leftMouseDown:Boolean;
		private var _stage:Object;
		public var mainLoop:Function;
		public var tf:TextField;
		
		public function Badass(stage:Object):void {
			_layers = new Vector.<badass.engine.Layer>;
			_context = new badass.engine.Context();
			
			FontManager.init(_context);
			ColorManager.init(_context);
			_tweener = new Tweener();
			_touchProcessor = new TouchProcessor(_layers);
			
			_lastTime = getTimer();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			
			for each (var touchEventType:String in touchEventTypes)
				stage.addEventListener(touchEventType, onTouch, false, 0, true);
			
			stage.addEventListener(Event.RESIZE, onResize);
			_stage = stage;
			
			_context.renderer.addEventListener(badass.events.Event.COMPLETE, gentlemenStartYourEngines);
			_context.renderer.init(stage);
		}
		
		private function gentlemenStartYourEngines(e:badass.events.Event):void {
			dispatchEvent(new badass.events.Event(badass.events.Event.COMPLETE));
			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function setGPUProgram():void 
		{
			_context.renderer.setGPUMovieClipProgram();
		}
		
		public function getWorldMatrix():Matrix3D {
			return _context.renderer.getWorldMatrix();
		}
		
		private function onResize(e:Event):void {
			var stage:Object = e.target;
			_context.renderer.resize(stage.fullScreenWidth, stage.fullScreenHeight);
			dispatchEvent(new ResizeEvent(badass.events.Event.RESIZE, stage.stageWidth, stage.stageHeight));
		}
		
		public function setViewport(width:int, height:int):void {
			_context.renderer.resize(width, height);
		}
		
		public function get stageWidth():int {
			return _context.renderer.viewportWidth;
		}
		
		public function get stageHeight():int {
			return _context.renderer.viewportHeight;
		}
		
		public function set color(value:int):void {
			_context.renderer.color = value;
		}
		
		public function addTween(t:Tween):void {
			_tweener.add(t);
		}
		
		public function removeTweens(target:Object):void {
			_tweener.removeTweens(target);
		}
		
		public function getLayer(layerType:String, blendType:String):badass.engine.Layer {
			var result:badass.engine.Layer;
			if (layerType == LayerType.DISPLAY_LIST) {
				result = new DisplayListLayer(blendType);
			} else if (layerType == LayerType.MOVIECLIP) {
				result = new GPUMovieClipLayer();
			} else if (layerType == LayerType.FAST) {
				result = new badass.engine.Layer(blendType);
			}
			_layers.push(result);
			
			return result;
		}
		
		private function get touchEventTypes():Array {
			return Mouse.supportsCursor || !multitouchEnabled ? [MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_UP] : [TouchEvent.TOUCH_BEGIN, TouchEvent.TOUCH_MOVE, TouchEvent.TOUCH_END];
		}
		
		public static function get multitouchEnabled():Boolean {
			return Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
		}
		
		public function createTexture(bitmapData:BitmapData):BadassTexture {
			return _context.renderer.createTexture(bitmapData);
		}
		
		public function getContext3D():Context3D {
			return _context.renderer.getContext3D();
		}
		
		private function onTouch(event:Event):void {
			var globalX:Number;
			var globalY:Number;
			var touchID:int;
			var phase:String;
			
			if (event is MouseEvent) {
				var mouseEvent:MouseEvent = event as MouseEvent;
				globalX = mouseEvent.stageX;
				globalY = mouseEvent.stageY;
				touchID = 0;
				
				if (event.type == MouseEvent.MOUSE_DOWN) {
					_leftMouseDown = true;
				} else if (event.type == MouseEvent.MOUSE_UP) {
					_leftMouseDown = false;
				}
			} else {
				var touchEvent:TouchEvent = event as TouchEvent;
				globalX = touchEvent.stageX;
				globalY = touchEvent.stageY;
				touchID = touchEvent.touchPointID;
			}
			
			// figure out touch phase
			switch (event.type) {
				case TouchEvent.TOUCH_BEGIN: 
					phase = TouchPhase.BEGAN;
					break;
				case TouchEvent.TOUCH_MOVE: 
					phase = TouchPhase.MOVED;
					break;
				case TouchEvent.TOUCH_END: 
					phase = TouchPhase.ENDED;
					break;
				case MouseEvent.MOUSE_DOWN: 
					phase = TouchPhase.BEGAN;
					break;
				case MouseEvent.MOUSE_UP: 
					phase = TouchPhase.ENDED;
					break;
				case MouseEvent.MOUSE_MOVE: 
					phase = (_leftMouseDown ? TouchPhase.MOVED : TouchPhase.HOVER);
					break;
			}
			
			// enqueue touch in touch processor         
			_touchProcessor.enqueue(touchID, phase, globalX, globalY);
		}
		
		private function onEnterFrame(e:Object):void {
			tick();
			if (mainLoop != null) {
				mainLoop();
			}
		}
		
		public function tick():void {
			var t:int = getTimer();
			var dt:int = t - _lastTime;
			_lastTime = t;
			if (t > _time + 1000) {
				if (tf) {
					tf.text = fps.toString();
				}
				fps = 0;
				_time = t;
			}
			
			_touchProcessor.tick(dt);
			_tweener.advanceTime(dt / 1000.0);
			_context.renderer.beginFrame();
			
			for (var i:int = 0; i < _layers.length; ++i) {
				_layers[i].draw(_context.renderer);
				
			}
			_context.renderer.endFrame();
			fps++;
		}
	
	}
}