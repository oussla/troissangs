package com.thequest.epist {
	import caurina.transitions.PropertyInfoObj;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.events.EventDispatcher;
	import com.nlgd.supertrace.SuperTrace;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.Event;

	public class Translator extends EventDispatcher {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _instance:Translator = null;
		private var _trace:SuperTrace;
		private var _xmlFileName:String;
		private var _loader:URLLoader;
		private var _request:URLRequest;
		private var _xml:XML;
		private var _language:String;
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():Translator {
			if (_instance == null) {
				_instance = new Translator(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function Translator(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use Translator.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.info("Hello Translator !");
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------	
		public function init(language:String):void {
			_trace.debug("Translator.init(" + language + ")");
			_language = language;
			_xmlFileName = BaseUrl.getInstance().BASE + "appdata/" + language + "/lang.xml";
			_trace.debug("Fichier de langue : " + _xmlFileName);
			loadXmlFile(_xmlFileName);
		}
		
		
		/**
		 * chargement du fichier de langue
		 * @param	filename
		 */
		public function loadXmlFile(filename:String):void {
			//_trace.info("Translator.loadXmlFile");
			_request = new URLRequest(_xmlFileName);
			_loader = new URLLoader();
			_loader.load(_request);
			_loader.addEventListener(Event.COMPLETE, onComplete);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, _xmlHTTPStatus);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, _xmlLoadError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _xmlSecurityError);
		}
		 
		public function onComplete(event:Event):void {
			//_trace.info("Fichier xml chargé");//quand le fichier de langue est chargé on peut continuer la suite
			_xml = new XML(_loader.data);
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Méthodes de gestion des erreurs de chargement du fichier xml
		 */
		private function _xmlLoadError(evt:IOErrorEvent) {
			_trace.error("Translator._xmlLoadError : " + evt.text + "(url : " + _xmlFileName + ")");
		}
		private function _xmlHTTPStatus(evt:HTTPStatusEvent) {
			//_trace.error("_xmlHTTPStatus : " + evt.status);
		}
		private function _xmlSecurityError(evt:SecurityErrorEvent) {
			_trace.error("Translator._xmlSecurityError : " + evt.text);
		}
		
		/**
		 * Traduction d'une chaine
		 * @param	word
		 * @return
		 */
		public function translate(word:String):String {
			//_trace.debug("Translator.translate(" + word + ")");
			var wordToReturn:String;
			if(_xml) {
				wordToReturn = _xml.tu.(@id == word);
			}
			if (!wordToReturn) wordToReturn = word;
			return wordToReturn;
		}
		
		public function get language():String {
			return _language;
		}
	}
}

internal class SingletonBlocker {}