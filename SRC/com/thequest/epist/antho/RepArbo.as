package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class RepArbo extends Sprite {
		
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _rootNode:XML;
		private var _rootRD:RepData;
		private var _corpus:int;
		
		public function RepArbo(p_firstNodeIndex:int) {
			_trace = SuperTrace.getTrace();
			_corpus = p_firstNodeIndex;
			this.visible = false;
			_mgr = AnthoManager.getInstance();
			//
			_rootNode = _mgr.findNodeByPath([p_firstNodeIndex]);
			_createArbo(_rootNode);
		}
		
		private function _createArbo(rn:XML) {
			var i, N:int;
			var firstRep:RepButton = new RepButton(new RepData(rn), _corpus);
			this.addChild(firstRep);
			//firstRep.develop();
		}
		
		public function show() {
			this.visible = true;
		}
		
		public function hide() {
			this.visible = false;
		}
		
	}
	
}