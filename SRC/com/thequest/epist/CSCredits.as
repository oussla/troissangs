package com.thequest.epist {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CSCredits extends ContentScreen {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _activeContent:MovieClip;
		private var _translator:Translator;
		//
		public var langSelector:LanguageSelector;
		public var creditsContent_fr:MovieClip;
		public var creditsContent_en:MovieClip;
		
		public var page1_ct:SimpleButton;
		public var page2_ct:SimpleButton;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function CSCredits() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello CSCredits !");
			_translator = Translator.getInstance();
			//
			creditsContent_en.visible = false;
			creditsContent_fr.visible = false;
			_activeContent = this["creditsContent_" + _translator.language];
			_activeContent.y = 10;
			_activeContent.visible = true;
			//this.addChild(_activeContent);
			//
			//Tweener.addTween(_activeContent, { y: -1500, time:60, transition:"linear", onComplete:_scrollEnd } );
			page1_ct.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				//_activeContent.y = 10;
				Tweener.removeTweens(_activeContent);
				Tweener.addTween(_activeContent, { y: 10, time:1, transition:"easeInOutQuart" } );
			} );
			page2_ct.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				//_activeContent.y = -700;
				Tweener.removeTweens(_activeContent);
				Tweener.addTween(_activeContent, { y: -700, time:1, transition:"easeInOutQuart" } );
			} );
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private function _scrollEnd() {
			_trace.debug("CSCredits._scrollEnd");
		}
	}
	
}