package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	/**
	 * ...
	 * @author nlgd
	 */
	public class EDEtape extends ElementData {
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
		public function EDEtape(p_raw:XML, p_index:int = 0) {
			super(p_raw, p_index);
			_trace = SuperTrace.getTrace();
			//_trace.debug("Hello EDEtape !");
			_activeLink = !this.isTitle;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function get isTitle():Boolean {
			var yesItIs:Boolean = false;
			if (_raw.TYPE_ETAPE == "0") 
				yesItIs = true;
			return yesItIs;
		}
		
	}
	
}