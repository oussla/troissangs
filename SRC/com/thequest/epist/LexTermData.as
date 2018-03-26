package com.thequest.epist {
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class LexTermData {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _raw:XML;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function LexTermData(p_raw:XML) {
			_raw = p_raw;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Renvoi le terme de lexique
		 */
		public function get term():String {
			return _raw.dt;
		}
		/**
		 * Renvoi la définition du terme
		 */
		public function get definition():String {
			return _raw.dd;
		}
		/**
		 * Renvoi la première lettre du terme
		 */
		public function get letter():String {
			return this.term.charAt(0);
		}		
	}
	
}