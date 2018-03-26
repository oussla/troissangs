package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class USLangMenuButton extends Sprite {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _format:TextFormat;
		private var _content_tf:TextField;
		private var _lang:String;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function USLangMenuButton(p_label:String, p_lang:String) {
			_trace = SuperTrace.getTrace();
		
			this.buttonMode = true;
			this.mouseChildren = false;
			this.useHandCursor = true;
			
			_lang = p_lang;
			
			var font:Font = new ImportedFontRegular();
			_format = new TextFormat();
			_format.font = font.fontName;
			_format.size = 12;
			_format.color = 0xB47B0D;
			//
			_content_tf = new TextField();
			_content_tf.x = 0;
			_content_tf.y = 0;
			_content_tf.width = 10;
			_content_tf.height = 19;
			_content_tf.antiAliasType = AntiAliasType.ADVANCED;
			_content_tf.autoSize = TextFieldAutoSize.LEFT;
			_content_tf.defaultTextFormat = _format;
			_content_tf.embedFonts = true;
			_content_tf.wordWrap = false;
			_content_tf.selectable = false;
			_content_tf.multiline = false;
			
			this.setLabel(p_label);
			
			this.addChild(_content_tf);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 * @param	p_label
		 */
		public function setLabel(p_label:String) {
			_content_tf.text = p_label;
		}
		
		public function setActive() {
			_trace.debug("btn " + this.lang + " setActive...");
		}
		
		public function setNormal() {
			_format.color = 0xB47B0D;
			_content_tf.defaultTextFormat = _format;
		}
		
		public function get lang():String {
			return _lang;
		}
		
	}
	
}