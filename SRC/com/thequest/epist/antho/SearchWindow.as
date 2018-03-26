package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.AscenseurCommand;
	import com.thequest.epist.NavEvent;
	import com.thequest.epist.Window;
	import com.thequest.epist.Windows;
	import com.thequest.tools.ascenseur.Ascenseur;
	import com.thequest.tools.scroller.Scroller;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class SearchWindow extends Window {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		//
		private static var _instance:SearchWindow;
		//
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _arboContainer:MovieClip;
		private var _arbos:Array;
		private var _sunsetAsc:Ascenseur;
		private var _sunriseAsc:Ascenseur;
		private var _sunsetAscCmd:AscenseurCommand;
		private var _sunriseAscCmd:AscenseurCommand;
		private var _sunAscs:Array;
		private var _maskArea:Rectangle;
		private var _activeRepBtn:RepButton;
		private var _results:Array;
		private var _results_mc:MovieClip;
		//
		public var corpusHeader:WindowCorpusHeader;
		public var searchString_tf:TextField;
		public var searchVerse_tf:TextField;
		public var info_tf:TextField;
		public var searchString_btn:SimpleButton;
		public var searchVerse_btn:SimpleButton;
		public var resultHead_tf:TextField;
		public var notice_tf:TextField;
		
		// Elements pour le scroll
		public var scrollMask:MovieClip;
		public var area:MovieClip;
		public var scrollbar:MovieClip;
		public var scrollUp_btn:SimpleButton;
		public var scrollDown_btn:SimpleButton;
		private var _sc:Scroller;
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():SearchWindow {
			if (_instance == null) {
				_instance = new SearchWindow(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function SearchWindow(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use SearchWindow.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello SearchWindow !");
				this._init();
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private function _init() {
			_mgr = AnthoManager.getInstance();
			// Ecoute les changements de langue
			_mgr.addEventListener(Event.CHANGE, _mgrChangeLanguage);
			
			title_tf.text = _translator.translate("recherche").toUpperCase();
			notice_tf.text = _translator.translate("search_notice");
			
			this._positionType = 1;
			this._windowHeight = 563;
			
			// Conteneur pour les deux arbos (levant / couchant)
			_arboContainer = new MovieClip();
			
			corpusHeader.addEventListener(Event.CHANGE, _corpusHeaderChange);
			corpusHeader.activateMouseInteractions();		
			
			// Champs de recherche
			searchString_tf.addEventListener(FocusEvent.FOCUS_IN, function(evt:Event) { 
				_trace.debug("searchString_tf.FOCUS_IN");
				if(searchString_tf.text == _translator.translate("search_keyword").toUpperCase()) searchString_tf.text = "";
			} );
			searchString_tf.addEventListener(FocusEvent.FOCUS_OUT, function(evt:Event) { 
				if(searchString_tf.text == "") searchString_tf.text = _translator.translate("search_keyword").toUpperCase();
			} );
			searchVerse_tf.addEventListener(FocusEvent.FOCUS_IN, function(evt:Event) { 
				if(searchVerse_tf.text == _translator.translate("search_verse").toUpperCase()) searchVerse_tf.text = "";
			} );
			searchVerse_tf.addEventListener(FocusEvent.FOCUS_OUT, function(evt:Event) { 
				if(searchVerse_tf.text == "") searchVerse_tf.text = _translator.translate("search_verse").toUpperCase();
			} );
			searchString_btn.addEventListener(MouseEvent.CLICK, _stringSearchHandler);
			searchVerse_btn.addEventListener(MouseEvent.CLICK, _verseSearchHandler);
			
			//
			_results_mc = new MovieClip();
			_results_mc.x = 360;
			_results_mc.y = 100;
			this.addChild(_results_mc);
			_results = new Array();
			//
			_versionInit();
		}
		
		/**
		 * Initialise tout ce qui est suceptible de changer avec la langue
		 */
		private function _versionInit() {
			_trace.debug("SearchWindow._versionInit();");
			title_tf.text = _translator.translate("recherche").toUpperCase();
			notice_tf.text = _translator.translate("search_notice");
			// Champs de recherche
			searchString_tf.text = _translator.translate("search_keyword").toUpperCase();
			searchVerse_tf.text = _translator.translate("search_verse").toUpperCase();
			// Met en place les deux arbos (levant / couchant)
			_arboContainer.x = 1;
			_arboContainer.y = 75;
			this.addChild(_arboContainer);
			
			_arbos = new Array();
			_arbos[AnthoManager.LEVANT] = new RepArbo(AnthoManager.LEVANT);
			_arbos[AnthoManager.COUCHANT] = new RepArbo(AnthoManager.COUCHANT);
			_arbos[AnthoManager.LEVANT].addEventListener(NavEvent.OPEN_US, _selectRep);
			_arbos[AnthoManager.COUCHANT].addEventListener(NavEvent.OPEN_US, _selectRep);
			
			_arboContainer.addChild(_arbos[AnthoManager.LEVANT]);
			_arboContainer.addChild(_arbos[AnthoManager.COUCHANT]);
			
			// Ecoute l'event OPEN sur tous les boutons de toutes les arbos
			_arboContainer.addEventListener(Event.OPEN, _repButtonOpening);
			
			// Un ascenseur pour chaque arborescence. Les ascenseurs et masques sont créés dans _arboContainer
			_maskArea = new Rectangle(0, 0, 339, 360);	
			_sunsetAsc = new Ascenseur(_arbos[AnthoManager.COUCHANT], _maskArea);
			_sunriseAsc = new Ascenseur(_arbos[AnthoManager.LEVANT], _maskArea);
			_arboContainer.addChild(_sunsetAsc);
			_arboContainer.addChild(_sunriseAsc);
			
			_sunsetAscCmd = new AscenseurCommand(_sunsetAsc);
			_sunriseAscCmd = new AscenseurCommand(_sunriseAsc);
			_sunsetAscCmd.x = _maskArea.x + _maskArea.width - 25;
			_sunsetAscCmd.y = _arboContainer.y + _maskArea.y + _maskArea.height + 15;
			_sunriseAscCmd.x = _maskArea.x + _maskArea.width - 25;
			_sunriseAscCmd.y = _arboContainer.y + _maskArea.y + _maskArea.height + 15;
			this.addChild(_sunsetAscCmd);
			this.addChild(_sunriseAscCmd);
			_sunAscs = new Array();
			_sunAscs[AnthoManager.COUCHANT] = _sunsetAsc;
			_sunAscs[AnthoManager.LEVANT] = _sunriseAsc;
		}
		
		/**
		 * Init scrollbar
		 * @param	e
		 */
		private function scInit(e:Event):void {
			_sc.init();
		}
		/**
		 * 
		 */
		public function openLevant() {
			corpusHeader.setCorpus(AnthoManager.LEVANT);
			_arbos[AnthoManager.COUCHANT].hide();
			_arbos[AnthoManager.LEVANT].show();
			_sunsetAscCmd.visible = false;
			_sunriseAscCmd.visible = true;
			this._open();
			
		}
		/**
		 * 
		 */
		public function openCouchant() {
			corpusHeader.setCorpus(AnthoManager.COUCHANT);
			_arbos[AnthoManager.COUCHANT].show();
			_arbos[AnthoManager.LEVANT].hide();
			_sunsetAscCmd.visible = true;
			_sunriseAscCmd.visible = false;
			this._open();
		}
		/**
		 * 
		 * @param	p_id
		 */
		public function openByCorpusId(p_id:int) {
			if (_activeRepBtn) {
				_activeRepBtn.setNormal();
				_activeRepBtn = null;
			}
			switch(p_id) {
				case AnthoManager.COUCHANT:
					openCouchant();
					break;
				case AnthoManager.LEVANT:
					openLevant();
					break;
			}
		}
		/**
		 * Ouvre le monde en cours
		 */
		public function openCurrent() {
			//_trace.debug("RepBrowser.openCurrent");
			var currentCorpus:int = _mgr.currentCorpus;
			currentCorpus == AnthoManager.COUCHANT ? this.openCouchant() : this.openLevant();
		}
		/**
		 * 
		 */
		private function _open() {
			_trace.debug("SearchWindow._open");
			if (!_isOpen) {
				_isOpen = true;
				// Passe par "Windows" pour ouvrir la fenêtre
				
				var windows:Windows = Windows.getInstance();
				windows.openWindow(this);
			}
		}
		/**
		 * Intercepte l'event OPEN déclenché par un RepButton
		 * @param	evt
		 */
		private function _repButtonOpening(evt:Event) {
			var repBtn:RepButton = evt.target as RepButton;
			var rd:RepData = repBtn.repData;
			
			if (_activeRepBtn) {
				_activeRepBtn.setNormal();
			}
			_activeRepBtn = repBtn;
			repBtn.setActive();
			
			/* 
			 * ##### si le bouton est développé, demande le placement visible de la position Y calculée
			 */ 
			if (repBtn.isDevelopped) {
				
			}
		}
		
		/**
		 * Sélection d'un répertoire dans une des arbos
		 * @param	evt
		 */
		private function _selectRep(evt:NavEvent) {
			_trace.debug("SearchWindow._selectRep");
		}
		/**
		 * Clic sur le bouton de recherche de chaine
		 * @param	evt
		 */
		private function _stringSearchHandler(evt:MouseEvent) {
			_trace.debug("SearchWindow._stringSearchHandler");
			_clearResults();
			var str:String = searchString_tf.text;
			// Limite la recherche à 3 caractères minimum
			if (str.length >= 3) {
				// Ne déclenche pas la recherche si le champ contient toujours l'indication du début
				if(str != _translator.translate("search_keyword").toUpperCase()) {
					//var rd:RepData = new RepData(_mgr.findNodeByPath([AnthoManager.COUCHANT]));
					var rd:RepData;
					if (_activeRepBtn) {
						rd = _activeRepBtn.repData;
					} else  {
						rd = new RepData(_mgr.findNodeByPath([corpusHeader.selectedCorpus]));
					}
					var sr:SearchResults = _mgr.searchStringOnRep(str, rd);
					//_trace.debug("Recherche terminée. sr contient " + sr.list.length + " US.");
					// Affichage
					_displayResults(sr);
				}
			} else {
				info_tf.text = _translator.translate("search_err_tooshort");
			}
		}
		/**
		 * Clic sur le bouton de recherche de n° de vers
		 * @param	evt
		 */
		private function _verseSearchHandler(evt:MouseEvent) {
			_trace.debug("SearchWindow._verseSearchHandler");
			_clearResults();
			var vn:int = int(searchVerse_tf.text);
			//var rd:RepData = new RepData(_mgr.findNodeByPath([AnthoManager.COUCHANT]));
			var rd:RepData;
			if (_activeRepBtn) {
				rd = _activeRepBtn.repData;
			} else  {
				rd = new RepData(_mgr.findNodeByPath([corpusHeader.selectedCorpus]));
			}
			var sr:SearchResults = _mgr.searchVerseNumOnRep(vn, rd);
			
			_displayResults(sr);
		}
		
		/**
		 * Affichage des résultats
		 * @param	sr
		 */
		private function _displayResults(sr:SearchResults) {
			info_tf.text = "";
			var list:Array = sr.list;
			var N:int = sr.resultsCount;
			var title_str:String;
			
			if(sr.searchType == SearchResults.SEARCH_STRING) {
				if (N == 0) {
					title_str = _translator.translate("search_keyword_noresult");
				} else if (N == 1) {
					title_str = _translator.translate("search_keyword_1result");
				} else {
					title_str = String(sr.resultsCount) + _translator.translate("search_keyword_Nresults");
				}
				title_str = title_str.replace("#pattern#", "\"" + sr.pattern + "\"");
				title_str = title_str.replace("#rep#", "\"" + sr.repData.title + "\"");
				resultHead_tf.htmlText = title_str;
			} else if (sr.searchType == SearchResults.SEARCH_VERSE) {
				if (N == 0) {
					title_str = _translator.translate("search_verse_noresult");
				} else if (N == 1) {
					title_str = _translator.translate("search_verse_1result");
				} else {
					title_str = String(sr.resultsCount) + _translator.translate("search_verse_Nresults");
				}
				title_str = title_str.replace("#verse#", sr.pattern);
				title_str = title_str.replace("#rep#", "\"" + sr.repData.title + "\"");
				resultHead_tf.htmlText = title_str;
			}
				
			var i:int;
			var us:USData;
			var srd:SearchResultDisplay;
			for (i = 0; i < N; i++) {
				us = list[i] as USData;
				//info_tf.appendText(" -> " + us.getSearchResultSample(sr.pattern) + "\n");
				srd = new SearchResultDisplay(us, AnthoManager.NEUTRE);
				srd.addEventListener(Event.OPEN, _resultClickHandler);
				if (i > 0) {
					srd.y = _results[i - 1].y + _results[i - 1].height;
				} else {
					srd.y = 0;
				}
				_results_mc.addChild(srd);
				_results.push(srd);
			}
			//
			_setScroller();
			//
		}
		
		private function _resultClickHandler(evt:Event) {
			_trace.debug("SearchWindow : ouverture d'un résultat");
			var srd:SearchResultDisplay = evt.target as SearchResultDisplay;
			_mgr.openUS(srd.usData);
			this.close();			
		}
		
		/**
		 * 
		 */
		private function _setScroller() {
			if(!_sc) {
				_sc = new Scroller(_results_mc, scrollMask, scrollbar.ruler, scrollbar.background, area, false, 1); 
				_sc.addEventListener(Event.ADDED, scInit); 
				this.addChild(_sc);
				scrollUp_btn.addEventListener(MouseEvent.CLICK, _sc.scrollUp);
				scrollDown_btn.addEventListener(MouseEvent.CLICK, _sc.scrollDown);
			}
		}
		/**
		 * Changement de langue demandé par le manager
		 * @param	evt
		 */
		private function _mgrChangeLanguage(evt:Event) {
			this._clear();
			this._versionInit();
		}
		/**
		 * Nettoyage des résultats de recherche
		 */
		private function _clearResults() {
			resultHead_tf.text = "";
			info_tf.text = "";
			if (_results) {
				var N:int = _results.length;
				var srd:SearchResultDisplay;
				for (var i:int = 0; i < N; i++) {
					srd = _results[0];
					srd.removeEventListener(Event.OPEN, _resultClickHandler);
					if (_results_mc.contains(srd)) {
						_results_mc.removeChild(srd);
					}
					_results.shift();
				}
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _corpusHeaderChange(evt:Event) { 
			//_trace.debug("RepBrowser entend CHANGE sur CorpusHeader");
			openByCorpusId(corpusHeader.selectedCorpus);
		} 
		/**
		 * 
		 */
		private function _clear() {
			_trace.debug("SearchWindow._clear");
			_arboContainer.removeChild(_sunsetAsc);
			_arboContainer.removeChild(_sunriseAsc);
			_arboContainer.removeChild(_arbos[AnthoManager.LEVANT]);
			_arboContainer.removeChild(_arbos[AnthoManager.COUCHANT]);
			_arboContainer.removeEventListener(Event.OPEN, _repButtonOpening);
			
			_arboContainer.removeEventListener(Event.OPEN, _repButtonOpening);
			
			_arbos[AnthoManager.LEVANT].removeEventListener(NavEvent.OPEN_US, _selectRep);
			_arbos[AnthoManager.COUCHANT].removeEventListener(NavEvent.OPEN_US, _selectRep);
			
			this.removeChild(_arboContainer);
			this.removeChild(_sunsetAscCmd);
			this.removeChild(_sunriseAscCmd);
			this._clearResults();
			this.close();
			
		}
	}
	
}

internal class SingletonBlocker {}