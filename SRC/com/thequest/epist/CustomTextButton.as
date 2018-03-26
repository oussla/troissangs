package com.thequest.epist {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.ElementData;
	import com.thequest.epist.Translator;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.StyleSheet;
	import com.thequest.epist.BasicFormat;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CustomTextButton extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		protected var _trace:SuperTrace;
		protected var _pos:Point;
		protected var _normalColor:int = 0x7D7D7D;
		protected var _overColor:int = 0xFFFFFF;
		protected var _activeColor:int = 0xFFCC40;
		protected var _isActive:Boolean = false;
		protected var _isEnabled:Boolean = false;
		private var _style:BasicFormat;
		private var _css:StyleSheet;
		public var label_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function CustomTextButton(p_label:String, p_align:String = TextFieldAutoSize.LEFT, p_nColor:int = 0x7D7D7D, p_oColor:int = 0xFFFFFF, p_aColor:int = 0xFFCC40) {
			_trace = SuperTrace.getTrace();
			
			_normalColor = p_nColor;
			_overColor = p_oColor;
			_activeColor = p_aColor;
			
			label_tf.autoSize = TextFieldAutoSize.LEFT;
			_style = BasicFormat.getInstance();
			_css = _style.getBasicCSS();
			label_tf.styleSheet = _css;
			this.setLabel(p_label);
			
			this.enable();
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
		}
		
		public function enable() {
			if (!_isEnabled) {
				_isEnabled = true;
				this.mouseChildren = false;
				this.buttonMode = true;
				this.useHandCursor = true;
				this.addEventListener(MouseEvent.MOUSE_OVER, rollOver);
				this.addEventListener(MouseEvent.MOUSE_OUT, rollOut);
			}
		}
		
		public function disable() {
			_isEnabled = false;
			this.mouseChildren = false;
			this.buttonMode = false;
			this.useHandCursor = false;
			this.removeEventListener(MouseEvent.MOUSE_OVER, rollOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, rollOut);
			Tweener.removeTweens(this.label_tf);
			Tweener.addTween(this.label_tf, {_color:0x00FF00, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function setPosition(p_pos:Point) {
			_pos = p_pos;
			this.x = _pos.x;
			this.y = _pos.y;
		}
		
		public function setActive() {
			_isActive = true;
			Tweener.removeTweens(this.label_tf);
			Tweener.addTween(this.label_tf, {_color:_activeColor, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function setNormal() {
			_isActive = false;
			Tweener.removeTweens(this.label_tf);
			Tweener.addTween(this.label_tf, {_color:null, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function rollOver(evt:MouseEvent = null) {
			if(!_isActive) {
				Tweener.removeTweens(this.label_tf);
				Tweener.addTween(this.label_tf, { _color:_overColor, time:0.3, transition:"easeOutQuart" } );
			}
		}
		
		public function rollOut(evt:MouseEvent = null) {
			if(!_isActive) {
				Tweener.removeTweens(this.label_tf);
				Tweener.addTween(this.label_tf, { _color:null, time:0.3, transition:"easeOutQuart" } );
			}
		}
		
		
				
	}
	
}