package badass {
	import badass.engine.Context;
	import badass.engine.MovieClip;
	import badass.engine.Layer;
	import badass.engine.Sprite;
	import badass.events.TouchPhase;
	import badass.events.TouchProcessor;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;
	import flash.text.TextField;
	import badass.tweens.Tween;
	import badass.tweens.Tweener;
	import badass.engine.Context;
	
	public class Badass {
		private var _context:badass.engine.Context;
		private var _zombie:MovieClip;
		private var _tf:flash.text.TextField;
		private var _time:int;
		private var _fps:int;
		private var _tweener:Tweener;
		private var _touchProcessor:TouchProcessor;
		private var _lastTime:int;
		private var _layers:Vector.<badass.engine.Layer>;
		private var _leftMouseDown:Boolean;
		private var _stageWidth:int = 640;
		private var _stageHeight:int = 960;
		private var _stage:Object;
		public var mainLoop:Function;
		
		public function Badass(stage:Object):void {
			_layers = new Vector.<badass.engine.Layer>;
			_context = new badass.engine.Context();
			_context.renderer.setViewport(_stageWidth, _stageHeight);
			_context.renderer.init(stage);
			
			_tweener = new Tweener();
			_touchProcessor = new TouchProcessor(_layers);
			
			_lastTime = getTimer();
			stage.frameRate = 60;
			
			_tf = new flash.text.TextField();
			_tf.x = 200;
			stage.addChild(_tf);
			
			for each (var touchEventType:String in touchEventTypes)
				stage.addEventListener(touchEventType, onTouch, false, 0, true);
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage = stage;
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
		
		public function getLayer():badass.engine.Layer {
			var result:badass.engine.Layer = new badass.engine.Layer();
			_layers.push(result);
			
			return result;
		}
		
		private function get touchEventTypes():Array {
			return Mouse.supportsCursor || !multitouchEnabled ? [MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_UP] : [TouchEvent.TOUCH_BEGIN, TouchEvent.TOUCH_MOVE, TouchEvent.TOUCH_END];
		}
		
		public static function get multitouchEnabled():Boolean {
			return Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
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
				_tf.text = _fps.toString();
				_fps = 0;
				_time = t;
			}
			
			_touchProcessor.tick(dt);
			_tweener.advanceTime(dt / 1000.0);
			_context.renderer.beginFrame();
			
			for (var i:int = 9; i < _layers.length; ++i) {
				_layers[i].draw(_context.renderer);
			}
			_context.renderer.endFrame();
			_fps++;
		}
	
	}
}