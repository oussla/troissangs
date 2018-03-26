package com.thequest.epist.editor {
	import flash.display.Sprite;
	import fl.controls.Button;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class AlertPopup extends Sprite {
		
		public var message_tf:TextField;
		public var accept_btn:Button;
		public var cancel_btn:Button;
		
		public function AlertPopup(msg:String, acceptLabel:String = "OK", cancelLabel:String = "") {
			message_tf.text = msg;
			accept_btn.label = acceptLabel;
			if (cancelLabel) {
				cancel_btn.label = cancelLabel;
				cancel_btn.visible = true;
			} else {
				cancel_btn.visible = false;
			}
			accept_btn.addEventListener(MouseEvent.CLICK, function(evt:Event) { 
				dispatchEvent(new Event(AlertPrompt.ACCEPT));
				_close();
			} );
			cancel_btn.addEventListener(MouseEvent.CLICK, function(evt:Event) { 
				dispatchEvent(new Event(AlertPrompt.CANCEL));
				_close();
			} );
		}
		
		private function _close(evt:Event = null) {
			this.dispatchEvent(new Event(Event.CLOSE));
			this.visible = false;
		}
		
		
	}
	
}