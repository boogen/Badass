package badass {
	import badass.engine.Context;
	import badass.engine.DisplayListLayer;
	import badass.engine.EventDispatcher;
	import badass.engine.FontManager;
	import badass.engine.GPUMovieClipLayer;
	import badass.engine.HAlign;
	import badass.engine.MovieClip;
	import badass.engine.Layer;
	import badass.engine.Quad;
	import badass.engine.Sprite;
	import badass.engine.TextField;
	import badass.events.ResizeEvent;
	import badass.events.TouchPhase;
	import badass.events.TouchProcessor;
	import badass.textures.BadassTexture;
	import badass.textures.ColorManager;
	import badass.types.BlendType;
	import badass.types.LayerType;
	import flash.display.BitmapData;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.system.System;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import badass.tweens.Tween;
	import badass.tweens.Tweener;
	import badass.engine.Context;
	import flash.utils.Timer;
	
	public class Badass extends EventDispatcher {
		private var _context:badass.engine.Context;
		private var _zombie:MovieClip;
		private var _time:int;
		public var currentFps:int;
		private var _tweener:Tweener;
		private var _touchProcessor:TouchProcessor;
		private var _lastTime:int;
		private var _layers:Vector.<badass.engine.Layer>;
		private var _leftMouseDown:Boolean;
		private var _stage:Object;
		public var mainLoop:Function;
		public var fpsTf:TextField;
		public var memoryTf:TextField;
		public var vram:TextField;
		private var _scaleX:Number = 1.0;
		private var _scaleY:Number = 1.0;
		public var fps:int = 30;
		private var _profiler:Boolean;
		private var _profilerLayer:Layer;
		private var _fps:TextField;
		private var _memory:TextField;
		private var _quad:Quad;
		
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
			_stage = stage;
			enableTouch();
			
			stage.addEventListener(Event.RESIZE, onResize);
			
			_context.renderer.addEventListener(badass.events.Event.COMPLETE, gentlemenStartYourEngines);
			_context.renderer.init(stage);
		}
		
		public function get profiler():Boolean {
			return _profiler;
		}
		
		public function set profiler(value:Boolean):void {
			_profiler = value;
			
			if (_profiler) {
				if (!_quad) {
					_quad = new Quad(80, 50, 0);
					_quad.alpha = 0.3;
					_fps = new TextField(100, 30, "fps", "system_white");
					_fps.hAlign = HAlign.LEFT;
					_quad.addChild(_fps);
					
					_memory = new TextField(100, 30, "mem", "system_white");
					_memory.hAlign = HAlign.LEFT;
					_memory.y = 20;
					_quad.addChild(_memory);
				}
				
				_profilerLayer = getLayer(LayerType.FAST, BlendType.ONE_MINUS_SOURCE_ALPHA);
				_profilerLayer.addChild(_quad);
				
			}
			else {
				if (_quad && _quad.parent) {
					_profilerLayer.removeChild(_quad);
				}
			}
		}
			
		
		public function setTutorialMode():void {
			_touchProcessor.tutorialMode = true;
			for (var i:int = 0; i < _layers.length; ++i) {
				_layers[i].setTutorialMode();
			}
			_context.renderer.setColor(0.439 * 0.3, 0.207 * 0.3, 0.007 * 0.3);
		}
		
		public function setStandardMode():void {
			_touchProcessor.tutorialMode = false;
			for (var i:int = 0; i < _layers.length; ++i) {
				_layers[i].setStandardMode();
			}
			_context.renderer.setColor(0.439, 0.207, 0.007);
		}
		
		public function disableTouch():void {
			for each (var touchEventType:String in touchEventTypes)
				_stage.removeEventListener(touchEventType, onTouch);
		}
		
		public function enableTouch():void {
			for each (var touchEventType:String in touchEventTypes)
				_stage.addEventListener(touchEventType, onTouch, false, 0, true);
		}
		
		public function disableTick():void {
			_stage.removeEventListener(Event.ENTER_FRAME, onTick);
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage.addEventListener(Event.ENTER_FRAME, onTick);
		}
		
		public function enableTick():void {
			_stage.removeEventListener(Event.ENTER_FRAME, onTick);
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function gentlemenStartYourEngines(e:badass.events.Event):void {
			dispatchEvent(new badass.events.Event(badass.events.Event.COMPLETE));
			enableTick();
		}
		
		public function getWorldMatrix():ByteArray {
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
		
		public function setStageSize(width:int, height:int):void {
			_context.renderer.setStageSize(width, height);
			_scaleX = _stage.fullScreenWidth / width;
			_scaleY = _stage.fullScreenHeight / height;
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
		
		public function setColor(r:Number, g:Number, b:Number):void {
			_context.renderer.setColor(r, g, b);
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
				result = new DisplayListLayer(blendType, _context.renderer);
			} else if (layerType == LayerType.MOVIECLIP) {
				result = new GPUMovieClipLayer(_context.renderer);
			} else if (layerType == LayerType.FAST) {
				result = new badass.engine.Layer(blendType, _context.renderer);
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
		
		public function createTexture(bitmapData:BitmapData, scaleEnabled:Boolean = true):BadassTexture {
			return _context.renderer.createTexture(bitmapData, scaleEnabled);
		}
		
		public function createCompressedTexture(ba:ByteArray):BadassTexture {
			return _context.renderer.createCompressedTexture(ba);
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
			_touchProcessor.enqueue(touchID, phase, globalX / _scaleX, globalY / _scaleY);
		}
		
		private function onTick(e:Object):void {
			tick();
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

			
			_touchProcessor.tick(dt);
			_tweener.advanceTime(dt / 1000.0);
			_context.renderer.beginFrame();
			
			for (var i:int = 0; i < _layers.length; ++i) {
				_layers[i].draw(_context.renderer);
			}
			
			if (_profilerLayer) {
				_profilerLayer.draw(_context.renderer);
			}
			_context.renderer.endFrame();
			currentFps++;
			
			if (t > _time + 1000) {
				
				if (_profiler) {
					_fps.text = "fps " + currentFps.toString();
					_memory.text = "mem " + (Math.round(10 * System.privateMemory / (1024 * 1024)) / 10.0).toString();
				}
				
				fps = currentFps;
				currentFps = 0;
				_time = t;
			}
		}
	
	}
}
