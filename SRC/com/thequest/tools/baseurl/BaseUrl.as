package com.thequest.tools.baseurl {
	
	/**
	 * ...
	 * @author nlgd
	 */
	import com.nlgd.supertrace.SuperTrace;
	
	public class BaseUrl {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _instance:BaseUrl;
		//
		private var _trace:SuperTrace;
		private var _baseUrl:String = "../";
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():BaseUrl {
			if (_instance == null) {
				_instance = new BaseUrl(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function BaseUrl(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use BaseUrl.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.info("Hello BaseUrl !");
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Définit l'url de base
		 * @param	p_base
		 */
		public function setBaseUrl(p_base:String) {
			_baseUrl = p_base;
		}
		/**
		 * 
		 */
		public function get BASE():String {
			return _baseUrl;
		}
	}
}

internal class SingletonBlocker {}