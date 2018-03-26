package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.nlgd.supertrace.SuperTraceDisplay;
	import com.nlgd.supertrace.SuperTraceStrictWindow;
	import com.thequest.epist.NavEvent;
	import com.thequest.epist.Translator;
	import com.thequest.epist.XMLLiteLoader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import flash.filesystem.*;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class DEV_SearchTools extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private const LANGUAGE:String = "fr";
		// Nombre total de vers à traiter. 0 pour arrêt automatique à la fin.
		private const TOTAL_US_COUNT:int = 0;//1100;
		//
		private var _trace:SuperTrace;
		private var _traceDisplay:SuperTraceDisplay;
		private var _translator:Translator;
		private var _xmlLoader:XMLLiteLoader;
		private var _mgr:AnthoManager;
		private var _continuum:int = 1;
		private var _totalVerses:int = 0;
		private var _timer:Timer;
		private var _selectedRepData:RepData;
		//	
		public var trace_tf:TextField;
		public var search_tf:TextField;
		public var btnOpen:SimpleButton;
		public var btnSave:SimpleButton;
		public var btnSearch:SimpleButton;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function DEV_SearchTools() {
			_trace = SuperTrace.getTrace();
			_traceDisplay = new SuperTraceDisplay(_trace, this, trace_tf);
			_trace.debug("DEV_SearchTools");
			_echoCurrentDate();
			_mgr = AnthoManager.getInstance();
			_translator = Translator.getInstance();
			_xmlLoader = new XMLLiteLoader();
			_xmlLoader.addEventListener(Event.COMPLETE, _xmlLoaded);
			//_xmlLoader.load("../PUB/appdata/" + LANGUAGE + "/anthologie.xml");
			//
			
			
			_timer = new Timer(50, TOTAL_US_COUNT);
			_timer.addEventListener(TimerEvent.TIMER, _timerHandler);
			//
			btnOpen.addEventListener(MouseEvent.CLICK, _openFileHandler);
			btnSearch.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_searchStringOnRep(search_tf.text, _selectedRepData);
			} );
		}
		
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		
		private function _openFileHandler(evt:MouseEvent) {
			_trace.debug("_openFileHandler");
			var fileToOpen:File = new File();
			try {
				fileToOpen.browseForOpen("Open");
				fileToOpen.addEventListener(Event.SELECT, _fileSelected);
			}
			catch (error:Error)	{
				_trace.error("openFile Failed:" + error.message);
			}
		}
		
		private function _fileSelected(event:Event):void {
			var stream:FileStream = new FileStream();
			stream.open(event.target as File, FileMode.READ);
			var fileDataXML:XML = new XML(stream.readUTFBytes(stream.bytesAvailable));
			//_trace.debug(fileData);
			
			var ad:AnthoData = new AnthoData(fileDataXML, LANGUAGE);
			_mgr.init(ad);
			
			this.init();
			
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _xmlLoaded(evt:Event) {
			_trace.debug("DEV_ManageDatas : le xml de l'anthologie est chargé.");
			// Initialise le AnthoManager en lui passant les données de la langue principale
			var ad:AnthoData = new AnthoData(_xmlLoader.xml, LANGUAGE);
			_mgr.init(ad);
			//
			this.init();
			
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _timerHandler(evt:TimerEvent) {
			_nextUS();
		}
		/**
		 * Initialisation : ouvre la première US du premier répertoire.
		 */
		private function init() {
			//var rootNode:XML = _mgr.findNodeByPath([AnthoManager.COUCHANT, 1, 1, 20]);
			//var rootNode:XML = _mgr.findNodeByPath([AnthoManager.LEVANT, 2]);
			var rootNode:XML = _mgr.findNodeByPath([AnthoManager.COUCHANT]);
			//var rootNode:XML = _mgr.findNodeByPath([AnthoManager.LEVANT]);
			_selectedRepData = new RepData(rootNode);
			_trace.debug("Init sur " + _selectedRepData.rawTitle);
		}
		/**
		 * 
		 * @param	str
		 * @return
		 */
		private function _searchStringOnRep(str:String, rd:RepData) {
			
			var sr:SearchResults = _mgr.searchStringOnRep(str, rd);
			
			_trace.debug("Recherche terminée. sr contient " + sr.list.length + " US.");
			
			// Affichage
			var list:Array = sr.list;
			var N:int = list.length;
			var i:int;
			var us:USData;
			for (i = 0; i < N; i++) {
				us = list[i] as USData;
				_trace.debug("i:" + i + " -> " + us.getSearchResultSample(str));
			}
			
		}
		/**
		 * Passage à l'US suivante.
		 */
		private function _nextUS() {
			var us:USData = this._getNextUS();
			if(us) {
				_processUS(us);
			}
		}
		/**
		 * Traitement d'une Unité de Son
		 * @param	us
		 * 
		 */
		private function _processUS(us:USData) {
			//
		}
		/**
		 * Compte les vers dans la strophe "str"
		 * @param	str
		 * @return	le nombre de vers
		 */
		private function _countVerses(str:String):int {
			var nbV:int = 0;
			var splitted:Array = str.split("\n");
			var N:int = splitted.length;
			//_trace.debug("countVerses, raw N : " + N);
			for (var i:int = 0; i < N; i++) {
				if (splitted[i].length > 0) {
					nbV++;
				}
			}
			return nbV;
		}
		/**
		 * Extrait le numéro de vers présent en début de la strophe "str".
		 * Retourne le numéro de vers, ou -1 si aucun numéro trouvé.
		 * @param	str
		 * @return
		 */
		private function _extractFirstVerseNumber(str:String):int {
			var vd:int = -1;
			
			// RegExp : est-ce que la chaine commence par un ou plusieurs chiffres
			var exp:RegExp = /^\d+/;
			
			var arr:Array = str.match(exp);
			if (arr && arr.length > 0) {
				vd = int(arr[0]);
			}
			//_trace.debug("exp.test, résultat : " + exp.test(str) + ", vn : " + vn);
			return vd;
		}
		/**
		 * 
		 * @param	str
		 * @param	vd
		 * @return
		 */
		private function _deleteFirstVerseNumber(str:String, vd:int):String {
			return str.replace(String(vd), "");	
		}
		/**
		 * Vérifie s'il doit y avoir continuité dans la numérotation
		 * (vrai si l'un des parents de rep est de type "cont")
		 * @param	rep
		 * @return
		 */
		private function _checkContinuum(rd:RepData):Boolean {
			var cont:Boolean = false;
			var parentRd:RepData = rd.getRepParent();
			// Stoppe la recherche dès qu'on arrive en haut de l'arbo ou qu'on rencontre un rép "continu".
			while (parentRd != null && !cont) {
				//_trace.debug("parent.isContinuum : " + parentRd.isContinuum() + ", parentRd.title : " + parentRd.title);
				cont = parentRd.isContinuum();
				parentRd = parentRd.getRepParent();
			}
			
			var affichageDebug:String = "";
			if (parentRd) {
				affichageDebug = " - répertoire \"" + parentRd.rawTitle + "\"";
			}
			_trace.debug("_checkContinuum : " + cont + affichageDebug);
			/*
			if (parentRd) {
				_trace.debug("\t(la numérotation continue pour le répertoire " + parentRd.rawTitle + ")");
			}
			*/
			return cont;
		}
		/**
		 * Remise à zéro du continuum
		 */
		private function _razContinuum() {
			_trace.debug("_razContinuum (ancien : " + _continuum + ")");
			_continuum = 1;
		}
		
		/**
		 * Renvoi la prochaine unité sonore
		 * @return
		 */
		private function _getNextUS():USData {
			//_trace.debug("DEV._getNextUS");
			var us:USData;
			var indexUD:int = _mgr.currentUD.raw.childIndex();//position de l'US dans la liste des US
			var repXml:XML = _mgr.currentUD.raw.parent().parent(); //repertoire dans lequel se trouve la liste d'US de l'us en cours
			var rep:RepData = new RepData(repXml);
			
			var list:Array = new Array();
			list = rep.getUSList();
			var nbUS:int = list.length;
			//_trace.debug("US actuel = " + int(indexUD+1) + " sur " + nbUS + " US dans cette liste d'US");
			if (indexUD < nbUS - 1) { 
				// S'il y a des US à lire dans la liste d'US courants
				// -> continuité dans la numérotation par défaut.
				us = list[indexUD + 1];
			} else { 
				// Si l'US en cours était la dernière de la liste		
				// 
				var found:Boolean = false;
				var node:XML = rep.raw;
				var listRepParent:XMLList;

				
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
						
						// Si le repertoire dans lequel on se trouve n'est pas le dernier
						
						if (indexParent < nbRep-1) { 
							repXml = listRepParent[indexParent+1];
							rep = new RepData(repXml);
							
							
							// Tous les répertoires ayant un "ignoreNum" à "true" sont ignorés. 
							// Passe tous les réps du niveau jusqu'à trouver un rép à traiter.
							var ignoreNum:Boolean = true;
							var repIndex:int = indexParent + 1;
							while (ignoreNum && repIndex < nbRep - 1) {
								rep = new RepData(listRepParent[repIndex]);
								_trace.debug("Cherche répertoire sans ignoreNum - teste \"" + rep.rawTitle + "\", ignoreNum : " + rep.ignoreNum);
								
								
								ignoreNum = rep.ignoreNum;
								repIndex++;
							}
							
							// ##### -> Tester si ce répertoire doit être traité ? #####
							if(!rep.ignoreNum) {
								us = _mgr.searchRepFirstUS(rep);
								found = true;
							} else {
								_trace.debug("Trouvé répertoire ignoreNum - \"" + rep.rawTitle + "\"");
							}
						}
					}
					/**
					 * Vérifier si un RAZ du continuum est nécessaire. 
					 * si on a un type="cont" dans l'un des parents, pas de RAZ. Sinon, RAZ.
					 */
					if (!_checkContinuum(new RepData(node))) {
						//_trace.debug("DECLENCHE RAZ");
						_razContinuum();
					}
					
					// Remonte dans l'arbo
					node = node.parent();
				}
			}
			if (!us) {
				_trace.debug("Pas d'US à ouvrir - FIN.");
				_endProcess();
				
			} else {
				_mgr.openUS(us);
			}
			//
			return us;
		}
		
		/**
		 * 
		 */
		private function _endProcess() {
			_timer.stop();
			_echoCurrentDate();
			var docsDir:File = File.documentsDirectory;
			try	{
				docsDir.browseForSave("Save As");
				docsDir.addEventListener(Event.SELECT, _saveData);
			}
			catch (error:Error)	{
				trace("Failed:", error.message);
			}
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function _saveData(event:Event):void 
		{
			var newFile:File = event.target as File;
			if (!newFile.exists) {
				var stream:FileStream = new FileStream();
				stream.open(newFile, FileMode.WRITE);
				stream.writeUTFBytes(_mgr.raw);
				stream.close();
			}
		}

		/**
		 * 
		 */
		private function _echoCurrentDate() {
			var d:Date = new Date();
			var str:String = d.date + "/" + d.month + "/" + d.fullYear + ", " + d.hours + "h" + d.minutes + ":" + d.seconds;
			_trace.debug("CurrentDate : " + str);
		}
		
	}
	
}