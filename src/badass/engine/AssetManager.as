package badass.engine {
    import flash.events.*;
    import flash.utils.Dictionary;
    import flash.display.Loader;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.net.URLRequest;

    public class AssetManager {
	private static var _waitingSprites:Dictionary;
	private static var _assets:Dictionary;
	private static var _loaders:Dictionary;

	{
	    _waitingSprites = new Dictionary();
	    _assets = new Dictionary();
	    _loaders = new Dictionary();
	}

	public static function getSprite(context:Context, name:String):Sprite {
	    var result:Sprite = new Sprite(context);

	    if (_assets[name]) {
		result.setTexture(_assets[name]);
	    }
	    else {
		addWaitingSprite(name, result);
	    }
	    return result;
	}

	private static function addWaitingSprite(name:String, sprite:Sprite):void {
	    if (!_waitingSprites[name]) {
		_waitingSprites[name] = new Vector.<Sprite>();
	    }

	    _waitingSprites[name].push(sprite);

	    if (!_loaders[name]) {
		var loader:Loader = new Loader();
		loader.name = name;
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAssetLoaded);
		_loaders[name] = loader;
		loader.load(new URLRequest("assets/" + name));
	    }
	}

	private static function onAssetLoaded(e:Event):void {
	    var bd:BitmapData = (e.target.content as Bitmap).bitmapData;
	    var name:String = (e.currentTarget.loader as Loader).name;

	    for (var i:int = 0; i < _waitingSprites[name].length; ++i) {
		_waitingSprites[name][i].setTexture(bd);
	    }
	}
    };
}