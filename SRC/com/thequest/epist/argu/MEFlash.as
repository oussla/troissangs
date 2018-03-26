package com.thequest.epist.argu {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.antho.SoundManager;
	import com.thequest.epist.EDMedia;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.Bitmap;
    import flash.display.BitmapData;	
	import flash.display.Sprite;
	import flash.system.LoaderContext;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MEFlash extends MediaElement {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _imgURL:URLRequest;
		private var _swfLoader:Loader;
		private var _swf:DisplayObject;
		private var _imgIsLoaded:Boolean = false;
		private var _container:Sprite;
		private var _baseUrl:BaseUrl;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MEFlash(p_ed:EDMedia) {
			super(p_ed);
			_trace = SuperTrace.getTrace();
			_container = new Sprite();
			_baseUrl = BaseUrl.getInstance();
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
			this.loadMedia();
		}
		/**
		 * Chargement 
		 */
		public function loadMedia() {
			_trace.debug("MEFlash.loadMedia : " + _ed.url);
			if (!_imgIsLoaded) {
				var lcontext:LoaderContext = new LoaderContext(true);
				_imgIsLoaded = true;
				_imgURL = new URLRequest(_ed.url);
				_swfLoader = new Loader();
				_swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _imgLoaded);
				_swfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _imgLoadError);
				_swfLoader.load(_imgURL, lcontext);
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _imgLoaded(evt:Event) {
			/*
			_image_bm = Bitmap(_swfLoader.content);
			_image_bm.smoothing = true;
			_container.alpha = 0;
			_container.addChild(_image_bm);
			// Centre l'image dans la zone
			_container.x = Math.round((_zoneWidth - _container.width) / 2);
			Tweener.addTween(_container, { alpha:1, time:0.5, transition:"easeOutQuart" } );
			*/
			_swf = _swfLoader.content as DisplayObject;
			_container.alpha = 0;
			_container.addChild(_swf);
			
			Tweener.addTween(_container, { alpha:1, time:0.5, transition:"easeOutQuart" } );
			
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _imgLoadError(evt:IOErrorEvent) {
			_trace.error("Erreur chargement SWF : " + _ed.url);
		}
		/**
		 * 
		 */
		override public function clear() {
			_trace.debug("MEFlash.clear");
			super.clear();
			if(_swf && _container.contains(_swf)) {
				_container.removeChild(_swf);
			}
			// Fait appel au SoundManager pour arrêter tous les sons 
			// (on n'a pas moyen d'arrêter autrement les sons de l'anim chargée, vu qu'on n'a pas les sources)
			var mgr:SoundManager = SoundManager.getInstance();
			mgr.stopAllSounds();
		}
		
	}
	
}