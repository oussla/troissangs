package com.thequest.epist {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.antho.*;
	import com.thequest.epist.Translator;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CSAnthoIntro extends ContentScreen {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _soundMgr:SoundManager;
		private var _translator:Translator;
		private var _xmlLoader:XMLLiteLoader;
		private var _repBrowser:RepBrowser;
		private var _searchWindow:SearchWindow;
		private var _usViewer:USViewer;
		private var _sunsetEntry:CorpusEntrySunset;
		private var _sunriseEntry:CorpusEntrySunrise;
		private var _listenList:Listenning;
		private var _decors:CorpusDecors;
		private var _lastLang:String;
		private var _baseUrl:BaseUrl;
		//
		public var title_en:MovieClip;
		public var title_fr:MovieClip;
		//--------------------------------------------------
		//
		//		Contstructor
		//
		//--------------------------------------------------
		public function CSAnthoIntro() {
			_trace = SuperTrace.getTrace();
			_context = ContentScreen.ANTHO;
			_mgr = AnthoManager.getInstance();
			_translator = Translator.getInstance();
			_soundMgr = SoundManager.getInstance();
			_baseUrl = BaseUrl.getInstance();
			_xmlLoader = new XMLLiteLoader();
			_xmlLoader.addEventListener(Event.COMPLETE, _xmlLoaded);
			_xmlLoader.load(_baseUrl.BASE + "appdata/" + _translator.language + "/anthologie.xml");
			//
			var _xmlLoader_ID:XMLLiteLoader = new XMLLiteLoader();
			_xmlLoader_ID.addEventListener(Event.COMPLETE, _xmlIDLoaded);
			_xmlLoader_ID.load(_baseUrl.BASE + "appdata/id/anthologie.xml");
			//
			var _xmlLoader_TO:XMLLiteLoader = new XMLLiteLoader();
			_xmlLoader_TO.addEventListener(Event.COMPLETE, _xmlTOLoaded);
			_xmlLoader_TO.load(_baseUrl.BASE + "appdata/to/anthologie.xml");
			//
			switch(_translator.language) {
				case "fr":
					_lastLang = "en";
					break;
				case "en":
					_lastLang = "fr";
					break;
			}
			var _xmlLoader_Last:XMLLiteLoader = new XMLLiteLoader();
			_xmlLoader_Last.addEventListener(Event.COMPLETE, _xmlLastLoaded);
			_xmlLoader_Last.load(_baseUrl.BASE + "appdata/"+ _lastLang + "/anthologie.xml");
			//
			_decors = new CorpusDecors();
			this.addChild(_decors);
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
		private function _xmlLoaded(evt:Event) {
			_trace.debug("CSAnthoIntro : le xml de l'anthologie est chargé.");
			// Initialise le AnthoManager en lui passant les données de la langue principale
			var ad:AnthoData = new AnthoData(_xmlLoader.xml, _translator.language);
			_mgr.init(ad);
			//
			_usViewer = new USViewer();
			//
			_repBrowser = RepBrowser.getInstance();
			_repBrowser.x = 72;
			//
			_searchWindow = SearchWindow.getInstance();
			_searchWindow.x = _repBrowser.x;
			//
			_sunsetEntry = new CorpusEntrySunset();
			_sunsetEntry.setDecors(_decors);
			_sunsetEntry.x = 454;
			_sunsetEntry.y = 370;
			this.addChild(_sunsetEntry);
			_sunriseEntry = new CorpusEntrySunrise();
			_sunriseEntry.setDecors(_decors);
			_sunriseEntry.x = 677;
			_sunriseEntry.y = 370;
			this.addChild(_sunriseEntry);
			//			
			_listenList = Listenning.getInstance();
			_listenList.x = 72;
			//_listenList.y = 50;
			//
			this.addChild(_usViewer);
			this.addChild(_listenList);
			this.addChild(_repBrowser);
			this.addChild(_searchWindow);
		}
		
		private function _xmlIDLoaded(evt:Event) {
			var loader:XMLLiteLoader = evt.target as XMLLiteLoader;
			var ad:AnthoData = new AnthoData(loader.xml, "id", "Bahasa");
			_mgr.addLanguage(ad);
		}
		
		private function _xmlTOLoaded(evt:Event) {
			var loader:XMLLiteLoader = evt.target as XMLLiteLoader;
			var ad:AnthoData = new AnthoData(loader.xml, "to", "Toraja");
			_mgr.addLanguage(ad);
		}
		
		private function _xmlLastLoaded(evt:Event) {
			var loader:XMLLiteLoader = evt.target as XMLLiteLoader;
			var langName:String;
			switch(_lastLang) {
				case "fr":
					langName = "French";
					break;
				case "en":
					langName = "English";
					break;				
			}
			var ad:AnthoData = new AnthoData(loader.xml, _lastLang, langName);
			_mgr.addLanguage(ad);
		}
		
	}
	
}