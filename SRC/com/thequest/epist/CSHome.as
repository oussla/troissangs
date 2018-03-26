package com.thequest.epist {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CSHome extends ContentScreen {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _translator:Translator;
		//
		public var argu_ct:SimpleButton;
		public var antho_ct:SimpleButton;
		public var argu_tf:TextField;
		public var antho_tf:TextField;
		public var argu_bg:MovieClip;
		public var antho_bg:MovieClip;
		public var langSelector:LanguageSelector;
		public var title_en:MovieClip;
		public var title_fr:MovieClip;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function CSHome() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello CSHome !");
			
			_translator = Translator.getInstance();
			
			argu_tf.htmlText = _translator.translate("argu");
			antho_tf.htmlText = _translator.translate("antho");
			
			argu_ct.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_appNav.change(AppNav.CS_ARGU_INTRO);
			} );
			argu_ct.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) {
				_btnOver(argu_bg);
			});
			argu_ct.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) {
				_btnOut(argu_bg);
			});
			
			
			antho_ct.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_appNav.change(AppNav.CS_ANTHO_INTRO);
			} );
			antho_ct.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) {
				_btnOver(antho_bg);
			});
			antho_ct.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) {
				_btnOut(antho_bg);
			});
			
			title_en.visible = false;
			title_fr.visible = false;
			this["title_" + _translator.language].visible = true;
			this.addChild(this["title_" + _translator.language])
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private function _btnOver(bg:MovieClip) {
			Tweener.removeTweens(bg);
			Tweener.addTween(bg, {alpha:0.8, time:0.3, transition:"easeOutQuart" } );
		}
		
		private function _btnOut(bg:MovieClip) {
			Tweener.removeTweens(bg);
			Tweener.addTween(bg, {alpha:0.45, time:0.3, transition:"easeOutQuart" } );
		}
	}
	
}
