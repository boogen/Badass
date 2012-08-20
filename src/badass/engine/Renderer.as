package badass.engine {
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
	
	public class Renderer {
		
		private var _context3D:Context3D;
		private var _viewportWidth:Number = 640;
		private var _viewportHeight:Number = 960;
		private var _projectionMatrix:Matrix3D;
		private var _shaderProgram:Program3D;
		
		private var _ready:Boolean = false;
		
		private var _textures:Dictionary;
		
		private var indexes:Vector.<uint>;
		private var lengths:Vector.<uint>;
		private var textures:Vector.<Texture>;
		
		private var r:Number = 1;
		private var g:Number = 1;
		private var b:Number = 1;
		
		public function Renderer() {
			_textures = new Dictionary();
			
			textures = new Vector.<Texture>();
		}
		
		public function getContext3D():Context3D {
			return _context3D;
		}
		
		public function setViewport(w:int, h:int):void {
			_viewportWidth = w;
			_viewportHeight = h;
		}
		
		public function set color(value:int):void {
			b = (value % 256) / 255.0;
			value = value / 256;
			g = (value % 256) / 255.0;
			value = value / 256;
			r = (value % 256) / 255.0;
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
			_context3D.enableErrorChecking = false;
			
			trace("let's do this motherfuuuuuckers");
			continueInit();
		
		}
		
		public function resize(width:int, height:int):void {
			_viewportWidth = width;
			_viewportHeight = height;
			if (_context3D) {
				_context3D.configureBackBuffer(_viewportWidth, _viewportHeight, 0, false);
				_projectionMatrix = createWorldMatrix(_viewportWidth / 2, _viewportHeight / 2);
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
			
			_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA)
			
			_context3D.setProgram(_shaderProgram);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _projectionMatrix, true);
			_ready = true;
		
		}
		
		private function createWorldMatrix(viewWidth:Number, viewHeight:Number):Matrix3D {
			var result:Matrix3D = new Matrix3D();
			result.identity();
			result.appendScale(2 / viewWidth, -2 / viewHeight, 1.0);
			result.appendTranslation(-1.0, 1.0, 0.0);
			
			return result;
		}
		
		private function initShaders():void {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0\n" + "mov v0, va0\n" + "mov v1, va1\n" + "mov v2, va2\n");
			
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, "text ft0, v1, fs0 <2d, nearest, nomip>;\n" + "mov ft1, ft0\n" + "mul ft1.w, v2.x, ft0.w\n" + "mov oc, ft1\n");
			
			_shaderProgram = _context3D.createProgram();
			_shaderProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		public function getTexture(frame:Frame):Texture {
			if (!_textures[frame.texture]) {
				var texture:flash.display3D.textures.Texture = _context3D.createTexture(frame.textureWidth, frame.textureHeight, Context3DTextureFormat.BGRA, false);
				texture.uploadFromBitmapData(frame.texture);
				_textures[frame.texture] = texture;
			}
			
			return _textures[frame.texture];
		
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