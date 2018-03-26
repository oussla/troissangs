package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.NavEvent;
	import com.thequest.epist.Translator;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class AnthoManager extends EventDispatcher {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		public static const COUCHANT:int = 0;
		public static const LEVANT:int = 1;
		public static const NEUTRE:int = 2;
		//
		private static var _instance:AnthoManager;
		//
		private var _trace:SuperTrace;
		private var _currentPath:Array;
		private var _currentNode:XML;
		private var _currentUD:USData;
		private var _currentCorpus:int = COUCHANT;
		private var _nextEndNode:XML;
		private var _raw:XML;
		private var _langDatas:Array;
		private var _mainLanguage:String;
		private var _translator:Translator;
		private var _lengthUsSup:Number;
		private var _forcePlaying:Boolean;
		//
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():AnthoManager {
			if (_instance == null) {
				_instance = new AnthoManager(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function AnthoManager(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use AnthoManager.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello AnthoManager !");
				_translator = Translator.getInstance();
				_translator.addEventListener(Event.CHANGE, _changeLanguage);
				_currentPath = new Array();
				_langDatas = new Array();
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Initialisation, avec l'arbo complète
		 * @param	p_raw
		 */
		public function init(ad:AnthoData) {
			_raw = ad.raw;
			_mainLanguage = ad.id;
			_langDatas.push(ad);
			_trace.debug("AnthoManager.init");
			
		}
		/**
		 * Ajoute un fichier de langue complet
		 * @param	ad
		 */
		public function addLanguage(ad:AnthoData) {
			_trace.debug("AnthoManager.addLanguage : " + ad.id + " (" + ad.language + ")");
			_langDatas.push(ad);
		}
		/**
		 * Changement de langue indiqué par le Translator
		 * @param	evt
		 */
		private function _changeLanguage(evt:Event) {
			_trace.debug("AnthoManager._changeLanguage");
			_raw = this.getXMLByLanguage(_translator.language);
			// Diffuse le changement de langue
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		/**
		 * Ouvre une unité de son
		 * @param	us
		 */
		private function _openUS(us:USData) {
			_currentUD = us;
			trace(_currentUD.soundURL);
			_lengthUsSup = _getLengthUsSup();
			var path:Array = findPathByNode(us.raw);
			_currentCorpus = path[0];
			//_trace.debug("AnthoManager.currentCorpus : " + _currentCorpus);
			this.dispatchEvent(new NavEvent(NavEvent.OPEN_US));
		}
		/**
		 * Ouverture publique d'une US, proposée pour les outils de transformation des données et pour la liste des US dans RepBrowser
		 * @param	us
		 */
		public function openUS(us:USData, p_forcePlaying:Boolean = true) {
			_forcePlaying = p_forcePlaying;
			this._openUS(us);
		}
		/**
		 * Ouvre la premère US du répertoire indiqué (descend dans les sous-répertoires)
		 * @param	p_rd
		 */
		public function openRepFirstUS(rd:RepData, p_forcePlaying:Boolean = true):USData {
			//_trace.debug("AnthoManager.openRepFirstUS");
			
			_forcePlaying = p_forcePlaying;
			
			// Descend au plus profond de ce noeud d'arbo jusqu'à trouver le premier US.
			var endNode:XML = _recursiveSearch(rd.raw);
			var rd:RepData = new RepData(endNode);
			_currentNode = endNode; // jenny

			var us:USData = rd.getFirstUS();
			this._openUS(us);
			
			return us;
		}
		/**
		 * Renvoie la première US du répertoire indiqué (idem à openRepFirstUS, mais ne déclenche pas d'ouverture)
		 * @param	rd
		 * @return
		 */
		public function getRepFirstUS(rd:RepData, p_forcePlaying:Boolean = true):USData {
			var endNode:XML = _recursiveSearch(rd.raw);
			var rd:RepData = new RepData(endNode);
			
			_forcePlaying = p_forcePlaying;
			
			return rd.getFirstUS();
		}
		/**
		 * 
		 * Recherche dans les sous-répertoires le rép de dernier niveau, et renvoi sa 1ere US
		 * @param	rd
		 * @return
		 */
		public function searchRepFirstUS(rd:RepData):USData {
			//_trace.debug("AnthoManager.searchRepFirstUS");
			
			// Descend au plus profond de ce noeud d'arbo jusqu'à trouver le premier US.
			var endNode:XML = _recursiveSearch(rd.raw);
			var rd:RepData = new RepData(endNode);
			
			return rd.getFirstUS();
		}
		
		/**
		 * 
		 * Recherche dans les sous-répertoires le dernier rép de dernier niveau, et renvoi sa dernière US
		 * @param	rd
		 * @return
		 */
		public function searchRepLastUS(rd:RepData):USData {
			//_trace.debug("AnthoManager.searchRepLastUS");
			var list:XMLList = new XMLList(rd.raw);
			var nbRep:int = list.REPERTOIRE.length();
			while (nbRep != 0) {
				var xmlRep:XML = list.REPERTOIRE[nbRep - 1];
				rd = new RepData(xmlRep);
				list = new XMLList(rd.raw);
				nbRep = list.REPERTOIRE.length();
			}
			return rd.getLastUS();
		}
		/**
		 * Recherche et ouvre l'unité de son suivante
		 * @return	retourne l'unité de son suivante, si elle existe, null sinon
		 */
		public function gotoNextUS(p_forcePlaying:Boolean = true):USData {
			//_trace.debug("AnthoManager.gotoNextUS");
			var us:USData;
			var indexUD:int = _currentUD.raw.childIndex();//position de l'US dans la liste des US
			var repXml:XML = _currentUD.raw.parent().parent(); //repertoire dans lequel se trouve la liste d'US de l'us en cours
			var rep:RepData = new RepData(repXml);
			
			_forcePlaying = p_forcePlaying;
			
			var list:Array = new Array();
			list = rep.getUSList();
			var nbUS:int = list.length;
			//_trace.debug("US actuel = " + int(indexUD+1) + " sur " + nbUS + " US dans cette liste d'US");
			if (indexUD < nbUS-1) { // S'il y a des US à lire dans la liste d'US courants
				//_trace.debug("Passage à l'US suivant...");
				us = list[indexUD + 1];
			}
			else { //s'il l'US en cours était la dernière de la liste
				//_trace.debug("Pas de next US dans la liste des US");
				var found:Boolean = false;
				var node:XML = rep.raw;
				var listRepParent:XMLList;

				//while (!found && node != undefined) {
				while (!found && node != null) {
					//_trace.debug("Répertoire actuel = '" + node.TITRE + "'");
					if (node.parent() != undefined) {
						listRepParent = new XMLList(node.parent().REPERTOIRE); //liste des repertoires du meme niveau
						
						var nbRep:int = listRepParent.length(); //nombre de repertoires
						
						//position du répertoire en cours
						//_trace.debug("Cherche position du répertoire en cours");
						for (var i = 0; i < nbRep; i++) {
							if (listRepParent[i] == node) {
								var indexParent:int = i;
							}
						}
						//_trace.debug("Rép actuel = " + int(indexParent+1) + " sur " + nbRep + " rep de ce niveau");
				
						if (indexParent < nbRep-1) { //si le repertoire dans lequel on se trouve n'est pas le dernier
							repXml = listRepParent[indexParent+1];
							rep = new RepData(repXml);
							//_trace.debug("Cherche dans le répertoire suivant... (" + rep.title + ")");
							us = this.searchRepFirstUS(rep);
							found = true;
						}
					}
					node = node.parent();
				}
			}
			if (us)			
				this._openUS(us);
			else {
				_trace.debug("Pas d'US à ouvrir");
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
			//
			return us;
		}
		
		/**
		 * Recherche et ouvre l'unité de son suivante.
		 * @param	p_forcePlaying	flag pour forcer la lecture du son après ouverture
		 */
		public function gotoPreviousUS(p_forcePlaying:Boolean = true) {
			//_trace.debug("AnthoManager.gotoPreviousUS");
			var us:USData;
			var indexUD:int = _currentUD.raw.childIndex();//position de l'US dans la liste des US
			var repXml:XML = _currentUD.raw.parent().parent(); //repertoire dans lequel se trouve la liste d'US de l'us en cours
			var rep:RepData = new RepData(repXml);
			
			_forcePlaying = p_forcePlaying;
			
			var list:Array = new Array();
			list = rep.getUSList();
			var nbUS:int = list.length;
			//_trace.debug("US vue = " + int(indexUD + 1) + " sur " + nbUS + " US dans cette liste d'US");
			
			if (indexUD > 0) { // si l'US n'est pas la première
				//_trace.debug("Passage à l'US précédente ...");
				us = list[indexUD - 1];
			}
			else { //s'il l'US en cours était la première de la liste
				//_trace.debug("\nL'US était la première de la liste");
				
				var found:Boolean = false;
				var node:XML = rep.raw;
				var listRepParent:XMLList;
				
				//while (!found && node != undefined) {
				while (!found && node != null) {
					if (node.parent() != undefined && node.parent().parent() != undefined) {
						listRepParent= new XMLList(node.parent().REPERTOIRE);
						var nbRep:int = listRepParent.length();//nombre de répertoire dans ce niveau
						for (var i = 0; i < nbRep; i++) {
							if (listRepParent[i] == node) {
								var indexRep:int = i;//position du répertoire courant
							}
						}
						//_trace.debug("index = " + int(indexRep+1) + " sur nbRep = " + nbRep);
						if (indexRep > 0) { //si le répertoire du niveau en cours n'est pas le premier 
							//_trace.debug("Le répertoire en cours n'est pas le premier de ce niveau");
							//_trace.debug("On se trouve dans '" + rep.title + "'");
							rep = new RepData(listRepParent[indexRep - 1]);
							//_trace.debug("On va chercher dans '" + rep.title + "'");
							us = this.searchRepLastUS(rep);
							found = true;
						}
					}
				node = node.parent();
				}
			}
			
			if (us)			
				this._openUS(us);
			else 
				_trace.debug("Pas d'US à ouvrir");
			
		}
		
		
		/**
		 * Convertit une USData en USData dans la langue demandée
		 * @param	us
		 * @param	langId
		 * @return
		 */
		public function convertUSToLanguage(us:USData, langId:String):USData {
			var path:Array = findPathByNode(us.raw);
			var node:XML = findNodeByPath(path, langId);
			var newUS:USData;
			if(node) {
				newUS = new USData(node);
			}
			return newUS;
		}
		/**
		 * Trouve un noeud XML d'après le chemin donné en paramètre - ANCIENNE VERSION
		 * @param	path
		 * @return
		 */
		public function findNodeByPath_old(path:Array, langId:String = null):XML {
			var i:int;
			var xmlBase:XML = getXMLByLanguage(langId);
			//_trace.debug("AnthoManager.findNodeByPath, language : " + langId);
			var finalNode:XML;
			var tempXMLList:XMLList = new XMLList(xmlBase.REPERTOIRE);
			var N:int = path.length;
			// Parcours la structure jusqu'au bout du chemin indiqué. 
			// Arrête un rang avant le dernier indice du path (le dernier rang sera relevé dans la dernière XMLList).
			for (i = 0; i < N - 1; i++) {
				tempXMLList = new XMLList(tempXMLList[path[i]].REPERTOIRE);
			}
			// Relève le XML final dans la XMLList, au rang donné par le dernier indice du path
			finalNode = tempXMLList[path[N - 1]];
			return finalNode;
		}
		/**
		 * Revnoi un noeud XML d'après le chemin donné en paramètre
		 * ##### TODO : ajouter contrôles d'erreurs si noeud non défini dans le XML cible #####
		 * @param	path
		 * @return
		 */
		public function findNodeByPath(path:Array, langId:String = null):XML {
			var i:int;
			var xmlNode:XML = getXMLByLanguage(langId);
			var tempXMLList:XMLList = new XMLList(xmlNode);
			var N:int = path.length;
			for (i = 0; i < N; i++) {
				tempXMLList = tempXMLList.child(path[i]);
			}
			return tempXMLList[0];
		}
		/**
		 * Définit un path d'après un noeud du XML. Part du noeud et remonte l'arbo jusqu'à la racine.
		 * @param	node
		 * @return
		 */
		public function findPathByNode(p_node:XML):Array {
			var path:Array = new Array();
			var node:XML = p_node;
			while (node) {
				if(node.childIndex() >= 0) {
					path.push(node.childIndex());
				}
				node = node.parent();
			}
			path.reverse();
			//_trace.debug("findPathByNode : " + path);	
			return path;
		}
		/**
		 * 
		 * @return
		 */
		public function getCurrentPath():Array {
			return this.findPathByNode(_currentUD.raw);
		}
		
		public function getCurrentPathCode():Array {
			var path:Array = new Array();
			var node:XML = _currentUD.raw;
			var index:int;
			while (node) {
				if (node.childIndex() >= 0) {
					index = node.childIndex();
					//path.push(node.localName() + ":" + node.childIndex());
					path.push(node.localName() + ":" + index);
				}
				node = node.parent();
			}
			path.reverse();
			//_trace.debug("findPathByNode : " + path);	
			return path;
			
		}
		
		/**
		 * Descend en profondeur dans l'arbo jusqu'au dernier noeud. Fonction récursive.
		 * @param	cn
		 * @return
		 */
		private function _recursiveSearch(cn:XML):XML {
			var i, N:int;
			var SRList:XMLList;
			var found:XML = null;
			// Si il y a des sous-répertoires
			SRList = new XMLList(cn.REPERTOIRE);
			if (SRList.length() > 0) {
				//_trace.debug("Le noeud " + cn.TITRE + " a des sous-rep.");
				// Appelle la fonction sur tous les noeuds répertoires SAUF si on trouve.
				N = SRList.length();
				for (i = 0; i < N && !found; i++) {
					found = _recursiveSearch(SRList[i]);
				}
				
			} else {
				// Pas de sous répertoires. Récupère la liste de SsRep dont ce noeud fait partie.
				SRList = new XMLList(cn.parent().REPERTOIRE);
				//_trace.debug("Le noeud " + cn.TITRE + " n'a pas de sous-rep. childIndex : " + cn.childIndex() + ", totalChilds : " + SRList.length());
				_nextEndNode = cn;
				found = cn;
				
			}
			return found;
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
		
		/**
		 * Renvoi le XML brut d'après l'identifiant de langue "id"
		 * @param	id
		 * @return
		 */
		private function getXMLByLanguage(id:String):XML {
			var i:int;
			var N:int = _langDatas.length;
			var found:Boolean = false;
			var xml:XML;
			
			if (!id) {
				xml = _raw;
			} else {
				for (i = 0; i < N && !found; i++) {
					if (_langDatas[i].id == id) {
						found = true;
						xml = _langDatas[i].raw;
					}
				}
				if (!found) {
					_trace.avert("Attention : AnthoManager.getXMLByLanguage, correspondance non trouvée (langage : " + id + ")");
				}
			}
			return xml;
			
		}
		
		/**
		 * Renvoi un tableau de RepData (au dessus de l'US courante)
		 */
		public function getCurrentPathSup():Array {
			var r:Array;
			if(_currentUD) {
				r = getPathSup(_currentUD);
			} else {
				r = new Array();
			}
			return r;			
		}
		/**
		 * Renvoi un tableau contenant tous les répertoires parents de us.
		 * @param	us
		 * @return
		 */
		public function getPathSup(us:USData):Array {
			var returnArray:Array = new Array();
			var arboXML:XML = us.raw.parent().parent();
			var rd:RepData;
			var dureeNiv:Number = 0;
			while (arboXML != null && arboXML.parent() != undefined) {
				// Est-ce qu'il est nécessaire de savoir si on se trouve dans un répertoire ?
				//if (arboXML.TITRE != undefined) {
					rd = new RepData(arboXML);
					if (dureeNiv) {
						rd.setLengthSup(dureeNiv);
						//_trace.debug("Durée = "+dureeNiv); //durée des sons des niveaux au dessus	
					}
					//dureeNiv = 0;
					
					//_trace.debug("\nRepData traité : " + rd.title);
					//childindex du noeud de ce rep
					var ci:int = rd.raw.childIndex();
					//_trace.debug(rd.rawTitle + " : " + ci);
					
					//parcours des children du parent de ci-1 à >=0
					for (var i:int = (ci-1); i >= 0; i--) {
						//si le noeud est un répertoire : ajouter la durée à la durée globale
						if (rd.raw.parent().children()[i] && rd.raw.parent().children()[i].localName() && rd.raw.parent().children()[i].localName() == "REPERTOIRE") {
							//_trace.debug(rd.raw.parent().children()[i].TITRE + " : " + rd.raw.parent().children()[i].LEN);
							dureeNiv = dureeNiv + Number(rd.raw.parent().children()[i].LEN);
						}
					}
					returnArray.push(rd);
				//}
				arboXML = arboXML.parent();
			}

			returnArray.reverse();
			returnArray.shift();
			return returnArray;
		}
		
		/**
		 * Renvoie la longueur des sons précédents l'us en cours
		 */
		private function _getLengthUsSup():Number {
			//_trace.debug("AnthoManager.getLengthUsSup");
			//_trace.debug("childIndex _currentUS = " + _currentUD.raw.childIndex());
			var ci:int = _currentUD.raw.childIndex();
			var dureeUS:Number = 0;
			for (var i:int = (ci - 1); i >= 0; i--) {
				//_trace.debug("US " + i + " = " + _currentUD.raw.parent().children()[i].LEN);
				dureeUS = dureeUS + Number(_currentUD.raw.parent().children()[i].LEN);
				//_trace.debug(""+dureeUS);
			}
			//_trace.debug("AnthoManager._getLengthUsSup, durée des US précédentes : " + dureeUS + ", childIndex : " + ci);
			return dureeUS;
			
		}
		/**
		 * 
		 */
		public function get lengthUsSup():Number {
			return _lengthUsSup;
		}
		/** 
		 * COPIE
		 * 
		public function getPathSup(us_raw:XML):Array {
			var returnArray:Array = new Array();
			var arboXML:XMLList = new XMLList(us_raw);
			arboXML = new XMLList(arboXML.parent().parent());
			var rd:RepData;
			//while (arboXML != undefined && arboXML.parent() != undefined) {
			while (arboXML != null && arboXML.parent() != undefined) {
				if (arboXML.TITRE != undefined) {
					rd = new RepData(new XML(arboXML));
					returnArray.push(rd);
				}
				arboXML = new XMLList(arboXML.parent());
			}
			returnArray.reverse();
			returnArray.shift();
			return returnArray;
		}
		*/
		
		/**
		 * Recherche le premier parent contenant une description
		 * @param	rd
		 * @return
		 */
		public function getParentWithDesc(rd:RepData):RepData {
			var found:Boolean = false;
			while (!found && rd) {
				rd = rd.getRepParent();
				if (rd && rd.desc) {
					found = true;
					
				}
			}		
			//_trace.debug("AnthoManager.getParentWithDesc, trouvé ? " + found);
			return rd;
		}
		
		/**
		 * Recherche la chaîne str dans toutes les unités de son de rd et de tous ses enfants
		 * @param	str
		 * @param	rd
		 * @return
		 */
		public function searchStringOnRep(str:String, rd:RepData):SearchResults {
			_trace.debug("AnthoManager.searchStringOnRep(" + str + ")");
			// Stocke les occurrences de résultats
			var sr:SearchResults = new SearchResults();			
			// Recherche. Récursivité dans les appels, par les RD.
			sr = rd.search(str);
			sr.searchType = SearchResults.SEARCH_STRING;
			sr.pattern = str;
			sr.repData = rd;
			return sr;
		}
		
		/**
		 * Recherche le numéro de vers vn dans toutes les unités de son de rd et de tous ses enfants
		 * @param	vn
		 * @param	rd
		 * @return
		 */
		public function searchVerseNumOnRep(vn:int, rd:RepData):SearchResults {
			_trace.debug("AnthoManager.searchVerseNumOnRep");
			var sr:SearchResults;
			sr = rd.searchVerseNum(vn);
			sr.searchType = SearchResults.SEARCH_VERSE;
			sr.pattern = String(vn);
			sr.repData = rd;
			return sr;
		}
		
		/**
		 * Renvoi la valeur du flag _forcePlaying, indiquant si la lecture doit être forcée après ouverture d'une US.
		 */
		public function get forcePlaying():Boolean {
			return _forcePlaying;
		}
		/**
		 * Renvoi le USData de l'unité de son en cours
		 */
		public function get currentUD():USData {
			return _currentUD;
		}
		/**
		 * Renvoi l'identifiant du corpus en cours (AnthoManager.COUCHANT ou AnthoManager.LEVANT)
		 */
		public function get currentCorpus():int {
			return _currentCorpus;
		}
		
		public function get raw():XML {
			return _raw;
		}
		
	}
	
}

internal class SingletonBlocker {}