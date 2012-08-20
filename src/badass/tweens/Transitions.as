package badass.tweens {
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class Transitions {
		public static const LINEAR:String = "LINEAR";
		public static const EASE_IN:String = "EASE_IN";
		public static const EASE_OUT:String = "EASE_OUT";
		public static const EASE_IN_OUT:String = "EASE_IN_OUT";
		public static const EASE_OUT_IN:String = "EASE_OUT_IN";
		public static const EASE_IN_BACK:String = "EASE_IN_BACK";
		public static const EASE_OUT_BACK:String = "EASE_OUT_BACK";
		public static const EASE_IN_OUT_BACK:String = "EASE_IN_OUT_BACK";
		public static const EASE_OUT_IN_BACK:String = "EASE_OUT_IN_BACK";
		public static const EASE_IN_ELASTIC:String = "EASE_IN_ELASTIC";
		public static const EASE_OUT_ELASTIC:String = "EASE_OUT_ELASTIC";
		public static const EASE_IN_OUT_ELASTIC:String = "EASE_IN_OUT_ELASTIC";
		public static const EASE_OUT_IN_ELASTIC:String = "EASE_OUT_IN_ELASTIC";
		public static const EASE_IN_BOUNCE:String = "EASE_IN_BOUNCE";
		public static const EASE_OUT_BOUNCE:String = "EASE_OUT_BOUNCE";
		public static const EASE_IN_OUT_BOUNCE:String = "EASE_IN_OUT_BOUNCE";
		public static const EASE_OUT_IN_BOUNCE:String = "EASE_OUT_IN_BOUNCE";
		
		private static var _transitions:Dictionary;
		
		public static function getTransition(name:String):Function {
			if (_transitions == null) {
				createTransitions();
			}
			
			return _transitions[name];
		}
		
		private static function createTransitions():void {
			_transitions = new Dictionary();
			
			_transitions[LINEAR] = linear;
			_transitions[EASE_IN] = easeIn;
			_transitions[EASE_OUT] = easeOut;
			_transitions[EASE_IN_OUT] = easeInOut;
			_transitions[EASE_OUT_IN] = easeOutIn;
			_transitions[EASE_IN_BACK] = easeInBack;
			_transitions[EASE_OUT_BACK] = easeOutBack;
			_transitions[EASE_IN_OUT_BACK] = easeInOutBack;
			_transitions[EASE_OUT_IN_BACK] = easeOutInBack;
			_transitions[EASE_IN_ELASTIC] = easeInElastic;
			_transitions[EASE_OUT_ELASTIC] = easeOutElastic;
			_transitions[EASE_IN_OUT_ELASTIC] = easeInOutElastic;
			_transitions[EASE_OUT_IN_ELASTIC] = easeOutInElastic;
			_transitions[EASE_IN_BOUNCE] = easeInBounce;
			_transitions[EASE_OUT_BOUNCE] = easeOutBounce;
			_transitions[EASE_IN_OUT_BOUNCE] = easeInOutBounce;
			_transitions[EASE_OUT_IN_BOUNCE] = easeOutInBounce;
		}
		
		// transition functions
		
		private static function linear(ratio:Number):Number {
			return ratio;
		}
		
		private static function easeIn(ratio:Number):Number {
			return ratio * ratio * ratio;
		}
		
		private static function easeOut(ratio:Number):Number {
			var invRatio:Number = ratio - 1.0;
			return invRatio * invRatio * invRatio + 1;
		}
		
		private static function easeInOut(ratio:Number):Number {
			return easeCombined(easeIn, easeOut, ratio);
		}
		
		private static function easeOutIn(ratio:Number):Number {
			return easeCombined(easeOut, easeIn, ratio);
		}
		
		private static function easeInBack(ratio:Number):Number {
			var s:Number = 1.70158;
			return Math.pow(ratio, 2) * ((s + 1.0) * ratio - s);
		}
		
		private static function easeOutBack(ratio:Number):Number {
			var invRatio:Number = ratio - 1.0;
			var s:Number = 1.70158;
			return Math.pow(invRatio, 2) * ((s + 1.0) * invRatio + s) + 1.0;
		}
		
		private static function easeInOutBack(ratio:Number):Number {
			return easeCombined(easeInBack, easeOutBack, ratio);
		}
		
		private static function easeOutInBack(ratio:Number):Number {
			return easeCombined(easeOutBack, easeInBack, ratio);
		}
		
		private static function easeInElastic(ratio:Number):Number {
			if (ratio == 0 || ratio == 1) {
				return ratio;
			}
			else {
				var p:Number = 0.3;
				var s:Number = p / 4.0;
				var invRatio:Number = ratio - 1;
				return -1.0 * Math.pow(2.0, 10.0 * invRatio) * Math.sin((invRatio - s) * (2.0 * Math.PI) / p);
			}
		}
		
		private static function easeOutElastic(ratio:Number):Number {
			if (ratio == 0 || ratio == 1) {
				return ratio;
			}
			else {
				var p:Number = 0.3;
				var s:Number = p / 4.0;
				return Math.pow(2.0, -10.0 * ratio) * Math.sin((ratio - s) * (2.0 * Math.PI) / p) + 1;
			}
		}
		
		private static function easeInOutElastic(ratio:Number):Number {
			return easeCombined(easeInElastic, easeOutElastic, ratio);
		}
		
		private static function easeOutInElastic(ratio:Number):Number {
			return easeCombined(easeOutElastic, easeInElastic, ratio);
		}
		
		private static function easeInBounce(ratio:Number):Number {
			return 1.0 - easeOutBounce(1.0 - ratio);
		}
		
		private static function easeOutBounce(ratio:Number):Number {
			var s:Number = 7.5625;
			var p:Number = 2.75;
			var l:Number;
			if (ratio < (1.0 / p)) {
				l = s * Math.pow(ratio, 2);
			} else {
				if (ratio < (2.0 / p)) {
					ratio -= 1.5 / p;
					l = s * Math.pow(ratio, 2) + 0.75;
				} else {
					if (ratio < 2.5 / p) {
						ratio -= 2.25 / p;
						l = s * Math.pow(ratio, 2) + 0.9375;
					} else {
						ratio -= 2.625 / p;
						l = s * Math.pow(ratio, 2) + 0.984375;
					}
				}
			}
			return l;
		}
		
		private static function easeInOutBounce(ratio:Number):Number {
			return easeCombined(easeInBounce, easeOutBounce, ratio);
		}
		
		private static function easeOutInBounce(ratio:Number):Number {
			return easeCombined(easeOutBounce, easeInBounce, ratio);
		}
		
		private static function easeCombined(startFunc:Function, endFunc:Function, ratio:Number):Number {
			if (ratio < 0.5)
				return 0.5 * startFunc(ratio * 2.0);
			else
				return 0.5 * endFunc((ratio - 0.5) * 2.0) + 0.5;
		}
	
	}

}