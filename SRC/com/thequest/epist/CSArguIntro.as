package com.thequest.epist {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.argu.*;
	import com.thequest.epist.Translator;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CSArguIntro extends ContentScreen {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _mgr:NavManager;
		private var _translator:Translator;
		private var _btns:Array;
		private var _btnsContainer:Sprite;
		private var _loadArtLite:XMLLiteLoader;
		private var _baseUrl:BaseUrl;
		//
		public var sommaire_tf:TextField;
		public var title_fr:MovieClip;
		public var title_en:MovieClip;
		//--------------------------------------------------
		//
		//		Contstructor
		//
		//--------------------------------------------------
		public function CSArguIntro() {
			_trace = SuperTrace.getTrace();
			_baseUrl = BaseUrl.getInstance();
			_context = ContentScreen.ARGU;
			_mgr = NavManager.getMgr();
			_translator = Translator.getInstance();
			sommaire_tf.text = _translator.translate("sommaire");
			_loadArtLite = new XMLLiteLoader();
			_loadArtLite.addEventListener(Event.COMPLETE, _articlesLoaded);
			_loadArtLite.load(_baseUrl.BASE+"appdata/" + _translator.language + "/articles.xml");
			//
			title_en.visible = false;
			title_fr.visible = false;
			this["title_" + _translator.language].visible = true;
			this.addChild(this["title_" + _translator.language])
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		
		private function _articlesLoaded(evt:Event) {
			_trace.debug("CSArguIntro._articlesLoaded");
			_mgr.init(_loadArtLite.xml);
			_createElements();
		}
		
		private function _createElements() {
			var elts:Array = _mgr.getArticles();
			var i:int;
			var N:int = elts.length;
			_trace.debug("_createElements, N : " + N);
			_btnsContainer = new Sprite();
			_btnsContainer.x = 650;
			_btnsContainer.y = 500;
			this.addChild(_btnsContainer);
			_btns = new Array();
			
			for (i = 0; i < N; i++) {
				var btn:EBArticleIntro = new EBArticleIntro(elts[i]);
				btn.setPosition(new Point(0, i * 20));
				btn.addEventListener(MouseEvent.MOUSE_OVER, _btnOver);
				btn.addEventListener(MouseEvent.MOUSE_OUT, _btnOut);
				btn.addEventListener(MouseEvent.CLICK, _btnClick);
				_btnsContainer.addChild(btn);
				_btns.push(btn);
			}
		}
		
		private function _btnOver(evt:MouseEvent) {
			var btn:ElementButton = evt.target as ElementButton;
			btn.rollOver();
		}
		
		private function _btnOut(evt:MouseEvent) {
			var btn:ElementButton = evt.target as ElementButton;
			btn.rollOut();
		}
		
		private function _btnClick(evt:MouseEvent) {
			var btn:ElementButton = evt.target as ElementButton;
			_trace.debug("CSArguIntro._btnClick : " + btn.elementData.id);
			_appNav.subNavId = btn.elementData.id;
			_appNav.change(AppNav.CS_ARGU_BROWSE);
		}
		
		
	}
	
}