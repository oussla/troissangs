package com.thequest.epist.argu {
	import com.nlgd.supertrace.*;
	import com.thequest.epist.*;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.events.EventDispatcher;
	import com.thequest.epist.argu.NavManagerEvent;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class NavManager extends EventDispatcher {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _mgr:NavManager = null;
		private var _trace:SuperTrace;
		private var _currentPath:Array;
		private var _xmlArticlesLite:XML;
		private var _EDArticles:Array;
		private var _EDEtapes:Array;
		private var _EDPropals:Array;
		private var _EDAntecs:Array;
		private var _xmlArticle:XML;
		private var _antecLinkRef:EDAntec;
		private var _xmlLinkedArticle:XML;
		private var _linkedArticle:EDArticle;
		private var _linkedEtape:EDEtape;
		private var _linkedPropal:EDPropal;
		
		private var _loader:URLLoader;
		private var _request:URLRequest;
		private var _baseUrl:BaseUrl;
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getMgr():NavManager {
			if (_mgr == null) {
				_mgr = new NavManager(new SingletonBlocker());
			}
			return _mgr;
		}
		//
		public function NavManager(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use VisualLoad.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_baseUrl = BaseUrl.getInstance();
				_trace.info("Hello NavManager !");
				_currentPath = new Array();
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 * @param	p_xmlArticlesLite
		 */
		public function init(p_xmlArticlesLite:XML) {
			_trace.info("NavManager.init");
			_xmlArticlesLite = p_xmlArticlesLite;
			_EDArticles = new Array();
			_EDEtapes = new Array();
			_EDPropals = new Array();
			_EDAntecs = new Array();
			_createArticlesED();			
			_currentPath = [0];
		}
		/**
		 * Crée la liste de EDArticles, stockée dans le tableau _EDArticles
		 */
		private function _createArticlesED() {
			var _articlesList:XMLList = new XMLList(_xmlArticlesLite.ARTICLE);
			var N:int = _articlesList.length();
			var i:int;
			for (i = 0; i < N; i++) {
				var art:EDArticle = new EDArticle(_articlesList[i], i);
				_EDArticles.push(art);
			}
		}
		/**
		 * Changement d'article : demande le chargement des données XML du nouvel article.
		 * @param	p_id
		 */
		public function changeArticle(p_id:int) {
			var article:XMLList = _xmlArticlesLite.ARTICLE.(@id == p_id);
			_currentPath[0] = p_id;
			loadArticle(_baseUrl.BASE+"appdata/" + (Translator.getInstance()).language + "/" + article.url);
		}
		/**
		 * Renvoi un tableau d'ElementData définissant les articles (lite)
		 * @return
		 */
		public function getArticles():Array {
			return _EDArticles;
		}
		/**
		 * Renvoi un tableau d'ElementData contenant les étapes de l'article en cours
		 * @param	idArticle
		 * @return
		 */
		public function getEtapes():Array {
			var eltList:XMLList = new XMLList(_xmlArticle.ETAPE);
			var N:int = eltList.length();
			var i:int;
			if (_EDEtapes) _EDEtapes.splice(0, _EDEtapes.length);
			//
			for (i = 0; i < N; i++) {
				var ed:EDEtape = new EDEtape(eltList[i], i);
				_EDEtapes[i] = ed;
			}
			return _EDEtapes;
		}
		/**
		 * Renvoi un tableau d'ElementData contenant les propositions de l'étape indiquée
		 * @param	idEtape
		 * @return
		 */
		public function getPropals(idEtape:int):Array {
			var eltList:XMLList = new XMLList(_xmlArticle.ETAPE.(@id == idEtape).PROPOSITION);
			_currentPath[1] = idEtape;
			var N:int = eltList.length();
			var i:int;
			if (_EDPropals) _EDPropals.splice(0, _EDPropals.length);
			//
			for (i = 0; i < N; i++) {
				var ed:EDPropal = new EDPropal(eltList[i], i);
				_EDPropals.push(ed);
			}
			return _EDPropals;
		}
		/**
		 * 
		 * @return
		 */
		public function getCurrentPropals():Array {
			return getPropals(_currentPath[1]);
		}
		/**
		 * Renvoi un tableau d'ElementData contenant les antécédents de la proposition indiquée
		 * @param	idPropal
		 * @return
		 */
		public function getAntecs(idPropal:int):Array {
			var eltList:XMLList = new XMLList(_xmlArticle.ETAPE.(@id == _currentPath[1]).PROPOSITION.(@id == idPropal).ANTECEDENT);
			_currentPath[2] = idPropal;
			var N:int = eltList.length();
			_trace.debug("NavManager.getAntecs, trouvé " + N);
			var i:int;
			if (_EDAntecs) _EDAntecs.splice(0, _EDAntecs.length);
			//
			for (i = 0; i < N; i++) {
				var ed:EDAntec = new EDAntec(eltList[i], i);
				_EDAntecs.push(ed);
			}
			//_trace.debug("NavManager.getAntecs, créé " + _EDAntecs.length + " antecs.");
			return _EDAntecs;
		}
		
		/**
		 * Demande l'ouverture d'un lien vers une proposition. Déclenche le chargement de la base.
		 * @param	p_ed
		 */
		public function openLinkedPropal(p_ed:EDAntec) {
			_antecLinkRef = p_ed;
			var filename:String = _baseUrl.BASE + "appdata/" + (Translator.getInstance()).language + "/base" + p_ed.linkBaseId + ".xml"
			var request:URLRequest = new URLRequest(filename);
			var loader:URLLoader = new URLLoader();
			loader.load(request);
			loader.addEventListener(Event.COMPLETE, _linkedPropalReady);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, _xmlHTTPStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, _xmlLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _xmlSecurityError);
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _linkedPropalReady(evt:Event) {
			var loader:URLLoader = evt.target as URLLoader;
			_xmlLinkedArticle = new XML(loader.data);
			
			_linkedArticle = new EDArticle(_xmlLinkedArticle);
			
			var etapes:XMLList = _xmlLinkedArticle.ETAPE.(@id == _antecLinkRef.linkEtapeId);
			_linkedEtape = new EDEtape(etapes[0]);
			
			var propals:XMLList = _linkedEtape.raw.PROPOSITION.(@id == _antecLinkRef.linkPropalId);
			_linkedPropal = new EDPropal(propals[0]);
			
			_trace.debug("NavManager._linkedPropalReady");
			//this.dispatchEvent(new Event(Event.COMPLETE, false, true));
			this.dispatchEvent(new NavManagerEvent(NavManagerEvent.LINKED_PROPAL_READY));
		}
		/**
		 * Renvoi la proposition liée
		 * @return
		 */
		public function get linkedPropal():EDPropal {
			return _linkedPropal;
		}
		public function get linkedArticle():EDArticle {
			return _linkedArticle;
		}
		public function get linkedEtape():EDEtape {
			return _linkedEtape;
		}
		
		
		/**
		 * GESTION DES PROPALS SUIVANTES / PRECEDENTES
		 */
		/* 
		 * Renvoi le nombre total de propositions, pour l'étape en cours
		 * @return
		 */
		public function getMaxPropals():int {
			var eltList:XMLList = new XMLList(_xmlArticle.ETAPE.(@id == _currentPath[1]).PROPOSITION);
			return eltList.length();
		}
		
		public function getPropalByIndex(index:int):EDPropal {
			var ed:EDPropal;
			if (_EDPropals) {
				ed = _EDPropals[index];
			}
			return ed;
		}
		
		
		public function get currentPropalIndex():int {
			return _currentPath[2];
		}
		
		
		
		/**
		 * Chargement d'un article
		 * @param	filename
		 */
		public function loadArticle(filename:String):void {
			_request = new URLRequest(filename);
			_loader = new URLLoader();
			_loader.load(_request);
			_loader.addEventListener(Event.COMPLETE, _onComplete);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, _xmlHTTPStatus);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, _xmlLoadError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _xmlSecurityError);
		}
		/**
		 * XML chargé
		 * @param	event
		 */
		private function _onComplete(event:Event):void {
			_xmlArticle = new XML(_loader.data);
			_trace.debug("NavManager -> _onComplete");
			this.dispatchEvent(event);
		}
		
		/**
		 * Méthodes de gestion des erreurs de chargement du fichier xml
		 */
		private function _xmlLoadError(evt:IOErrorEvent) {
			_trace.error("_xmlLoadError : " + evt.text);
		}
		private function _xmlHTTPStatus(evt:HTTPStatusEvent) {
			//_trace.error("_xmlHTTPStatus : " + evt.status);
		}
		private function _xmlSecurityError(evt:SecurityErrorEvent) {
			_trace.error("_xmlSecurityError : " + evt.text);
		}
		
	}
}

internal class SingletonBlocker {}