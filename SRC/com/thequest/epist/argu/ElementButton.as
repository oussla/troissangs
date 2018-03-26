package com.thequest.epist.argu {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.ElementData;
	import com.thequest.epist.Translator;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.StyleSheet;
	import com.thequest.epist.BasicFormat;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class ElementButton extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		protected var _trace:SuperTrace;
		protected var _ed:ElementData;
		protected var _maxLabelLength:int = 0;
		protected var _pos:Point;
		protected var _normalColor:int = 0x7D7D7D;
		protected var _overColor:int = 0xFFFFFF;
		protected var _activeColor:int = 0xFFCC40;
		protected var _yMargin:Number = 0;
		public var label_tf:TextField;
		//FFCC40
		private var _style:BasicFormat;
		private var _css:StyleSheet;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function ElementButton(p_ed:ElementData) {
			_ed = p_ed;
			_trace = SuperTrace.getTrace();
			if(_ed.activeLink) {
				this.mouseChildren = false;
				this.buttonMode = true;
				this.useHandCursor = true;
			} else {
				_yMargin = 14;
			}
			label_tf.autoSize = TextFieldAutoSize.LEFT;
			_style = BasicFormat.getInstance();
			_css = _style.getBasicCSS();
			label_tf.styleSheet = _css;
			this.setLabel(_ed.title);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function setLabel(p_label:String) {
			if (!p_label || p_label.length == 0) {
				p_label = Translator.getInstance().translate("sans titre");
			}
			p_label = _style.transformItaTags(p_label)
			label_tf.htmlText = p_label;
			//trace("ElementButton -> setLabel : " + p_label);
		}
		
		public function setPosition(p_pos:Point) {
			_pos = p_pos;
			this.x = _pos.x;
			this.y = _pos.y;
		}
		
		public function setActive() {
			Tweener.removeTweens(this.label_tf);
			Tweener.addTween(this.label_tf, {_color:_activeColor, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function setNormal() {
			Tweener.removeTweens(this.label_tf);
			Tweener.addTween(this.label_tf, {_color:null, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function rollOver() {
			Tweener.removeTweens(this.label_tf);
			Tweener.addTween(this.label_tf, {_color:_overColor, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function rollOut() {
			Tweener.removeTweens(this.label_tf);
			Tweener.addTween(this.label_tf, {_color:null, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function get elementData():ElementData {
			return _ed;
		}
		
		public function get yMargin():Number {
			return _yMargin;
		}
		
	}
	
}