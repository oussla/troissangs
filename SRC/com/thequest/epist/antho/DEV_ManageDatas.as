package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.nlgd.supertrace.SuperTraceStrictWindow;
	import com.thequest.epist.NavEvent;
	import com.thequest.epist.Translator;
	import com.thequest.epist.XMLLiteLoader;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import flash.filesystem.*;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class DEV_ManageDatas extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private const LANGUAGE:String = "fr";
		// Nombre total de vers à traiter. 0 pour arrêt automatique à la fin.
		private const TOTAL_US_COUNT:int = 0;//1100;
		private const ROOT_URL:String = "D:/Travaux/Epistemes/Dev/PUB/";
		//
		private var _trace:SuperTrace;
		private var _translator:Translator;
		private var _xmlLoader:XMLLiteLoader;
		private var _mgr:AnthoManager;
		private var _continuum:int = 1;
		private var _totalVerses:int = 0;
		private var _timer:Timer;
		private var _totalRepVerses:int = 0;
		private var _sound:Sound;
		private var _baseUrl:BaseUrl;
		//	
		public var superTraceWindow:SuperTraceStrictWindow;
		public var btnOpen:SimpleButton;
		public var btnSave:SimpleButton;
		public var btnCountProcess:SimpleButton;
		public var btnRepProcess:SimpleButton;
		public var btnSoundProcess:SimpleButton;
		public var strophe_tf:TextField;
		public var vd_tf:TextField;
		public var vnb_tf:TextField;
		public var vnbTotal_tf:TextField;
		public var sortie_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function DEV_ManageDatas() {
			_trace = SuperTrace.getTrace();
			_echoCurrentDate();
			_mgr = AnthoManager.getInstance();
			_translator = Translator.getInstance();
			_baseUrl = BaseUrl.getInstance();
			_baseUrl.setBaseUrl("./");
			//
			_timer = new Timer(50, TOTAL_US_COUNT);
			_timer.addEventListener(TimerEvent.TIMER, _timerHandler);
			//
			btnOpen.addEventListener(MouseEvent.CLICK, _openFileHandler);
			btnSave.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				_endProcess();
			});
			superTraceWindow.switchVisible();
		}
		
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		
		private function _openFileHandler(evt:MouseEvent) {
			var fileToOpen:File = new File();
			try {
				fileToOpen.browseForOpen("Open");
				fileToOpen.addEventListener(Event.SELECT, _fileSelected);
			}
			catch (error:Error)	{
				_trace.error("openFile Failed:" + error.message);
			}
			

		}
		/**
		 * 
		 * @param	event
		 */
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
		private function _timerHandler(evt:TimerEvent) {
			_nextUS();
		}
		/**
		 * Initialisation : ouvre la première US du premier répertoire.
		 */
		private function init() {
			btnCountProcess.addEventListener(MouseEvent.CLICK, _initCountProcess);
			btnRepProcess.addEventListener(MouseEvent.CLICK, _initRepProcess);
			btnSoundProcess.addEventListener(MouseEvent.CLICK, _initSoundProcess);
			
		}
		/**
		 * Démarre le process pour le comptage et numérotation des vers
		 * @param	evt
		 */
		private function _initCountProcess(evt:MouseEvent = null) {
			var rootNode:XML = _mgr.findNodeByPath([AnthoManager.COUCHANT]);
			var rd:RepData = new RepData(rootNode);
			//
			var us:USData = _mgr.searchRepFirstUS(rd);
			_mgr.openRepFirstUS(rd);
			_processUS(_mgr.currentUD);
			_timer.start();
		}
		/**
		 * Démarre le process de cumul des durées de rép
		 * @param	evt
		 */
		private function _initRepProcess(evt:MouseEvent = null) {
			// D'abord pour la partie COUCHANT
			var rootNode:XML = _mgr.findNodeByPath([AnthoManager.COUCHANT]);
			var rd:RepData = new RepData(rootNode);
			var cargo1:DEV_DataCargo = rd.processRepVersesNumber();
			//var count:int = rd.processRepVersesNumber();
			
			// Ensuite pour la partie LEVANT
			rootNode = _mgr.findNodeByPath([AnthoManager.LEVANT]);
			rd = new RepData(rootNode);
			var cargo2:DEV_DataCargo = rd.processRepVersesNumber();
			//
			var vnb:int = cargo1.vnb + cargo2.vnb;
			var rlen:Number = cargo1.len + cargo2.len;
			_trace.debug("result : vnb:" + vnb + ", rlen:" + rlen);
			
		}
		/**
		 * Process de relevé des durées des sons
		 * @param	evt
		 */
		private function _initSoundProcess(evt:MouseEvent = null) {
			var rootNode:XML = _mgr.findNodeByPath([AnthoManager.COUCHANT]);
			var rd:RepData = new RepData(rootNode);
			//
			var us:USData = _mgr.searchRepFirstUS(rd);
			_mgr.openRepFirstUS(rd);
			_processUSSound(_mgr.currentUD);			
		}
		
		/**
		 * Passage à l'US suivante.
		 */
		private function _nextUS() {
			/*
			//	Trace des URLs des fichiers
			var us:USData = _mgr.gotoNextUS();
			if(us) {
				_traceSoundName(us);
			}
			*/
			
			
			//	Numérotation des vers
			var us:USData = this._getNextUS();
			if(us) {
				_processUS(us);
			}
			
			
		}
		/**
		 * 
		 * @param	us
		 */
		private function _traceSoundName(us:USData) {
			_trace.debug(us.soundURL);
		}
		/**
		 * Traitement des unités de son pour relevé des durées
		 */
		private function _nextSoundProcess() {
			var us:USData = _mgr.gotoNextUS();
			if (us) {
				_processUSSound(us);
			} else {
				_trace.debug("End of soundProcess.");
			}
		}
		
		private function _processUSSound(us:USData) {
			_loadSound(ROOT_URL + us.soundURL);
		}
		
		private function _loadSound(filename) {
			_sound = new Sound();
			_sound.addEventListener(Event.COMPLETE, _soundLoadComplete);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, _soundError);
			_sound.load(new URLRequest(filename));
		}
		
		private function _soundLoadComplete(evt:Event) {
			var us:USData = _mgr.currentUD;
			_trace.debug("_soundLoadComplete : " + _mgr.currentUD.soundURL + ", duree : " + _sound.length);
			// Arrondi la durée aux centièmes de secondes, et stocke une valeur en secondes.
			var len:Number = Math.round(_sound.length / 10)/100;
			us.saveSoundLength(len);
			_nextSoundProcess();
		}
		
		private function _soundError(evt:IOErrorEvent) {
			_trace.error("ERREUR : son introuvable : " + evt.text);
			_nextSoundProcess();
		}
		
		
		/**
		 * Traitement d'une Unité de Son (pour comptage des vers)
		 * @param	us
		 * 
		 */
		private function _processUS(us:USData) {
			// Si la numérotation existe déjà ET vaut 0, ne pas traiter.
			if (us.firstVerseNumber != 0) {
				var vn,vnBis:int;
				var vd:int;
				
				vn = us.firstVerseNumber;
				vnBis = _extractFirstVerseNumber(us.strophe);
				if (vn == -1) {
					// Si pas dispo, prend le numéro extrait du début de la strophe
					vn =  vnBis;
				}
				
				if (vn == -1) {
					// Si aucun numéro de vers n'a pu être relevé, reprend le continuum.
					vd = _continuum;
				} else {
					// Si on a relevé un n° de vers, on garde cette valeur. Le continuum est repris à partir de cette valeur relevée.
					vd = vn;
					_continuum = vd;
					us.saveStrophe(_deleteFirstVerseNumber(us.strophe, vd));
				}
				
				var vnb:int = _countVerses(us.strophe);
				_continuum += vnb;
				// Nombre de vers total
				_totalVerses += vnb;
				// Nombre de vers du répertoire en cours
				_totalRepVerses += vnb;
				
				us.saveVersesDatas(vd, vnb);
				
				// Affichage...
				strophe_tf.text = us.strophe;
				vd_tf.text = String(_continuum);
				vnb_tf.text = String(vnb);
				vnbTotal_tf.text = String(_totalVerses);
				//_trace.debug("--- us.firstVerse : " + us.firstVerseNumber + ", vn relevé : " + vn + ", vd calculé : " + vd + ", nb vers : " + vnb + " - \"" + us.getBegin() + "...\"");
			} else {
				_trace.debug("Strophe non comptabilisée : \"" + us.getBegin() + "...\"");
				
			}
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
				// Indique si le noeud était le dernier du niveau
				var isLastLevelNode:Boolean = false;

				
				while (!found && node != null) {
					isLastLevelNode = false;
					
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
								//_trace.debug("Cherche répertoire sans ignoreNum - teste \"" + rep.rawTitle + "\", ignoreNum : " + rep.ignoreNum);
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
						} else {
							isLastLevelNode = true;
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
					
					if (isLastLevelNode) {
						rep = new RepData(node);
						_trace.debug("isLastLevelNode:" + isLastLevelNode + " (" + rep.rawTitle + ")");
						rep.setVersesDatas(-1, _totalRepVerses);
						_totalRepVerses = 0;
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
			if(_timer) {
				_timer.stop();
			}
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