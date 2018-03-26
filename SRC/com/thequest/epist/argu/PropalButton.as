package com.thequest.epist.argu {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.EDPropal;
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class PropalButton extends ElementButton {
		
		public function PropalButton(p_ed:EDPropal) {
			super(p_ed);
			label_tf.text = (_ed as EDPropal).P;
			label_tf.width = label_tf.textWidth;
			_normalColor = 0xc1c1c1;
			_overColor = 0xffffff;
			_activeColor = 0xffc400;
			
		}
		
		public function traceSeparation() {
			var posX:Number = 45;
			this.graphics.moveTo(posX, 0);
			this.graphics.lineStyle(1, 0x7C631D);
			this.graphics.lineTo(posX, 20);
		}
		
	}
	
}