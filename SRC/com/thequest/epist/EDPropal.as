package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	/**
	 * ...
	 * @author nlgd
	 */
	public class EDPropal extends ElementData {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function EDPropal(p_raw:XML, p_index:int = 0) {
			super(p_raw, p_index);
			_trace = SuperTrace.getTrace();
			//_trace.debug("Hello EDPropal !");
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function get level():int {
			return _raw.NIVEAU;
		}
		public function get order():int {
			return _raw.ORDRE;
		}
		public function get P():String {
			return "P" + " " + level + "-" + order;
		}
		public function get comment():String {
			return _raw.COMMENTAIRE;
		}
	}
	
}