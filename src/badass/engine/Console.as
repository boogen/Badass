package badass.engine {
    import badass.engine.HAlign;
    import badass.engine.Quad;
    import badass.engine.TextField;
    import badass.events.Touch;
    import badass.events.TouchEvent;
    import badass.events.TouchPhase;
	/**
     * ...
     * @author Marcin Wojteczko
     */
    public class Console extends Quad
    {
        public var fps:TextField;
        public var memory:TextField;
        public var logs:Vector.<String>;
        public var logger:TextField;
        public function Console()
        {
            super(80, 60, 0);
            alpha = 0.3;
            fps = new TextField(100, 30, "fps", "system_white");
            fps.hAlign = HAlign.LEFT;
            addChild(fps);

            memory = new TextField(100, 30, "mem", "system_white");
            memory.hAlign = HAlign.LEFT;
            memory.y = 20;
            addChild(memory);

            logs = new Vector.<String>();
            logger = new TextField(670, 80, "logger", "system_white");
            logger.x = 80;
            addEventListener(TouchEvent.TOUCH, touch);
        }

        private function touch(e:TouchEvent):void
        {
            var touch:Touch = e.getTouch(e.currentTarget as DisplayObject);
            if (touch.phase == TouchPhase.BEGAN)
            {
                if (logger && logger.parent)
                {
                    logger.parent.removeChild(logger);
                    width = 80
                }
                else
                {
                    addChild(logger);
                    width = 1000;
                }
            }
        }
        public function log(value:String):void
        {
            if (logs.length >= 2)
                logs.shift();
            logs.push(value);
            logger.text = "";
            for (var i:int; i < logs.length; i++) {
                logger.text += logs[i] + " ***** ";
            }
        }

    }

}
