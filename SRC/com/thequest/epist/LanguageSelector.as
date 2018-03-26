package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class LanguageSelector extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _language:String;
		//
		public var fr_ct:SimpleButton;
		public var en_ct:SimpleButton;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function LanguageSelector() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello LanguageSelector !");
			
			fr_ct.addEventListener(MouseEvent.CLICK, function(evt:Event) {
				_change("fr");
			});
			en_ct.addEventListener(MouseEvent.CLICK, function(evt:Event) {
				_change("en");
			});
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 * @param	newLang
		 */
		private function _change(newLang:String) {
			_language = newLang;
			this.gotoAndPlay("hide");
			// Diffuse l'évènement CHANGE après un petit délai...
			var timer:Timer = new Timer(500, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(evt:TimerEvent) { 
				dispatchEvent(new Event(Event.CHANGE));
			} );
			timer.start();
		}
		/**
		 * Renvoi la langue sélectionnée
		 */
		public function get language():String {
			return _language;
		}
	}
	
}