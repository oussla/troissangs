package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.SimpleButton;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class LangButton extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _lang:String;
		//
		public var lang_tf:TextField;
		public var ct:SimpleButton;
		public var separation:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function LangButton(lang:String) {
			_trace = SuperTrace.getTrace();
			_lang = lang;
			//_trace.debug("Hello LangButton "+ _lang+" !");
			var display:String;
			switch(_lang) {
				case "to":
					display = "Toraja";
					break;
				case "id":
					display = "Indonesia";
					break;
				case "en":
					display = "English";
					break;
				case "fr":
					display = "Français";
					break;

			}
			this.lang_tf.text = display.toUpperCase();
			this.lang_tf.textColor = 0xB47B0D;
			this.lang_tf.autoSize = TextFieldAutoSize.LEFT;
			this.lang_tf.width = lang_tf.textWidth;
			this.separation.x = lang_tf.x + lang_tf.textWidth+5;
			this.ct.width = lang_tf.width;
			this.ct.addEventListener(MouseEvent.CLICK, btnClick);
			this.name = "_btn_" + lang;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------

		public function btnClick(evt:MouseEvent) {
			//_trace.debug("LangButton.btnClick");
			this.dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		public function get lang():String {
			return _lang;
		}
		
		public function setInactive() {
			//_trace.debug("LangButton.setInactive");
			this.ct.visible = false;
			this.lang_tf.textColor = 0x626260;
		}
		
		public function setActive() {
			this.ct.visible = true;
			this.lang_tf.textColor = 0xB47B0D;
		}
	}
	
}