package badass.engine {
	import badass.events.Event;
	import badass.textures.BadassTexture;
	import badass.types.BlendType;
	import flash.events.*;
	
	import com.adobe.utils.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.system.ApplicationDomain;
	import flash.geom.*;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.BitmapData;
	import badass.engine.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class Renderer extends badass.engine.EventDispatcher {
		
		private var _context3D:Context3D;
		private var _viewportWidth:Number = 640;
		private var _viewportHeight:Number = 960;
		private var _stageWidth:Number = 640;
		private var _stageHeight:Number = 960;		
		private var _projectionMatrix:Matrix3D;
		
		private var _shaderProgram:Program3D;
		private var _movieClipShaderProgram:Program3D;
		
		private var _ready:Boolean = false;
		
		private var indexes:Vector.<uint>;
		private var lengths:Vector.<uint>;
		private var textures:Vector.<Texture>;
		
		private var r:Number = 1;
		private var g:Number = 1;
		private var b:Number = 1;
		
		private var _blendType:String;
		private var _lastTexture:BadassTexture;
		
		public function Renderer() {
			textures = new Vector.<Texture>();
			_stageWidth = _viewportWidth;
			_stageHeight = _viewportHeight;
		}
		
		public function getContext3D():Context3D {
			return _context3D;
		}
		
		public function setViewport(w:int, h:int):void {
			resize(w, h);
		}
		
		public function getWorldMatrix():Matrix3D {
			return _projectionMatrix;
		}
		
		public function setTexture(texture:BadassTexture):void {
			_context3D.setTextureAt(0, texture.nativeTexture);
		}
		
		public function createTexture(bitmapData:BitmapData):BadassTexture {
			return new BadassTexture(_context3D, bitmapData);
		}
		
		public function set color(value:int):void {
			b = (value % 256) / 255.0;
			value = value / 256;
			g = (value % 256) / 255.0;
			value = value / 256;
			r = (value % 256) / 255.0;
		}
		
		public function setGPUMovieClipProgram():void {
			_context3D.setVertexBufferAt(0, null);
			_context3D.setVertexBufferAt(1, null);
			_context3D.setVertexBufferAt(2, null);
			_context3D.setProgram(_movieClipShaderProgram);
		}
		
		public function setStandardProgram():void {
			_context3D.setProgram(_shaderProgram);
		}
		
		public function init(stage:Object):void {
			setViewport(stage.fullScreenWidth, stage.fullScreenHeight);
			var stage3DAvailable:Boolean = ApplicationDomain.currentDomain.hasDefinition("flash.display.Stage3D");
			if (stage3DAvailable) {
				stage.stage3Ds[0].addEventListener(flash.events.Event.CONTEXT3D_CREATE, onContext3DCreated);
				stage.stage3Ds[0].addEventListener(ErrorEvent.ERROR, onStage3DError);
				stage.stage3Ds[0].requestContext3D();
			} else {
				trace("Stage 3D not available");
			}
		}
		
		private function onStage3DError(e:ErrorEvent):void {
			trace("a motherfuckin error");
		}
		
		private function onContext3DCreated(e:Object):void {
			var stage3D:Stage3D = e.target as Stage3D;
			_context3D = stage3D.context3D;
			_context3D.enableErrorChecking = true;
			
			trace("let's do this motherfuuuuuckers");
			continueInit();
		
		}
		
		public function resize(width:int, height:int):void {			
			if (_stageHeight == _viewportHeight && _stageWidth == _viewportWidth) {
				_stageHeight = height;
				_stageWidth = width;
			}
			_viewportWidth = width;
			_viewportHeight = height;			
			if (_context3D) {
				_context3D.configureBackBuffer(_viewportWidth, _viewportHeight, 0, false);
				_projectionMatrix = createWorldMatrix(_stageWidth, _stageHeight);
			}
		}
		
		public function setStageSize(width:int, height:int):void {
			_stageWidth = width;
			_stageHeight = height;
			_projectionMatrix = createWorldMatrix(_stageWidth, _stageHeight);
			if (_ready) {
				_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _projectionMatrix, true);
			}
		}
		
		public function get viewportWidth():int {
			return _viewportWidth;
		}
		
		public function get viewportHeight():int {
			return _viewportHeight;
		}
		
		private function continueInit():void {
			resize(_viewportWidth, _viewportHeight);
			initShaders();
			
			setBlendType(BlendType.NONE);
			
			setStandardProgram();
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _projectionMatrix, true);
			_ready = true;
			dispatchEvent(new badass.events.Event(badass.events.Event.COMPLETE));
		}
		
		public function setBlendType(value:String):void {
			if (_blendType != value) {
				_blendType = value;
				if (_blendType == BlendType.NONE) {
					_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO)
				} else if (_blendType == BlendType.ONE_MINUS_SOURCE_ALPHA) {
					_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA)
				}
			}
		}
		
		private function createWorldMatrix(viewWidth:Number, viewHeight:Number):Matrix3D {
			var result:Matrix3D = new Matrix3D();
			result.identity();
			result.appendScale(2 / viewWidth, -2 / viewHeight, 1.0);
			result.appendTranslation(-1.0, 1.0, 0.0);
			
			return result;
		}
		
		private function initShaders():void {
			initStandardShader();
			initGPUMovieClipShader();
		}
		
		private function initStandardShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "text ft0, v1, fs0 <2d, nearest, nomip>;\n" + "mov ft1, ft0\n" + "mul ft1.w, v2.x, ft0.w\n" + "mov oc, ft1\n");
			
			_shaderProgram = _context3D.createProgram();
			_shaderProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		private function initGPUMovieClipShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, (["mul vt0, vc6.zw, va0.xy",
																		"add v0, vc6.xy, vt0.xy",
																		"mov vt0, va0",
																		"mov vt4, vc4",
																		"mul vt2, vt4, vc7.z",
																		"mov vt5, vc5",
																		"mul vt3, vt5, vc7.w",
																		"dp4 vt0.x, va0, vt2",
																		"dp4 vt0.y, va0, vt3",
																		"mov vt1, vt0",
																		"add vt0.xy, vt1.xy, vc7.xy",
																		"m44 op, vt0, vc0"]).join("\n"));
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, (["tex oc, v0, fs0 <2d, norepeat, linear, nomip>"]).join("\n"));
			
			_movieClipShaderProgram = _context3D.createProgram();
			_movieClipShaderProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		public function beginFrame():void {
			if (_ready) {
				_context3D.clear(r, g, b);
			}
		
		}
		
		public function endFrame():void {
			if (_ready) {
				_context3D.present();
			}
		}
	}
}