package com.thequest.epist.argu {
	import com.thequest.epist.EDAntec;
	import com.thequest.epist.ElementData;
	import com.thequest.epist.Translator;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import com.thequest.epist.BasicFormat;
	import flash.text.StyleSheet;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class AntecButton extends MovieClip {
		
		private var _ed:EDAntec;
		private var _pos:Point;
		private var _active:Boolean = false;
		private var _style:BasicFormat;
		private var _css:StyleSheet;
		
		public var label_tf:TextField;
		public var active_mc:MovieClip;
		public var picto_link:MovieClip;
		
		public function AntecButton(p_ed:EDAntec) {
			_ed = p_ed;
			setLabel(_ed.title);
			this.mouseChildren = false;
			this.buttonMode = true;
			this.useHandCursor = true;
			active_mc.alpha = 0;
			if (_ed.type == EDAntec.TYPE_LIEN) {
				picto_link.visible = true;
				label_tf.x = 20;
			} else {
				picto_link.visible = false;
			}
		}
		
		public function setLabel(p_label:String) {
			_style = BasicFormat.getInstance();
			_css = _style.getBasicCSS();
			label_tf.styleSheet = _css;
			if (!p_label || p_label.length == 0) {
				p_label = "<i>(" + Translator.getInstance().translate("sans titre") + ")</i>";
			}
			label_tf.htmlText = _style.transformItaTags(p_label);
		}
		
		public function setPosition(p_pos:Point) {
			_pos = p_pos;
			this.x = _pos.x;
			this.y = _pos.y;
		}
		
		public function get elementData():EDAntec {
			return _ed;
		}
		
		public function setActive() {
			_active = true;
			active_mc.alpha = 1;
			
		}
		
		public function setNormal() {
			_active = false;
			active_mc.alpha = 0;
		}
		
		public function get active():Boolean {
			return _active;
		}
	}
	
}