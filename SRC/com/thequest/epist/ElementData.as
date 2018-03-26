package com.thequest.epist {
	/**
	 * ...
	 * @author nlgd
	 */
	public class ElementData {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		protected var _raw:XML;
		protected var _id:int;
		protected var _listIndex:int;
		protected var _title:String;
		protected var _activeLink:Boolean = true;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function ElementData(p_raw:XML, p_index:int = 0) {
			_raw = p_raw;
			_listIndex = p_index;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 */
		public function get title():String {
			return _raw.TITRE;
		}
		/**
		 * 
		 */
		public function get id():int {
			return _raw.@id;
		}
		/**
		 * 
		 */
		public function get listIndex():int {
			return _listIndex;
		}
		/**
		 * Indique si cet ElementData fait l'objet d'un lien actif (ou s'il est juste un titre)
		 */
		public function get activeLink():Boolean {
			return _activeLink;
		}
		/**
		 * Renvoi les données brutes en XML
		 */
		public function get raw():XML {
			return _raw;
		}
		
		
	}
	
}