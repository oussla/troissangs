package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.events.Event;
	import com.thequest.epist.NavEvent;
	
		public class USButton extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _usd:USData;
		public var label_tf:TextField;
		public var verses_tf:TextField;
		public var ct:SimpleButton;
		public var bg:MovieClip;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function USButton(usData:USData) {
			_trace = SuperTrace.getTrace();
			_mgr = AnthoManager.getInstance();
			//_trace.debug("Hello USButton!");
			_usd = usData;
			label_tf.htmlText = _usd.getBegin();
			label_tf.x = 90;
			bg.alpha = 0;
			this.ct.addEventListener(MouseEvent.CLICK, _openUs);
			this.ct.addEventListener(MouseEvent.MOUSE_OVER, _over);
			this.ct.addEventListener(MouseEvent.MOUSE_OUT, _out);
			//
			if (_usd.firstVerseNumber > 0) {
				if (_usd.firstVerseNumber == _usd.lastVerseNumber) {
					verses_tf.text = String(_usd.firstVerseNumber);
				} else {
					verses_tf.text = _usd.firstVerseNumber + " > " + _usd.lastVerseNumber;
				}
			}
		}
		
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------

		public function _openUs(evt:MouseEvent) {
			//_trace.debug("USButton._openUs");
			//_mgr.goToUS(_usd);
			this.dispatchEvent(new NavEvent(NavEvent.OPEN_US, true));
		}
		
		public function get usdata():USData {
			return _usd;
		}
		
		public function _over(evt:MouseEvent) {
			bg.alpha = 1;
		}
		
		public function _out(evt:MouseEvent) {
			bg.alpha = 0;
		}
	}
	
	
}