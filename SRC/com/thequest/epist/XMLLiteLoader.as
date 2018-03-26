package com.thequest.epist {	
	import com.nlgd.supertrace.SuperTrace;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author nlgd
	 */
	public class XMLLiteLoader extends EventDispatcher {
		
		private var _trace:SuperTrace;
		private var _loader:URLLoader;
		private var _request:URLRequest;
		private var _filename:String;
		private var _xml:XML;
		
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function XMLLiteLoader () {
			_trace = SuperTrace.getTrace();
			//_trace.debug("Hello XMLLiteLoader !");
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Chargement de la liste d'articles
		 * @param	filename
		 */
		public function load(filename:String):void {
			_request = new URLRequest(filename);
			_loader = new URLLoader();
			_filename = filename;
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
			try {
				_xml = new XML(_loader.data);
				this.dispatchEvent(event);
			}catch (e:Error) {
				_trace.error("XMLLiteLoader : Erreur sur création du XML à partir de " + _filename + " / " + e.message );
			}
			
		}
		
		/**
		 * Méthodes de gestion des erreurs de chargement du fichier xml
		 */
		private function _xmlLoadError(evt:IOErrorEvent) {
			_trace.error("_xmlLoadError : " + evt.text + "(" + _filename + ")");
		}
		private function _xmlHTTPStatus(evt:HTTPStatusEvent) {
			//_trace.error("_xmlHTTPStatus : " + evt.status);
		}
		private function _xmlSecurityError(evt:SecurityErrorEvent) {
			_trace.error("_xmlSecurityError : " + evt.text);
		}
		
		/**
		 * Accès au XML
		 */
		public function get xml():XML {
			return _xml;
		}
		
		
		
	}
	
}