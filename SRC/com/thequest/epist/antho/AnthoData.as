package com.thequest.epist.antho {
	
	/**
	 * Stocke les données brutes de l'anthologie, pour une version de langue.
	 * @author nlgd
	 */
	public class AnthoData {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _raw:XML;
		private var _languageId:String;
		private var _language:String;
		//--------------------------------------------------
		//
		//		Contructor
		//
		//--------------------------------------------------
		public function AnthoData(p_raw:XML, p_langId:String, p_lang:String = "") {
			_raw = p_raw;
			_languageId = p_langId;
			_language = p_lang;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function get id():String {
			return _languageId.toLowerCase();
		}
		
		public function get language():String {
			return _language;
		}
		
		public function get raw():XML {
			return _raw;
		}
		
	}
	
}