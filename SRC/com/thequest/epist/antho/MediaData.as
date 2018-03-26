package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.Urlizer;
	import com.thequest.tools.baseurl.BaseUrl;
	/**
	 * ...
	 * @author nlgd
	 */
	public class MediaData {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _raw:XML;
		private var _trace:SuperTrace;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MediaData(p_raw:XML) {
			_raw = p_raw;
			_trace = SuperTrace.getTrace();
			//_trace.debug("Hello MediaData!");
			//_trace.debug("XML = \n"+p_raw);
			
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Renvoi l'url du fichier à charger
		 */
		public function get url():String {
			/*
			var url:String = _raw.FICHIER;
			var reg:RegExp = /:/g;
			url = url.replace(reg, "/");
			var reg2:RegExp = /\\/g;
			url = url.replace(reg2, "/");
			return BaseUrl.getInstance().BASE + "data/" + url;
			//return "data/" + url;
			*/
			return Urlizer.urlize("data/" + _raw.FICHIER);
		}
		
		/**
		 * Type de média. A définir d'après les 3 derniers caractères du getter "url".
		 */
		public function get typeMedia():String {
			var type:String;
			var indexPoint:int;
			indexPoint = url.lastIndexOf(".");
			type = url.substring(indexPoint + 1).toLowerCase();
			return type;
		}
		/**
		 * Renvoi la légende
		 */
		public function get legend():String {
			return _raw.LEGENDE;
		}
		
		/**
		 * Dans le cas d'un video, la miniature porte le meme nom mais pas la meme extension
		 */
		public function get mediaName():String {
			var name:String;
			var indexPoint:int;
			indexPoint = url.indexOf(".");
			name = url.substring(0, indexPoint);
			return name;
		}	
	}
	
}