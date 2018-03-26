package com.thequest.epist.argu {
	import com.thequest.epist.ElementData;
	import flash.display.MovieClip;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class EBArticle extends ElementButton {
		
		public function EBArticle(p_ed:ElementData) {
			super(p_ed);
			//_overColor = 0xFFCC40;
			label_tf.autoSize = TextFieldAutoSize.RIGHT;
		}
		
	}
	
}