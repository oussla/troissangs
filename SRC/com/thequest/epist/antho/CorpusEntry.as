package com.thequest.epist.antho {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.Translator;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CorpusEntry extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		protected var _translator:Translator;
		protected var _baseName:String = "";
		protected var _corpusId:int;
		protected var _trace:SuperTrace;
		protected var _repBrowser:RepBrowser;
		protected var _searchWindow:SearchWindow;
		protected var _descMask:Sprite;
		protected var _activeMask:Sprite;
		
		protected var _decors:CorpusDecors;
		//
		public var active_mc:MovieClip;
		public var desc_tf:TextField;
		public var title_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function CorpusEntry() {
			_trace = SuperTrace.getTrace();
			_translator = Translator.getInstance();
			_repBrowser = RepBrowser.getInstance();
			_searchWindow = SearchWindow.getInstance();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 * @param	p_baseName
		 */
		public function init(p_baseName:String, p_corpusId:int ) {
			_baseName = p_baseName;
			_corpusId = p_corpusId;
			this.active_mc.visible = false;
			//this.active_mc.alpha = 0;
			
			_activeMask = new Sprite();
			_activeMask.graphics.beginFill(0x00FF00);
			_activeMask.graphics.drawRect(0, 0, 201, 344);
			_activeMask.graphics.endFill();
			//_activeMask.scaleY = 0;
			_activeMask.y = 51;
			this.addChild(_activeMask);
			active_mc.mask = _activeMask;
			
			this.title_tf.text = _translator.translate(_baseName + "_title").toUpperCase();
			this.desc_tf.text = _translator.translate(_baseName + "_desc");
			this.active_mc.access_browse_tf.text = _translator.translate("corpus_access_browse").toUpperCase();
			this.active_mc.access_keyword_tf.text = _translator.translate("corpus_access_keyword").toUpperCase();
			
			this.addEventListener(MouseEvent.MOUSE_OVER, _rollOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, _rollOut);
			
			this.active_mc.access_browse_ct.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_repBrowser.openByCorpusId(_corpusId);
			} );
			this.active_mc.access_keyword_ct.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_searchWindow.openByCorpusId(_corpusId);
			} );
			
			this.active_mc.access_keyword_ct.addEventListener(MouseEvent.ROLL_OVER, function(evt:MouseEvent) { 
				active_mc.access_keyword_tf.textColor = 0xFFFFFF;
			} );
			this.active_mc.access_keyword_ct.addEventListener(MouseEvent.ROLL_OUT, function(evt:MouseEvent) { 
				active_mc.access_keyword_tf.textColor = 0xCCCCCC;
			} );
			this.active_mc.access_browse_ct.addEventListener(MouseEvent.ROLL_OVER, function(evt:MouseEvent) { 
				active_mc.access_browse_tf.textColor = 0xFFFFFF;
			} );
			this.active_mc.access_browse_ct.addEventListener(MouseEvent.ROLL_OUT, function(evt:MouseEvent) { 
				active_mc.access_browse_tf.textColor = 0xCCCCCC;
			} );
		}
		/**
		 * 
		 * @param	p_decors
		 */
		public function setDecors(p_decors:CorpusDecors) {
			_decors = p_decors;
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _rollOver(evt:MouseEvent) {
			this.desc_tf.visible = false;
			this.active_mc.visible = true;
			//Tweener.addTween(active_mc, { alpha:1, time:0.3, transition:"easeInOutQuart" } );
			_decors.showCorpus(_corpusId);
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _rollOut(evt:MouseEvent) {
			this.desc_tf.visible = true;
			this.active_mc.visible = false;
			//Tweener.addTween(active_mc, { alpha:0, time:0.3, transition:"easeOutQuart", onComplete:function() { active_mc.visible = false; } } );
			_decors.backToNormal();
		}
		
	}
	
}