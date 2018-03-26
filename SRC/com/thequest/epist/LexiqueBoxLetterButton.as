package com.thequest.epist {
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class LexiqueBoxLetterButton extends Sprite {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _label:String;
		//
		public var label_tf:TextField;
		public var bg:MovieClip;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function LexiqueBoxLetterButton(p_label:String) {
			_label = p_label;
			label_tf.text = p_label;
			bg.visible = false;
			//this.mouseEnabled = true;
			this.buttonMode = true;
			this.useHandCursor = true;
			this.mouseChildren = false;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 */
		public function btnOver() {
			Tweener.removeTweens(this.bg);
			Tweener.addTween(this.bg, { alpha:1, time:0.3, transition:"easeOutQuart" } );
		}
		/**
		 * 
		 */
		public function btnOut() {
			Tweener.removeTweens(this.bg);
			Tweener.addTween(this.bg, { alpha:0, time:0.3, transition:"easeOutQuart" } );
		}
		/**
		 * Renvoi la lettre 
		 */
		public function get letter():String {
			return _label;
		}
		
		public function setActive() {
			this.bg.visible = true;
		}
		
		public function setNormal() {
			this.bg.visible = false;
		}
		
	}
	
}