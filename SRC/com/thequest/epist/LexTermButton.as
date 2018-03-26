package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class LexTermButton extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _ltData:LexTermData;
		//
		public var bg:MovieClip;
		public var label_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function LexTermButton(p_ltData:LexTermData) {
			_ltData = p_ltData;
			label_tf.text = _ltData.term.toUpperCase();
			bg.visible = false;
			this.mouseChildren = false;
			this.buttonMode = true;
			this.useHandCursor = true;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function btnOver() {
			this.bg.visible = true;
		}
		
		public function btnOut() {
			this.bg.visible = false;
		}
		/**
		 * Renvoi l'objet de données du bouton
		 */
		public function get ltData():LexTermData {
			return _ltData;
		}
		
	}
	
}