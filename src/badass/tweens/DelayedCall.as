package badass.tweens
{
    import badass.engine.EventDispatcher;
    import badass.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
	/**
     * ...
     * @author Marcin Wojteczko
     */
    public class DelayedCall extends Tween
    {
        private var currentTime:Number;
        private var args:Array;
        public function DelayedCall(onComplete:Function, delay:Number /*[s]*/, args:Array = null) {
            super(null, delay);
            _onComplete = onComplete;
            _onCompleteArgs = args;
        }
    }

}
