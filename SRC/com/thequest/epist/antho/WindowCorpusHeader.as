package com.thequest.epist.antho {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.antho.AnthoManager;
	import com.thequest.epist.Translator;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class WindowCorpusHeader extends MovieClip	{
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _translator:Translator;
		private var _selectedCorpus:int;
		private var _sunsetLine:Sprite;
		private var _sunriseLine:Sprite;
		//
		public var sunset_tf:TextField;
		public var sunrise_tf:TextField;
		public var sunset_ct:SimpleButton;
		public var sunrise_ct:SimpleButton;
		public var sunset_bg:MovieClip;
		public var sunrise_bg:MovieClip;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function WindowCorpusHeader() {
			_trace = SuperTrace.getTrace();
			_translator = Translator.getInstance();
			_translator.addEventListener(Event.CHANGE, _changeLanguage);
			sunset_tf.text = _translator.translate("sunset_title").toUpperCase();
			sunrise_tf.text = _translator.translate("sunrise_title").toUpperCase();
			//
			_sunriseLine = new Sprite();
			_sunriseLine.y = 39;
			_sunriseLine.graphics.moveTo(0, 0);
			_sunriseLine.graphics.lineStyle(1, 0xC5894A);
			_sunriseLine.graphics.lineTo(855, 0);
			this.addChild(_sunriseLine);
			//
			_sunsetLine = new Sprite();
			_sunsetLine.y = 39;
			_sunsetLine.graphics.moveTo(0, 0);
			_sunsetLine.graphics.lineStyle(1, 0xE53426);
			_sunsetLine.graphics.lineTo(855, 0);
			this.addChild(_sunsetLine);
			//
			sunset_ct.visible = false;
			sunrise_ct.visible = false;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function activateMouseInteractions() {
			sunset_ct.visible = true;
			sunrise_ct.visible = true;
			//
			sunset_ct.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_corpusSelect(AnthoManager.COUCHANT);
			} );
			sunrise_ct.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_corpusSelect(AnthoManager.LEVANT);
			} );
			sunset_ct.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) {
				if(_selectedCorpus != AnthoManager.COUCHANT) {
					_changeToActive(sunset_bg, sunset_tf);
				}
			});
			sunset_ct.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) {
				if(_selectedCorpus != AnthoManager.COUCHANT) {
					_changeToNormal(sunset_bg, sunset_tf);
				}
			});
			sunrise_ct.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) {
				if(_selectedCorpus != AnthoManager.LEVANT) {
					_changeToActive(sunrise_bg, sunrise_tf);
				}
			});
			sunrise_ct.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) {
				if(_selectedCorpus != AnthoManager.LEVANT) {
					_changeToNormal(sunrise_bg, sunrise_tf);
				}
			});
		}
		/**
		 * 
		 * @param	cid
		 */
		private function _corpusSelect(cid:int) {
			_selectedCorpus = cid;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		/**
		 * 
		 * @param	bg
		 * @param	tf
		 * @param	line
		 */
		private function _changeToActive(bg:MovieClip, tf:TextField, line:Sprite = undefined) {
			//_trace.debug("_changeToActive");
			Tweener.addTween(bg, { alpha:1, time:0.3, transition:"easeOutQuart" } );
			Tweener.addTween(tf, { _color:0xFFFFFF, time:0.3, transition:"easeOutQuart" } );
			if(line) line.visible = true;
		}
		/**
		 * 
		 * @param	bg
		 * @param	tf
		 * @param	line
		 */
		private function _changeToNormal(bg:MovieClip, tf:TextField, line:Sprite = undefined) {
			//_trace.debug("_changeToNormal");
			Tweener.addTween(bg, { alpha:0, time:0.3, transition:"easeOutQuart" } );
			Tweener.addTween(tf, { _color:0x626262, time:0.3, transition:"easeOutQuart" } );
			if(line) line.visible = false;
		}
		/**
		 * Réagit au changement de langue diffusé par le Translator
		 * @param	evt
		 */
		private function _changeLanguage(evt:Event) {
			sunset_tf.text = _translator.translate("sunset_title").toUpperCase();
			sunrise_tf.text = _translator.translate("sunrise_title").toUpperCase();
		}
		/**
		 * 
		 * @param	cid
		 */
		public function setCorpus(cid:int) {
			_selectedCorpus = cid;
			var isSunset:Boolean;
			cid == AnthoManager.COUCHANT ? isSunset = true : isSunset = false;
			
			switch(cid) {
				case AnthoManager.COUCHANT: // Sunset.
					_changeToActive(sunset_bg, sunset_tf, _sunsetLine);
					_changeToNormal(sunrise_bg, sunrise_tf, _sunriseLine);
					break;
				case AnthoManager.LEVANT:
					_changeToActive(sunrise_bg, sunrise_tf, _sunriseLine);
					_changeToNormal(sunset_bg, sunset_tf, _sunsetLine);
					break;
			}
			
		}
		/**
		 * Retourne le corpus sélectionné
		 */
		public function get selectedCorpus():int {
			return _selectedCorpus;
		}
		
	}
	
}