package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class Lexique extends EventDispatcher {
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private static var _instance:Lexique;
		//
		private var _trace:SuperTrace;
		private var _raw:XML;
		private var _openingLtData:LexTermData;
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():Lexique {
			if (_instance == null) {
				_instance = new Lexique(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function Lexique(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use Lexique.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.info("Hello Lexique !");
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Initialisation. Reçoit les données XML brutes.
		 * @param	p_raw
		 */
		public function init(p_raw:XML) {
			trace("Lexique -> init");
			_raw = p_raw;
			this.dispatchEvent(new LexiqueEvent(LexiqueEvent.READY));
		}
		/**
		 * Renvoi la définition de la chaine "term"
		 * @param	term
		 * @return
		 */
		public function getDef(term:String):String {
			var def:String;
			var defList:XMLList;
			defList = _raw.lu.(dt == term);
			if (defList.length() > 0) {
				def = defList[0].dd;
			} else {
				def = "";
				//"-- pas de définition pour \"" + term + "\" dans le lexique --";
			}
			return def;
		}
		/**
		 * Renvoi un objet LexTermData pour le terme "term" demandé
		 * @param	term
		 * @return
		 */
		public function getTermData(term:String):LexTermData {
			var ltData:LexTermData;
			var defList:XMLList;
			defList = _raw.lu.(dt == term);
			if (defList.length() > 0) {
				ltData = new LexTermData(defList[0]);
			}
			return ltData;
		}
		/**
		 * Demande l'ouverture de la définition d'un terme
		 * @param	term
		 */
		public function openDef(term:String) {
			if (defExists(term)) {
				_openingLtData = getTermData(term);
				this.dispatchEvent(new Event(Event.OPEN));
			}
		}
		/**
		 * Renvoi le ltData dont l'ouverture a été demandée
		 */
		public function get openingLtData():LexTermData {
			return _openingLtData;
		}
		/**
		 * Renvoi la liste des termes commençant par "letter", ou la liste complète si "letter" n'est pas définie.
		 * @param	letter
		 * @return	la liste des termes
		 */
		public function getTermsList(letter:String):Array {
			var terms:Array = new Array();
			if (!letter) letter = "a";
			letter = letter.toLowerCase();
			
			var tList:XMLList = _raw.lu.(dt.toString().charAt(0) == letter);
			//_trace.debug("Lexique.getTermsList(" + letter + ") : Trouvé " + tList.length() + " termes commençant par " + letter);
			
			var N:int = tList.length();
			for (var i:int = 0; i < N; i++) {
				var ltData:LexTermData = new LexTermData(tList[i]);
				terms.push(ltData);
			}
			
			
			return terms;
		}
		/**
		 * Indique si le terme "term" a une définition dans le lexique
		 * @param	term
		 * @return
		 */
		public function defExists(term:String):Boolean {
			var exists:Boolean;
			var defList:XMLList;
			defList = _raw.lu.(dt == term);
			exists = defList.length() > 0;
			return exists;
		}
	}	
}

internal class SingletonBlocker {}