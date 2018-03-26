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
	
	public class ImageObject extends MediaObject	{
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _imgContainer:Sprite;
		private var _imgFilename:String;
		private var _imgLoader:Loader;
		private var _image_bm:Bitmap;
		private var _isLoaded:Boolean = false;
		//
		public var heightContainer:int;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function ImageObject() {
			_trace = SuperTrace.getTrace();
			//_trace.info("* Hello ImageObject");
			this.visible = false;
			this.alpha = 0;
			_imgContainer = new Sprite();
			//_miniContainer = new Sprite();
			this.addChild(_imgContainer);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------	
		override public function setContentUrl(filename:String) {
			//_trace.debug("ImageObject.SetContentUrl override");
			_imgFilename = filename;
		}
		
		override public function load() {
			//_trace.debug("ImageObject.load override, filename = " + _imgFilename);
			if (!_isLoaded) {
				//_trace.debug("Charge l'image");
				loadImage(_imgFilename);
			}
			else {
				//_trace.debug("Déja chargée!");
				this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_LOADED));	
			}
		}
		
		private function loadImage(filename:String) {
			_trace.debug("ImageObject.loadImage : " +filename);
			var imgURL = new URLRequest(filename);
			_imgLoader = new Loader();
			_imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoaded);
			_imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imgLoadError);
			_imgLoader.load(imgURL);
		}
		
		private function imgLoaded(evt:Event) {
			//_trace.debug("ImageObject.imgLoaded");
			_isLoaded = true;
			_image_bm = Bitmap(_imgLoader.content);
			_image_bm.smoothing = true;
			_image_bm.x = 0;
			_image_bm.y = 0;
			_imgContainer.addChild(_image_bm);
			resize(_imgContainer, MediaObject.WIDTH_MAX_MEDIA, MediaObject.HEIGHT_MAX_MEDIA);
			centre(_imgContainer, MediaObject.WIDTH_MAX_MEDIA);
			heightContainer = _imgContainer.height;
			this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_LOADED));	
		}
		
		private function imgLoadError(evt:IOErrorEvent) {
			_trace.error("Erreur chargement image " + _imgFilename);
		}

		override public function show() {
			//_trace.debug("ImageObject.show override");
			this.visible = true;
			Tweener.addTween(this, { alpha:1, time:1, transition:"easeOutQuart" } );
			trace(_imgFilename);
		}
		
		override public function hide() {
			//_trace.debug("ImageObject.hide override");
			Tweener.addTween(this, {alpha:0, time:1, transition:"easeOutQuart"});
		}
		
		
		private function centre(container:Sprite, widthMax:int):void {
			container.x = (widthMax / 2) - (container.width / 2);
		}
		
		private function resize(container:Sprite, width:int, height:int):void {
			//_trace.info("* ImageObject.resize");
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
		
		public function get hauteur():int {
			return heightContainer;
		}
	}
}