package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class  VisualLoad extends MovieClip	{
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _instance:VisualLoad;
		private var _trace:SuperTrace;
		public var spinner_mc:MovieClip;
		
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():VisualLoad {
			if (_instance == null) {
				_instance = new VisualLoad(new SingletonBlocker());
			}
			return _instance;
		}
		
		public function VisualLoad(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use VisualLoad.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello VisualLoader !");
				this.visible = false;
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function show() {
			this.visible = true;
			this.addEventListener(Event.ENTER_FRAME, _enterFrame);
		}
		
		public function hide() {
			this.visible = false;
			this.removeEventListener(Event.ENTER_FRAME, _enterFrame);
		}
		
		private function _enterFrame(evt:Event) {
			this.spinner_mc.rotation += 5;
		}
		
		
	}
	
}

internal class SingletonBlocker {}