package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class  TESTXmlParcours extends MovieClip {
		
		private var _trace:SuperTrace;
		private var _raw:XML;
		private var _currentNode:XML;
		private var _currentPath:Array;
		private var _nextEndNode:XML;
		
		private var _loader:URLLoader;
		private var _request:URLRequest;
		private var _xmlArticles:XML;
		
		public var test_tf:TextField;
		
		
		
		public function TESTXmlParcours() {
			_trace = SuperTrace.getTrace();
			_trace.debug("TESTXmlParcours");
			
			_currentPath = new Array();
			
			_raw = new XML();
			
			_currentPath = [0,0,0,1];
			_trace.debug("_currentPath : " + _currentPath);
			
			//_trace.debug("----------\nle parent : \n" + xmlTest.parent().parent());
			//_currentNode = xmlTest;
			
			//_findNextEndNode();
			
			//_trace.debug("Le noeud suivant est : " + _nextEndNode.TITRE);
			
			loadXML("../PUB/appdata/fr/anthologie.xml");
			
			test_tf.text = "Un morceau de texte\n\tet un alinéa";
			
		}
		
		/**
		 * Trouve un noeud XML d'après le chemin donné en paramètre
		 * @param	path
		 * @return
		 */
		private function _findNodeByPath(path:Array):XML {
			var finalNode:XML;
			var tempXMLList:XMLList = new XMLList(_raw.REPERTOIRE);
			var N:int = path.length;
			// Parcours la structure jusqu'au bout du chemin indiqué. 
			// Arrête un rang avant le dernier indice du path (le dernier rang sera relevé dans la dernière XMLList).
			for (var i:int = 0; i < N - 1; i++) {
				tempXMLList = new XMLList(tempXMLList[path[i]].REPERTOIRE);
			}
			// Relève le XML final dans la XMLList, au rang donné par le dernier indice du path
			finalNode = tempXMLList[path[N - 1]];
			return finalNode;
		}
		
		/**
		 * Renvoi le prochain noeud sans sous-répertoires, d'après le noeud courant
		 * @return
		 */
		private function _findNextEndNode():XML {
			var finalNode:XML;
			var cn:XML = _currentNode;
			var path:Array = _currentPath.slice();
			
			/*
			 * 0. Est-ce qu'il a des sous-répertoires ? 
			 * 		oui : descend dans le sous-répertoire, sur le premier de la liste de sous-rep.
			 * 		non : passe en 1.
			 * 1. Si ce noeud n'est pas le dernier dans la liste de son parent : passe au suivant dans la liste et revient en 0.
			 * 2. Si c'est le dernier : remonte d'un répertoire, et revient en 1
			 * 
			 */
			
			
			_recursiveSearch(cn);

			
			return finalNode;
		}
		
		private function _recursiveSearch(cn:XML):Boolean {
			var i, N:int;
			var SRList:XMLList;
			var found:Boolean = false;
			// Si il y a des sous-répertoires
			SRList = new XMLList(cn.REPERTOIRE);
			if (SRList.length() > 0) {
				_trace.debug("Le noeud " + cn.TITRE + " a des sous-rep.");
				
				// Appelle la fonction sur tous les noeuds répertoires SAUF si on trouve.
				N = SRList.length();
				for (i = 0; i < N && !found; i++) {
					found = _recursiveSearch(SRList[i]);
				}
				
				//_recursiveSearch(SRList[0]);
			} else {
				// Pas de sous répertoires. Récupère la liste de SsRep dont ce noeud fait partie.
				SRList = new XMLList(cn.parent().REPERTOIRE);
				_trace.debug("Le noeud " + cn.TITRE + " n'a pas de sous-rep. childIndex : " + cn.childIndex() + ", totalChilds : " + SRList.length());
				_nextEndNode = cn;
				found = true;
				/*
				if (cn.childIndex() == SRList.length() - 1) {
					_trace.debug("--- Le noeud " + cn.TITRE + " est dernier de la liste");
					// Dernier de la liste. On remonte d'un répertoire, et on passe au suivant s'il était dernier de la liste.
					//SRList = new XMLList(cn.parent().parent().parent().REPERTOIRE);
					//_trace.debug("--- total : " + SRList.length() + ", index du parent : " + cn.parent().parent().childIndex());
					//_trace.debug("--- le parent : \n" + cn.parent().parent());
				} else {
					// Pas le dernier de la liste. On checke avec le noeud suivant.
					//_recursiveSearch(SRList[cn.childIndex() + 1]);
				}
				*/
			}
			//if (found) _trace.debug("FOUND");
			return found;
		}
		
		
		
		
		
		
		
		
		
		
		/**
		 * Chargement de la liste d'articles
		 * @param	filename
		 */
		public function loadXML(filename:String):void {
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
			_trace.debug("anthologie chargée");
			_raw = new XML(_loader.data);
			var xmlTest = this._findNodeByPath(_currentPath);
			//_trace.debug("le résultat : \n " + xmlTest);
			_currentNode = _raw;
			_findNextEndNode();
			_trace.debug("Le noeud suivant est : " + _nextEndNode.TITRE);
			
			
			var listeUS:XMLList = new XMLList(_nextEndNode.LISTE_US.US);
			_trace.debug("Nombre d'US : " + listeUS.length());
			//_trace.debug("Strophe : \n" + listeUS[0].STROPHE);
			
			var str:String = listeUS[0].STROPHE;
			_trace.debug("cherche retourligne : " + str.lastIndexOf("\r\n\t"));
			
			var pattern:RegExp = /\r\n/g;
			str = str.replace(pattern, "\n");
			var pattern2:RegExp = /\n\t\n/g;
			str = str.replace(pattern2, "\n");
			
			_trace.debug("----------\n" + str + "---------");
			test_tf.htmlText = str;
			
			
			
		}
		
		/**
		 * Méthodes de gestion des erreurs de chargement du fichier xml
		 */
		private function _xmlLoadError(evt:IOErrorEvent) {
			_trace.error("_xmlLoadError : " + evt.text);
		}
		private function _xmlHTTPStatus(evt:HTTPStatusEvent) {
			_trace.error("_xmlHTTPStatus : " + evt.status);
		}
		private function _xmlSecurityError(evt:SecurityErrorEvent) {
			_trace.error("_xmlSecurityError : " + evt.text);
		}
		
		
		
		
	}
	
}