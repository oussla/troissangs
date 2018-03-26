package com.thequest.epist.argu {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.BasicFormat;
	import com.thequest.epist.EDMedia;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MESon extends MediaElement {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _container:Sprite;
		private var _baseUrl:BaseUrl;		
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MESon(p_ed:EDMedia) {
			super(p_ed);
			_trace = SuperTrace.getTrace();
			_baseUrl = BaseUrl.getInstance(); //url à charger géré dans MediaElement
			_container = new Sprite();
			/*
			_container.graphics.beginFill(0x982343);
			_container.graphics.drawRect(0, 0, 20, 5);
			_container.graphics.endFill();
			*/
			this.addChild(_container);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Ecrase la fonction d'init.
		 */
		override public function init() {
			super.init();
		}

		override public function clear() {
			super.clear();
		}
	}
	
}