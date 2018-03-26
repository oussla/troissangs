package com.thequest.epist.argu {
	import com.thequest.epist.EDPropal;
	import com.thequest.epist.ElementData;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import com.thequest.epist.BasicFormat;
	import flash.text.StyleSheet;
	/**
	 * ...
	 * @author nlgd
	 */
	public class EBPropal extends ElementButton {
		
		public var level_tf:TextField;
		private var _style:BasicFormat;
		private var _css:StyleSheet;
		
		public function EBPropal(p_ed:EDPropal) {
			super(p_ed);
			/*
			_style = BasicFormat.getInstance();
			_css = _style.getBasicCSS();
			level_tf.styleSheet = _css;
			level_tf.htmlText = _style.transformItaTags(p_ed.P);*/
			
			level_tf.text = p_ed.P;
		}
	}
}