package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CSPreHome extends ContentScreen {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		//
		public var langSelector:LanguageSelector;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function CSPreHome() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello CSPreHome !");
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		
	}
	
}