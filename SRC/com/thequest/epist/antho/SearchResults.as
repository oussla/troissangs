package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	
	/**
	 * Conteneur pour les résultats de recherche
	 * @author nlgd
	 */
	public class SearchResults {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		public static const SEARCH_STRING:String = "searchString";
		public static const SEARCH_VERSE:String = "searchVerse";
		//
		private var _trace:SuperTrace;
		private var _usList:Array;
		private var _searchType:String;
		private var _rd:RepData;
		//
		public var pattern:String = "";
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function SearchResults() {
			_usList = new Array();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Ajoute une US à la liste
		 * @param	us
		 */
		public function addUs(us:USData) {
			_usList.push(us);
		}
		/**
		 * Fusionne avec le SR passé en paramètre. Ne fait rien si sr vaut null.
		 * @param	sr
		 */
		public function fusion(sr:SearchResults) {
			if (sr) {
				_usList = _usList.concat(sr.list);
			}
		}
		/**
		 * Renvoi la liste des US
		 */
		public function get list():Array {
			return _usList;
		}
		
		public function get resultsCount():int {
			var count:int = 0;
			if (_usList) count = _usList.length;
			return count;
		}
		/**
		 * 
		 */
		public function set searchType(type:String) {
			_searchType = type;
		}
		public function get searchType():String {
			return _searchType;
		}
		/**
		 * 
		 */
		public function set repData(p_rd:RepData) {
			_rd = p_rd;
		}
		public function get repData():RepData {
			return _rd;
		}
		
	}
	
	
}