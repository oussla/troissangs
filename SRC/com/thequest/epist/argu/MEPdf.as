package com.thequest.epist.argu {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.AppNav;
	import com.thequest.epist.EDMedia;
	import com.thequest.epist.Translator;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import mdm.*;
	import flash.net.URLRequest;
	import flash.net.*;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MEPdf extends MediaElement {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _container:Sprite;
		private var _baseUrl:BaseUrl;
		
		public var pdf_btn:SimpleButton;
		public var legend_tf:TextField;
		
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MEPdf(p_ed:EDMedia) {
			super(p_ed);
			_baseUrl = BaseUrl.getInstance();
			_trace = SuperTrace.getTrace();
			legend_tf.text = Translator.getInstance().translate("open_pdf");
			pdf_btn.addEventListener(MouseEvent.CLICK, _onBtnClick);
			/*
			pdf_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				//navigateToURL(new URLRequest(_ed.url), "_blank");
				mdm.System.exec(_baseUrl.BASE+_ed.url);
				//mdm.System.exec(_ed.url);
				//trace(_baseUrl.BASE+_ed.url);
				
				var pdfDoc:String = _ed.url;
				pdfDoc = 
				navigateToURL(new URLRequest(_baseUrl.BASE+_ed.url), "_blank");
			});
			*/
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private function _onBtnClick(evt:MouseEvent):void {
			var pdfDoc:String = _ed.url;
			// replace all blank spaces
			var pattern:RegExp = / /g;
			pdfDoc = pdfDoc.replace(pattern, "-");
			
			AppNav.getInstance().setWindowed();
			
			var appFilename:String = mdm.Application.filename;
			if (appFilename) {
				mdm.System.exec(pdfDoc);
			} else {
				navigateToURL(new URLRequest(pdfDoc), "_blank");
			}
			
			//navigateToURL(new URLRequest(_baseUrl.BASE+_ed.url), "_blank");
		}
		/**
		 * Ecrase la fonction d'init.
		 */
		override public function init() {
			pdf_btn.addEventListener(MouseEvent.CLICK, _onBtnClick);
			super.init();
		}

		override public function clear() {
			pdf_btn.removeEventListener(MouseEvent.CLICK, _onBtnClick);
			super.clear();
		}
	}
	
}