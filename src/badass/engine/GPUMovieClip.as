package badass.engine {
	import badass.textures.BadassTexture;
	import com.adobe.images.PNGEncoder;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DTextureFormat;
	import flash.utils.Endian;
	import flash.utils.getQualifiedClassName;
	import flash.utils.SetIntervalTimer;
	
	/**
	 * ...
	 * @author mosowski
	 */
	public class GPUMovieClip extends badass.engine.DisplayObject {
		
		public var bmp:BitmapData;
		public var children:Dictionary = new Dictionary();
		public var tracks:Dictionary = new Dictionary();
		public var framesChildren:Vector.<Vector.<GPUMovieClip>> = new Vector.<Vector.<GPUMovieClip>>();
		
		public var gpuParent:GPUMovieClip;
		public var currentMatrix:Matrix = new Matrix();
		public var currentFrame:int = 0;
		
		private var matrixData:ByteArray;
		public var bitmapScaleX:Number = 1.0;
		public var bitmapScaleY:Number = 1.0;
		
		public var track:GPUMovieClipAnimationTrack;
		
		public var totalFrames:int;
		public var childrenCount:int;
		
		public var uvs:ByteArray;
		public var name:String;
		
		public var texture:BadassTexture;
		
		public function GPUMovieClip() {
		}
		
		public function play():void 
		{
			
		}
		
		public function stop():void 
		{
			
		}
		
		override public function render(layer:badass.engine.Layer):void {
			if (visible) {
				layer.addBatch(this);
				super.render(layer);
			}
		}		
		
		private function nearUpPowOf2(n:uint):uint {
			n--;
			n |= n >> 1;
			n |= n >> 2;
			n |= n >> 4;
			n |= n >> 8;
			n |= n >> 16;
			n++;
			return n;
		}
		
		public function getBitmapFromDisplayObject(obj:flash.display.DisplayObject):void {
			if (bmp) {
				bmp.dispose();
			}
			
			var container:DisplayObjectContainer = obj as DisplayObjectContainer;
			if (container) {
				var visibility:Vector.<Boolean> = new Vector.<Boolean>();
				for (var j:int = 0; j < container.numChildren; ++j) {
					visibility.push(container.getChildAt(j).visible);
					container.getChildAt(j).visible = false;
				}
			}
			
			var bounds:Rectangle = obj.getBounds(obj);
			bmp = new BitmapData(bounds.width + 1, bounds.height + 1, true, 0x00000000);
			bmp.draw(obj, new Matrix(1, 0, 0, 1, -bounds.left, -bounds.top));
			
			var empty:Boolean = true;
			for (var i:int = 0; i < bmp.width; ++i) {
				for (j = 0; j < bmp.height; ++j) {
					if (bmp.getPixel32(i, j) != 0) {
						empty = false;
						break;
					}
				}
			}
			if (empty) {
				bmp.dispose();
				bmp = null;
			}
			
			if (bmp) {
				bitmapScaleX = bmp.width;
				bitmapScaleY = bmp.height;
			}
			
			if (container) {
				for (j = 0; j < container.numChildren; ++j) {
					container.getChildAt(j).visible = visibility.shift();
				}
			}
		}
		
		private function get currentChildren():Vector.<GPUMovieClip> {
			return currentFrame < framesChildren.length ? framesChildren[currentFrame] : noChildren;
		}
		
		private function processDisplayObject(d:flash.display.DisplayObject):GPUMovieClip {
			if (d is DisplayObjectContainer) {
				var gpuMc:GPUMovieClip = new GPUMovieClip();
				gpuMc.fromContainer(d as DisplayObjectContainer);
				return gpuMc;
			} else {
				gpuMc = new GPUMovieClip();
				gpuMc.getBitmapFromDisplayObject(d);
				return gpuMc;
			}
		}
		
		private function processChild(child:flash.display.DisplayObject, frame:int):GPUMovieClip {
			var name:String = child.name;
			
			if (!children[name]) {
				var gpuChild:GPUMovieClip = processDisplayObject(child);
				gpuChild.name = name;
				children[name] = gpuChild;
				gpuChild.gpuParent = this;
				gpuChild.track = tracks[name] = new GPUMovieClipAnimationTrack();
				gpuChild.track.fillPreceedingFrames(frame);
				childrenCount++;				
			}
			return children[name];
		}
		
		private function captureChildFrame(obj:flash.display.DisplayObject, layer:int):void {
			var name:String = obj.name;
			var track:GPUMovieClipAnimationTrack = tracks[name];
			
			if (obj.visible == false) {
				track.matrix.push(new Matrix(0, 0, 0, 0, 0, 0));
			} else {
				var mtx:Matrix = obj.transform.matrix.clone();
				var bounds:Rectangle = obj.getBounds(obj);
				if (!(obj is DisplayObjectContainer)) {
					mtx.translate(bounds.x, bounds.y);
				}
				track.matrix.push(mtx);
			}
		}
		
		public function fromMC(mc:flash.display.MovieClip):void {
			totalFrames = mc.totalFrames;
			
			for (var i:int = 0; i < mc.totalFrames; ++i) {
				// add trace to framescript to force movieclip revalidation
				mc.addFrameScript(i, function():void {
						trace(mc);
					});
				mc.gotoAndStop(i + 1);
				mc.gotoAndStop(i);
				
				currentFrame = i;
				framesChildren.push(new Vector.<GPUMovieClip>);
				
				for (var j:int = 0; j < mc.numChildren; ++j) {
					var d:flash.display.DisplayObject = mc.getChildAt(j);
					currentChildren.push(processChild(d, i));
					captureChildFrame(d, mc.getChildIndex(d));
				}
				for each (var ch:GPUMovieClip in children) {
					if (ch.track.length <= i) {
						ch.track.addEmptyFrame();
					}
				}
			}
		}
		
		public function fromSprite(spr:flash.display.Sprite):void {
			totalFrames = 1;
			framesChildren.push(new Vector.<GPUMovieClip>);
			
			for (var j:int = 0; j < spr.numChildren; ++j) {
				var d:flash.display.DisplayObject = spr.getChildAt(j);
				currentChildren.push(processChild(d, 0));
				captureChildFrame(d, spr.getChildIndex(d));
			}
		}
		
		public function fromContainer(c:DisplayObjectContainer):void {
			
			getBitmapFromDisplayObject(c);
			
			if (c is flash.display.MovieClip) {
				fromMC(c as flash.display.MovieClip);
			} else if (c is flash.display.Sprite) {
				fromSprite(c as flash.display.Sprite);
			} else {
				throw "GPUMovieClipData: unknown container.";
			}
		
		}
		
		public function createData():void {
			matrixData = new ByteArray();
			matrixData.endian = Endian.LITTLE_ENDIAN;
		}
		
		public function createGPUData():void {

			createData();
			
			for each (var ch:GPUMovieClip in children) {
				ch.createGPUData();
			}
			
		}
		
		
		
		public function setFrame(f:int):void {
			setChildrenFrame(f);
		}
		
		private function setChildrenFrame(f:int):void {
			currentFrame = f;
			for each (var ch:GPUMovieClip in currentChildren) {
				ch.currentMatrix.identity();
				ch.currentMatrix.scale(ch.bitmapScaleX, ch.bitmapScaleY);
				ch.currentMatrix.concat(ch.track.matrix[currentFrame]);
				ch.currentMatrix.concat(this.currentMatrix);
				
				ch.setChildrenFrame(ch.currentFrame);
			}
		}
		
		public function draw(ctx:Context3D, screenMtx:Matrix3D):void {
			if (texture) {
				matrixData.position = 0;
				matrixData.writeFloat(currentMatrix.a);
				matrixData.writeFloat(currentMatrix.c);
				matrixData.writeFloat(0);
				matrixData.writeFloat(currentMatrix.tx);
				
				matrixData.writeFloat(currentMatrix.b);
				matrixData.writeFloat(currentMatrix.d);
				matrixData.writeFloat(0);
				matrixData.writeFloat(currentMatrix.ty);
								
				ctx.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, screenMtx, true);
				ctx.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 4, 2, matrixData, 0);
				ctx.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 6, 1, uvs, 0);
				
				ctx.setTextureAt(0, texture.nativeTexture);
				
				if (!vertexBuffer) {
					prepareGPUStaticData(ctx);
				}				
				
				ctx.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				

				ctx.drawTriangles(indexBuffer, 0, 2);
			}
			
			if (framesChildren.length) {
				for (var i:int = 0; i < framesChildren[currentFrame].length; ++i) {
					framesChildren[currentFrame][i].draw(ctx, screenMtx);
				}
			}
		}
		
		private static var noChildren:Vector.<GPUMovieClip> = noChildren;
		private static var program:Program3D;
		private static var vertexBuffer:VertexBuffer3D;
		private static var indexBuffer:IndexBuffer3D;
		
		public static function prepareGPUStaticData(ctx:Context3D):void {
			vertexBuffer = ctx.createVertexBuffer(4, 2);
			vertexBuffer.uploadFromVector(new <Number>[0, 0, 0, 1, 1, 1, 1, 0], 0, 4);
			
			indexBuffer = ctx.createIndexBuffer(6);
			indexBuffer.uploadFromVector(new <uint>[0, 1, 2, 2, 3, 0], 0, 6);
		}
	
	}

}