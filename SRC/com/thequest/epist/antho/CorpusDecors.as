package com.thequest.epist.antho {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CorpusDecors extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _visibleDecor:MovieClip;
		//
		public var decor_couchant:MovieClip;
		public var decor_levant:MovieClip;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function CorpusDecors() {
			_trace = SuperTrace.getTrace();
			
			
			decor_couchant.visible = false;
			decor_levant.visible = false;
			
			
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Affiche le décor correspondant au corpus "id"
		 * @param	id
		 */
		public function showCorpus(id:int) {
			//_trace.debug("CorpusDecors.showCorpus(" + id + ")");
			var decor:MovieClip;
			switch(id) {
				case AnthoManager.COUCHANT:
					decor = decor_couchant;
					break;
				case AnthoManager.LEVANT:
					decor = decor_levant;
					break;
			}
			decor.visible = true;
			this.addChild(decor);
			Tweener.addTween(decor, {alpha:1, time:0.8, transition:"easeOutQuart" } );
			
			/*
			
			switch(id) {
				case AnthoManager.COUCHANT:
					decor_couchant.visible = true;
					decor_levant.visible = false;
					break;
				case AnthoManager.LEVANT:
					decor_couchant.visible = false;
					decor_levant.visible = true;
					break;
			}
			*/
			
		}
		/**
		 * 
		 */
		public function backToNormal() {
			Tweener.addTween(decor_couchant, {alpha:0, time:0.8, transition:"easeOutQuart" } );
			//decor_couchant.visible = false;
			Tweener.addTween(decor_levant, {alpha:0, time:0.8, transition:"easeOutQuart" } );
			//decor_levant.visible = false;
		}
	}
	
}