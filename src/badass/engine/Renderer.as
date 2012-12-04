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
		private var _projectionMatrix:ByteArray;
		
		private var _standardProgram:Program3D;
		private var _noAlphaStandardProgram:Program3D;
		private var _standardCompressedProgram:Program3D;
		private var _noAlphaStandardCompressedProgram:Program3D;
		private var _linearProgram:Program3D;		
		private var _noAlphaLinearProgram:Program3D;
		private var _linearCompressedProgram:Program3D;
		private var _noAlphaLinearCompressedProgram:Program3D;
		private var _colorProgram:Program3D;
		private var _colorCompressedProgram:Program3D;
		private var _movieClipShaderProgram:Program3D;
		private var _movieClipColorShaderProgram:Program3D;
		
		private var _ready:Boolean = false;
		
		private var indexes:Vector.<uint>;
		private var lengths:Vector.<uint>;
		private var textures:Vector.<Texture>;
		
		private var r:Number = 1;
		private var g:Number = 1;
		private var b:Number = 1;
		
		private var _blendType:String;
		private var _lastTexture:BadassTexture;
		private var _lastColor:uint = 0;
		private var _colorVector:Vector.<Number>;
		private var _currentProgram:Program3D;
				
		
		public static const STANDARD:int = 0;
		public static const LINEAR:int = 1;
		public static const COLOR:int = 2;
		public static const MOVIECLIP:int = 3;
		public static const MOVIECLIP_COLOR:int = 4;
		
		private var _alphaState:Boolean = false;
		private var _compressedState:Boolean = false;
		private var _state:int = STANDARD;		
		
		private var _states:Array;
		
		public function Renderer() {
			textures = new Vector.<Texture>();
			_stageWidth = _viewportWidth;
			_stageHeight = _viewportHeight;
			_colorVector = new Vector.<Number>();
			_states = new Array();
			_states[STANDARD] = new Dictionary();
			_states[STANDARD][false] = new Dictionary();
			_states[STANDARD][true] = new Dictionary();
			_states[LINEAR] = new Dictionary();
			_states[LINEAR][false] = new Dictionary();
			_states[LINEAR][true] = new Dictionary();			
			_states[COLOR] = new Dictionary();
			_states[COLOR][false] = new Dictionary();
			_states[COLOR][true] = new Dictionary();
			_states[MOVIECLIP] = new Dictionary();
			_states[MOVIECLIP][false] = new Dictionary();
			_states[MOVIECLIP][true] = new Dictionary();
			_states[MOVIECLIP_COLOR] = new Dictionary();
			_states[MOVIECLIP_COLOR][false] = new Dictionary();
			_states[MOVIECLIP_COLOR][true] = new Dictionary();			
		}
		
		public function getContext3D():Context3D {
			return _context3D;
		}
		
		public function setViewport(w:int, h:int):void {
			resize(w, h);
		}
		
		public function getWorldMatrix():ByteArray {
			return _projectionMatrix;
		}
		
		public function setTexture(texture:BadassTexture):void {
			_context3D.setTextureAt(0, texture.nativeTexture);
		}
		
		public function createTexture(bitmapData:BitmapData, scaleEnabled:Boolean = true):BadassTexture {
			return new BadassTexture(_context3D, bitmapData, null, scaleEnabled);
		}
		
		public function createCompressedTexture(ba:ByteArray, scaleEnabled:Boolean = true):BadassTexture {
			return new BadassTexture(_context3D, null, ba, scaleEnabled);
		}
		
		public function set color(value:int):void {
			b = (value % 256) / 255.0;
			value = value / 256;
			g = (value % 256) / 255.0;
			value = value / 256;
			r = (value % 256) / 255.0;
		}
		
		public function setColor(r:Number, g:Number, b:Number):void {
			this.r = r;
			this.g = g;
			this.b = b;
		}
		
		public function getGPUMovieClipProgram():Program3D {
			return _movieClipShaderProgram;
		}
		
		public function getGPUMovieClipColorProgram():Program3D {
			return _movieClipColorShaderProgram;
		}
		
		public function getStandardProgram(compressed:Boolean = false):Program3D {
			if (compressed) {
				return _standardCompressedProgram;
			}
			else {
				return _standardProgram;
			}
		}
		
		public function getLinearProgram(compressed:Boolean = false):Program3D {
			if (compressed) {
				return _linearCompressedProgram;
			}
			else {
				return _linearProgram;
			}
		}
		
		public function getColorProgram(compressed:Boolean = false):Program3D {
			if (compressed) {
				return _colorCompressedProgram;
			}
			else {
				return _colorProgram;
			}
		}
		
		public function setProgram(program:Program3D):Boolean {
			if (program != _currentProgram) {
				_currentProgram = program;
				_context3D.setVertexBufferAt(0, null);
				_context3D.setVertexBufferAt(1, null);
				_context3D.setVertexBufferAt(2, null);
				_context3D.setProgram(program);
				return true;
			}
			
			return false;
		}
		
		public function getState():int {
			return _state;
		}
		
		public function getAlphaState():Boolean {
			return _alphaState;
		}
		
		public function getCompressedState():Boolean {
			return _compressedState;
		}
		
		public function changeState(state:int, compressed:Boolean, alpha:Boolean):Boolean {
			_state = state;
			_compressedState = compressed;
			_alphaState = alpha;
			return setProgram(_states[state][compressed][alpha]);
		}
		
		/*public function setColor(color:uint):void
		   {
		   if (color != _lastColor) {
		   _lastColor = color;
		   _colorVector.length = 0;
		   var b:Number = (color % 256) / 255.0;
		   color = color / 256;
		   var g:Number = (color % 256) / 255.0;
		   color = color / 256;
		   var r:Number = (color % 256) / 255.0;
		   color = color / 256;
		   var a:Number = (color % 256) / 255.0;
		   _colorVector.push(r, g, b, a);
		   _context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, _colorVector);
		
		   }
		 }*/
		
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
		}
		
		private function onContext3DCreated(e:Object):void {
			var stage3D:Stage3D = e.target as Stage3D;
			_context3D = stage3D.context3D;
			_context3D.enableErrorChecking = false;
			_context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
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
				_context3D.configureBackBuffer(_viewportWidth, _viewportHeight, 0, true);
				_projectionMatrix = createWorldMatrix(_stageWidth, _stageHeight);
			}
		}
		
		public function setStageSize(width:int, height:int):void {
			_stageWidth = width;
			_stageHeight = height;
			_projectionMatrix = createWorldMatrix(_stageWidth, _stageHeight);
			if (_ready) {
				_context3D.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 0, 2, _projectionMatrix, 0);
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
			
			setProgram(getStandardProgram());
			_context3D.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 0, 2, _projectionMatrix, 0);
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
				} else if (_blendType == BlendType.SOURCE_ALPHA) {
					_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA)
				}
			}
		}
		
		private function createWorldMatrix(viewWidth:Number, viewHeight:Number):ByteArray {
            var result:ByteArray = new ByteArray();
            result.endian = Endian.LITTLE_ENDIAN;
            result.writeFloat(2 / viewWidth);
            result.writeFloat(0);
            result.writeFloat(0);
            result.writeFloat( -1);

            result.writeFloat(0);
            result.writeFloat( -2 / viewHeight);
            result.writeFloat(0);
            result.writeFloat(1);
			
			return result;
		}
		
		private function initShaders():void {
			initStandardShader();
			initNoAlphaStandardShader();
			initCompressedStandardShader();
			initNoAlphaCompressedStandardShader();
			initLinearShader();
			initNoAlphaLinearShader();
			initCompressedLinearShader();
			initNoAlphaCompressedLinearShader();
			initColorShader();
			initCompressedColorShader();
			initGPUMovieClipShader();
			initGPUMovieClipColorShader();
			
			_states[STANDARD][false][true] = _standardProgram;
			_states[STANDARD][false][false] = _noAlphaStandardProgram;
			_states[STANDARD][true][true] = _standardCompressedProgram;
			_states[STANDARD][true][false] = _noAlphaStandardCompressedProgram
			
			_states[LINEAR][false][true] = _linearProgram;
			_states[LINEAR][false][false] = _noAlphaLinearProgram;
			_states[LINEAR][true][true] = _linearCompressedProgram;
			_states[LINEAR][true][false] = _noAlphaLinearCompressedProgram;
			
			_states[COLOR][false][true] = _colorProgram;
			_states[COLOR][false][false] = _colorProgram;
			_states[COLOR][true][true] = _colorCompressedProgram;
			_states[COLOR][true][false] = _colorCompressedProgram;
			
			_states[MOVIECLIP][false][true] = _movieClipShaderProgram;
			_states[MOVIECLIP][false][false] = _movieClipShaderProgram;
			_states[MOVIECLIP][true][true] = _movieClipShaderProgram;
			_states[MOVIECLIP][true][false] = _movieClipShaderProgram;
			
			_states[MOVIECLIP_COLOR][false][true] = _movieClipColorShaderProgram;
			_states[MOVIECLIP_COLOR][false][false] = _movieClipColorShaderProgram;
			_states[MOVIECLIP_COLOR][true][true] = _movieClipColorShaderProgram;
			_states[MOVIECLIP_COLOR][true][false] = _movieClipColorShaderProgram;			
		}
		
		private function initNoAlphaStandardShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex oc, v1, fs0 <2d, nearest, nomip>;\n");
			
			_noAlphaStandardProgram = _context3D.createProgram();
			_noAlphaStandardProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);			
		}
		
		private function initStandardShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex ft0, v1, fs0 <2d, nearest, nomip>;\n" + "mov ft1, ft0\n" + "mul ft1.w, v2.x, ft0.w\n" + "mov oc, ft1\n");
			
			_standardProgram = _context3D.createProgram();
			_standardProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		private function initNoAlphaCompressedStandardShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex oc, v1, fs0 <2d, dxt5, nearest, nomip>;\n");
			
			_noAlphaStandardCompressedProgram = _context3D.createProgram();
			_noAlphaStandardCompressedProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		private function initCompressedStandardShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex ft0, v1, fs0 <2d, dxt5, nearest, nomip>;\n" + "mov ft1, ft0\n" + "mul ft1.w, v2.x, ft0.w\n" + "mov oc, ft1\n");
			
			_standardCompressedProgram = _context3D.createProgram();
			_standardCompressedProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}		
		
		private function initNoAlphaLinearShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();

			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex oc, v1, fs0 <2d, norepeat, linear, nomip>;\n");
			
			_noAlphaLinearProgram = _context3D.createProgram();
			_noAlphaLinearProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}		
		
		private function initLinearShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();

			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex ft0, v1, fs0 <2d, norepeat, linear, nomip>;\n" + "mov ft1, ft0\n" + "mul ft1, v2.yzwx, ft0\n" + "mov oc, ft1\n");
			
			_linearProgram = _context3D.createProgram();
			_linearProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		private function initNoAlphaCompressedLinearShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex oc, v1, fs0 <2d, dxt5, norepeat, linear, nomip>;\n");
			
			_noAlphaLinearCompressedProgram = _context3D.createProgram();
			_noAlphaLinearCompressedProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}			
		
		private function initCompressedLinearShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex ft0, v1, fs0 <2d, dxt5, norepeat, linear, nomip>;\n" + "mov ft1, ft0\n" + "mul ft1, v2.yzwx, ft0\n" + "mov oc, ft1\n");
			
			_linearCompressedProgram = _context3D.createProgram();
			_linearCompressedProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}				
		
		private function initColorShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex ft0, v1, fs0 <2d, norepeat, nearest, nomip>;\n" + "mov ft1, ft0\n" + "mul ft1, v2.yzwx, ft0\n" + "mov oc, ft1\n");
			
			_colorProgram = _context3D.createProgram();
			_colorProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		private function initCompressedColorShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "dp4 op.x, va0, vc0\n" + "dp4 op.y, va0, vc1\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "tex ft0, v1, fs0 <2d, dxt5, norepeat, nearest, nomip>;\n" + "mov ft1, ft0\n" + "mul ft1, v2.yzwx, ft0\n" + "mov oc, ft1\n");
			
			_colorCompressedProgram = _context3D.createProgram();
			_colorCompressedProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}		
		
		private function initGPUMovieClipShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, (["mul vt0, vc6.zw, va0.xy",
																		  "add v0, vc6.xy, vt0.xy",
																		  "mov vt0, va0",
																		  "mov vt4, vc4",
																		  "mul vt2, vt4, vc9.z",
																		  "mov vt5, vc5",
																		  "mul vt3, vt5, vc9.w",
																		  "mul vt7, va0, vc7",
																		  "dp4 vt0.x, vt7, vt2",
																		  "dp4 vt0.y, vt7, vt3",
																		  "mov vt1, vt0",
																		  "add vt0.xy, vt1.xy, vc9.xy",
																		  "mov vt1, vt0",
																		  "add vt0.xy, vt1.xy, vc8.xy",
																		  "mov op, vt0\n",
                                                                          "dp4 op.x, vt0, vc0\n",
                                                                          "dp4 op.y, vt0, vc1\n"]).join("\n"));
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, (["tex oc, v0, fs0 <2d, norepeat, linear, nomip>"]).join("\n"));
			
			_movieClipShaderProgram = _context3D.createProgram();
			_movieClipShaderProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		private function initGPUMovieClipColorShader():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, (["mul vt0, vc6.zw, va0.xy",
																		  "add v0, vc6.xy, vt0.xy",
																		  "mov vt0, va0",
																		  "mov vt4, vc4",
																		  "mul vt2, vt4, vc9.z",
																		  "mov vt5, vc5",
																		  "mul vt3, vt5, vc9.w",
																		  "mul vt7, va0, vc7",
																		  "dp4 vt0.x, vt7, vt2",
																		  "dp4 vt0.y, vt7, vt3",
																		  "mov vt1, vt0",
																		  "add vt0.xy, vt1.xy, vc9.xy",
																		  "mov vt1, vt0",
																		  "add vt0.xy, vt1.xy, vc8.xy",
																		  "mov op, vt0\n",
                                                                          "dp4 op.x, vt0, vc0\n",
                                                                          "dp4 op.y, vt0, vc1\n"]).join("\n"));

			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, (["tex ft0, v0, fs0 <2d, norepeat, linear, nomip>", "mov ft1, ft0", "mul ft1, ft0, fc0", "mov oc, ft1"]).join("\n"));
			
			_movieClipColorShaderProgram = _context3D.createProgram();
			_movieClipColorShaderProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		public function beginFrame():void {
			if (_ready) {
				_context3D.clear(r, g, b);
			}
		
		}
		
		public function setMask(value:int):void {
			_context3D.setStencilReferenceValue(value);
			_context3D.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.EQUAL, Context3DStencilAction.INCREMENT_SATURATE, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP);
		}
		
		public function endMask(value:int):void {
			_context3D.setStencilReferenceValue(value);
			_context3D.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.LESS_EQUAL, Context3DStencilAction.KEEP , Context3DStencilAction.KEEP, Context3DStencilAction.KEEP);
		}
		
		public function turnOffMask():void {
			_context3D.setStencilReferenceValue(1);
			_context3D.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS, Context3DStencilAction.KEEP , Context3DStencilAction.KEEP, Context3DStencilAction.KEEP);
		}
		
		public function endFrame():void {
			if (_ready) {
				_context3D.present();
			}
		}
	}
}