package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.NavEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import com.thequest.epist.Translator;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class USMultilangues extends Sprite {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _mgr:AnthoManager;
		private var _trace:SuperTrace;
		private var _maxLang:int = 3;
		private var _langElts:Array;
		private var _translator:Translator;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function USMultilangues() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello USMultilangues !");
			_langElts = new Array();
			_mgr = AnthoManager.getInstance();
			_mgr.addEventListener(NavEvent.OPEN_US, refreshColumns);
			_translator = Translator.getInstance();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function init(p_strophe:String) {
			_trace.debug("USMultilangues.init");
			var lang:USLangColumn = this._addLang();
			lang.setContent(p_strophe, _translator.language);
			lang.close_btn.visible = false;
			lang.bg.visible = false;
			lang.bgFirst.visible = true;
		}
		
		public function setLanguages(p_languages:Array) {
			
		}
		
		public function reset() {
			trace("USMultilangues.reset")
			var i:int;
			var N:int = _langElts.length;
			for (i = 0; i < N; i++) {
				var lang:USLangColumn = _langElts.shift() as USLangColumn;
				this.removeChild(lang);
				lang = null;
			}
		}
		
		public function refreshColumns(evt:NavEvent) {
			_trace.debug("USMultilangues.refreshColumns");
			var nbCol:int = _langElts.length;
			var newUS:USData;
			//_trace.debug("" + nbCol + " colonnes ouvertes");
			if (nbCol == 0) {//1er lancement de l'appli
				newUS = _mgr.convertUSToLanguage(_mgr.currentUD, _translator.language);
				this.init(newUS.strophe);
			}
			else {
				for (var i:int = 0; i < nbCol; i++) {
					var col:USLangColumn = 	_langElts[i] as USLangColumn;
					//_trace.debug("Colonne n°" + i + " => " + col.lang);
					newUS = _mgr.convertUSToLanguage(_mgr.currentUD, col.lang);
					col.setContent(newUS.strophe, col.lang);
				}
			}
		}
		
		
		/**
		 * Ajout d'une colonne de langue
		 * @param	evt
		 */
		private function _addLang(evt:Event = null) {
			trace("USMultilangues._addLang")
			var lang:USLangColumn;
			//_trace.debug("USMultilangues._addLang");
			if (_langElts.length < _maxLang) {
				// Ajout nouvelle langue
				lang = new USLangColumn();
				lang.addEventListener(Event.CHANGE, _changeLang);
				lang.addEventListener(Event.CLOSE, _closeLang);
				lang.addEventListener(NavEvent.US_ADD_LANG, _addLang);
				this.addChild(lang);
				_langElts.push(lang);
				
			}
			arrangeColumns();
			//
			
			// ###### TEMP 
			if (_langElts.length > 1) {
				var newUS:USData;
				// Demande l'unité de son en indonésien
				if(_langElts.length == 2) {
					newUS = _mgr.convertUSToLanguage(_mgr.currentUD, "id");
					if (newUS != null) {
						lang.setContent(newUS.strophe, "id");
					}
					else {
						_trace.avert("Attention : USMultilangues._addLang : unité de son non définie (id).");
					}
				}
				if(_langElts.length == 3) {
					newUS = _mgr.convertUSToLanguage(_mgr.currentUD, "to");
					if (newUS != null) {
						lang.setContent(newUS.strophe, "to");
					} else {
						_trace.avert("Attention : USMultilangues._addLang : unité de son non définie (to).");
					}
				}
			}
			//
			return lang;
		}
		/**
		 * Remet les colonnes en place et diffuse l'évènement CHANGE
		 */
		private function arrangeColumns() {
			var i:int;
			var lang:USLangColumn;
			var N:int = _langElts.length;
			
			for (i = N-1; i >= 0; i--) {
				this.addChild(_langElts[i]);
			}
			
			i = 0;
			for each(lang in _langElts) {
				lang.setPosition(new Point(i * 327, 0));
				i++;
			}
			
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		/**
		 * Changement ou ouverture d'une traduction demandée par une colonne
		 * @param	evt
		 */
		private function _changeLang(evt:Event) {
			var btn:LangButton = evt.target as LangButton;
			//_trace.debug("\nLangue demandée : " + btn.lang);
			var lang:USLangColumn = evt.target.parent.parent as USLangColumn;
			var i:int = _langElts.indexOf(lang);
			//_trace.debug("Dans la colonne n°" + i);
			//changement du contenu de la colonne
			var newUS:USData = _mgr.convertUSToLanguage(_mgr.currentUD, btn.lang);
			if (newUS != null)
				lang.setContent(newUS.strophe, btn.lang);
		}
		
		/**
		 * Fermeture d'une colonne de langue
		 * @param	evt
		 */
		private function _closeLang(evt:Event) {
			_trace.debug("USMultilangues._closeLang");
			var lang:USLangColumn = evt.target as USLangColumn;
			var i:int = _langElts.indexOf(lang);
			if(i != 0) {
				_trace.debug("fermeture de la colonne trouvée en " + i);
				
				this.removeChild(lang);
				lang.removeEventListener(Event.CHANGE, _changeLang);
				lang.removeEventListener(Event.CLOSE, _closeLang);
				lang.removeEventListener(NavEvent.US_ADD_LANG, _addLang);
				
				_langElts.splice(i, 1);
				
				arrangeColumns();
			} else {
				_trace.debug("la colonne 0 ne peut pas être fermée.");
			}
		}
		/**
		 * Renvoi le nombre de langues ouvertes
		 */
		public function get nbLang():int {
			return _langElts.length;
		}
	}
	
}