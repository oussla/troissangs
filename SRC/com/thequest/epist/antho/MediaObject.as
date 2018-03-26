package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import caurina.transitions.Tweener;
	
	public class MediaObject extends Sprite	{
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
		//
		public static const WIDTH_MAX_MEDIA:int = 455;
		public static const HEIGHT_MAX_MEDIA:int = 402;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MediaObject() {
			_trace = SuperTrace.getTrace();
			_imgContainer = new Sprite();
			this.addChild(_imgContainer);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------	
		public function load() {
			//_trace.debug("MediaObject.load");
		}
		
		public function show() {
			//_trace.debug("MediaObject.show");
		}
		
		public function hide() {
			//_trace.debug("MediaObject.hide");
		}
		
		public function setContentUrl(filename:String) {
			//_trace.debug("MediaObject.SetContentUrl");
		}		
	}
	
	
}