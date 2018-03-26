package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	/**
	 * ...
	 * @author nlgd
	 */
	public class EDArticle extends ElementData {
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
		public function EDArticle(p_raw:XML, p_index:int = 0) {
			super(p_raw, p_index);
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello EDArticle !");
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		
	}
	
}