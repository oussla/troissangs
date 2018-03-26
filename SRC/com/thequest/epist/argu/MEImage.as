package com.thequest.epist.argu {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.EDMedia;
	import com.thequest.tools.baseurl.BaseUrl;
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
	public class MEImage extends MediaElement {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _imgURL:URLRequest;
		private var _imgLoader:Loader;
		private var _image_bm:Bitmap;
		private var _imgIsLoaded:Boolean = false;
		private var _imgContainer:Sprite;
		private var _imgHeight:Number;
		private var _baseUrl:BaseUrl;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MEImage(p_ed:EDMedia) {
			super(p_ed);
			_baseUrl = BaseUrl.getInstance();
			_trace = SuperTrace.getTrace();
			_imgContainer = new Sprite();
			this.addChild(_imgContainer);
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
			this.loadImage();
		}
		/**
		 * Chargement 
		 */
		public function loadImage() {
			//_trace.debug("MEImage.loadImage : " + _ed.url);
			if (!_imgIsLoaded) {
				var lcontext:LoaderContext = new LoaderContext(true);
				_imgIsLoaded = true;
				_imgURL = new URLRequest(_ed.url);
				//_imgURL = new URLRequest(_ed.url);
				//trace("_imgUrl : " + _imgURL.url);
				_imgLoader = new Loader();
				_imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _imgLoaded);
				_imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _imgLoadError);
				_imgLoader.load(_imgURL, lcontext);
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _imgLoaded(evt:Event) {
			_image_bm = Bitmap(_imgLoader.content);
			_image_bm.smoothing = true;
			_imgContainer.alpha = 0;
			_imgContainer.addChild(_image_bm);
			//redimensionner si l'image est trop grande
			_resize(_zoneWidth, _zoneHeight);
			// Centre l'image dans la zone
			_imgContainer.x = Math.round((_zoneWidth - _imgContainer.width) / 2);
			_imgContainer.y = Math.round((_zoneHeight - _imgContainer.height) / 2);
			Tweener.addTween(_imgContainer, { alpha:1, time:0.5, transition:"easeOutQuart" } );
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _imgLoadError(evt:IOErrorEvent) {
			_trace.error("Erreur chargement image " + _ed.url);
		}
		/**
		 * 
		 */
		override public function clear() {
			//_trace.debug("MEImage.clear!");
			super.clear();
			if(_image_bm) {
				_image_bm.bitmapData.dispose();
			}
		}
	
		private function _resize(width:int, height:int):void {
			//trace("MEImage._resize : "+width+"x"+height);
			if (_imgContainer.height > _imgContainer.width) {
				_imgContainer.height = height;
				_imgContainer.scaleX = _imgContainer.scaleY;
				if (_imgContainer.width > width) {
					_imgContainer.width = width;
					_imgContainer.scaleY = _imgContainer.scaleX;
				}
			}
			else {
				_imgContainer.width = width;
				_imgContainer.scaleY = _imgContainer.scaleX;
				if (_imgContainer.height > height) {
					_imgContainer.height = height;
					_imgContainer.scaleX = _imgContainer.scaleY;
				}
			}
		}
	}
	
}