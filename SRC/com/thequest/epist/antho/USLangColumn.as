package com.thequest.epist.antho {
	
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.BasicFormat;
	import com.thequest.epist.NavEvent;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.display.SimpleButton;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class  USLangColumn extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _pos:Point;
		private var _btn_en, _btn_fr, _btn_in, _btn_to:LangButton;
		private var _containerBtn:Sprite;
		private var _lang:String;
		private var _btnArray:Array;
		private var _basicFormat:BasicFormat;
		private var _index:uint;
		//
		public var content_tf:TextField;
		public var plus_btn:SimpleButton;
		public var moins_btn:SimpleButton;
		public var close_btn:SimpleButton;
		public var bg:MovieClip;
		public var bgFirst:MovieClip;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function USLangColumn() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello USLangColumn !");
			
			_basicFormat = BasicFormat.getInstance();
			content_tf.styleSheet = _basicFormat.getBasicCSS();
			content_tf.autoSize = TextFieldAutoSize.LEFT;
			
			
			plus_btn.addEventListener(MouseEvent.CLICK, _add);
			close_btn.addEventListener(MouseEvent.CLICK, close);
			moins_btn.visible = false;
			
			//création des boutons de langues
			_containerBtn = new Sprite();
			_btn_en = new LangButton("en");
			_btn_fr = new LangButton("fr");
			_btn_in = new LangButton("id");
			_btn_to = new LangButton("to");
			
			//placement et affichage des boutons
			_btn_to.x = 0;
			_btn_in.x = _btn_to.x + _btn_to.width;
			_btn_en.x = _btn_in.x + _btn_in.width;
			_btn_fr.x = _btn_en.x + _btn_en.width;
			_btn_fr.separation.visible = false;
			
			_btnArray = new Array();
			_btnArray.push(_btn_to);
			_btnArray.push(_btn_in);
			_btnArray.push(_btn_en);
			_btnArray.push(_btn_fr);
			
			_containerBtn.addChild(_btn_en);
			_containerBtn.addChild(_btn_fr);
			_containerBtn.addChild(_btn_in);
			_containerBtn.addChild(_btn_to);
			_containerBtn.x = 30;
			_containerBtn.y = 698;
			this.addChild(_containerBtn);
			
			plus_btn.x = Math.round(_containerBtn.x + _containerBtn.width);
			
			bgFirst.visible = false;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Click sur le bouton d'ajout d'une langue
		 * @param	evt
		 */
		public function _add(evt:MouseEvent) {
			_trace.debug("USLangColumn._add");
			this.dispatchEvent(new NavEvent(NavEvent.US_ADD_LANG));
		}
		
		public function setContent(str:String, lang:String) {
			content_tf.htmlText = _basicFormat.transformItaTags(str);
			_lang = lang;
			//_trace.debug("USLangcolumn.setContent => _lang = " + lang);
			var btn:LangButton = _containerBtn.getChildByName("_btn_" + lang) as LangButton;
			btn.setInactive();
			
			var nbBtn:int = _btnArray.length;
			for (var i:int = 0; i < nbBtn; i++) {
				if (_btnArray[i] == btn)
					btn.setInactive();
				else
					_btnArray[i].setActive();
			}
		}
		/**
		 * 
		 * @param	p_pos
		 */
		public function setPosition(p_pos:Point) {
			_pos = p_pos;
			this.x = _pos.x;
			Tweener.addTween(this, { alpha:1, time:1, transition:"easeOutQuart" } );
		}
		/**
		 * Fermeture de la colonne
		 */
		public function close(evt:MouseEvent = null) {
			this.dispatchEvent(new Event(Event.CLOSE));
		}
		
		public function get lang():String {
			return _lang;
		}
	}
	
}