package com.thequest.epist.editor {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author nlgd
	 */
	public class AlertPrompt extends Sprite {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		public static const ACCEPT:String = "acceptAction";
		public static const CANCEL:String = "cancelAction";
		//
		private static var _instance:AlertPrompt;
		//
		private var _trace:SuperTrace;
		private var _bg:Sprite;
		//
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():AlertPrompt {
			if (_instance == null) {
				_instance = new AlertPrompt(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function AlertPrompt(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use AlertPrompt.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello AlertPrompt !");
				_bg = new Sprite();
				_bg.graphics.beginFill(0x000000, 0.5);
				_bg.graphics.drawRect(0, 0, 1024, 768);
				_bg.graphics.endFill();
				this.addChild(_bg);
				this.visible = false;
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		
		public function newAlert(msg:String, acceptLabel:String = "OK", cancelLabel:String = ""):AlertPopup {
			var alert:AlertPopup = new AlertPopup(msg, acceptLabel, cancelLabel);
			alert.addEventListener(Event.CLOSE, _alertClose, false, 0, true);
			alert.x = 402;
			alert.y = 340;
			this.addChild(alert);
			this.visible = true;
			return alert;
		}
		
		private function _alertClose(evt:Event) {
			var alert:AlertPopup = evt.target as AlertPopup;
			if (this.contains(alert)) {
				this.removeChild(alert);
			}
			alert = null;
			this.visible = false;
		}
	}
	
}

internal class SingletonBlocker {}