package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import caurina.transitions.Tweener;
	import com.thequest.epist.antho.MediaEvent;
	
	public class MiniObject extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _id:int;
		private var _filename:String;
		private var _imgLoader:Loader;
		private var _image_bm:Bitmap;
		private var _container:Sprite;
		private var _isLoaded:Boolean = false;
		
		public static const WIDTH_MAX_MINI:int = 120;
		public static const HEIGHT_MAX_MINI:int = 75;
		public static const MARGE:int = 10;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MiniObject(id:int, url:String) {
			_trace = SuperTrace.getTrace();
			//_trace.info("* Hello MiniObject");
			_filename = url;
			_id = id;
			this.visible = true;
			_container = new Sprite();
			this.addChild(_container);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------			
		
		public function load() {
			//_trace.debug("MiniObject.load, filename = " + _filename);
			loadImage(_filename);
		}
		
		
		private function loadImage(filename:String) {
			//_trace.debug("MiniObject.loadImage");
			var imgURL = new URLRequest(filename);
			_imgLoader = new Loader();
			_imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoaded);
			_imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imgLoadError);
			_imgLoader.load(imgURL);
		}
		
		private function imgLoaded(evt:Event) {
			//_trace.debug("MiniObject.imgLoaded");
			_image_bm = Bitmap(_imgLoader.content);
			_image_bm.smoothing = true;
			_image_bm.x = 0;
			_image_bm.y = 0;
			_container.addChild(_image_bm);
			resize(_container, MiniObject.WIDTH_MAX_MINI, MiniObject.HEIGHT_MAX_MINI);
			_isLoaded = true;
			this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_LOADED));
		}
		
		private function imgLoadError(evt:IOErrorEvent) {
			_trace.error("Erreur chargement image " + _filename);
		}
		
		private function resize(container:Sprite, width:int, height:int):void {
			//_trace.info("* MiniObject.resize");
			if (container.height > container.width) {
				container.height = height;
				container.scaleX = container.scaleY;
				if (container.width > width) {
					container.width = width;
					container.scaleY = container.scaleX;
				}
			}
			else {
				container.width = width;
				container.scaleY = container.scaleX;
				if (container.height > height) {
					container.height = height;
					container.scaleX = container.scaleY;
				}
			}
		}
		
		public function get id():int {
			return _id;
		}
		
		public function get isLoaded():Boolean {
			return _isLoaded;
		}
	}
}