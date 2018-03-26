package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.tools.baseurl.BaseUrl;
	import mdm.*;
	/**
	 * ...
	 * @author nlgd
	 */
	public class EDMedia extends ElementData {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		public static const TYPE_IMAGE:String = "image";
		public static const TYPE_VIDEO:String = "video";
		public static const TYPE_SWF:String = "swf";
		public static const TYPE_SON:String = "son";
		public static const TYPE_PDF:String = "pdf";
		public static const TYPE_SWF_FLUTES:String = "swf_flutes";
		public static const TYPE_SWF_PROFERATION:String = "swf_proferation";
		private var _trace:SuperTrace;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function EDMedia(p_raw:XML, p_index:int = 0) {
			super(p_raw, p_index);
			_trace = SuperTrace.getTrace();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function get typeMedia():String {
			var type:String;
			var fileList:XMLList = new XMLList(_raw.FICHIER);
			if (fileList.length() > 0) {
				var rawType:String = new String(fileList[0].TYPE);
				switch(rawType) {
					case "IMAGE":
						type = EDMedia.TYPE_IMAGE;
						break;
					case "VIDEO":
						type = EDMedia.TYPE_VIDEO;
						break;
					case "FLASH":
						type = EDMedia.TYPE_SWF;
						break;
					case "SON":
						type = EDMedia.TYPE_SON;
						break;
					case "PDF":
						type = EDMedia.TYPE_PDF;
						break;
					case "SWF_FLUTES":
						type = EDMedia.TYPE_SWF_FLUTES;
						break;
					case "SWF_PROFERATION":
						type = EDMedia.TYPE_SWF_PROFERATION;
						break;
				}
				
			}
			return type;			
		}
		
		public function get url():String {
			var urlStr:String;
			var fileList:XMLList = new XMLList(_raw.FICHIER);
			if (fileList.length() > 0) {
				
				var rawStr:String = fileList[0].ADRESSE;
				var regExp:RegExp;
				var separator:String = "/";
				
				/*
				var myAppPath:String = mdm.Application.path;
				if (myAppPath) {
					separator = "\\";
					regExp = /\//g;
					rawStr = rawStr.replace(regExp, "\\");
				} else {
					separator = "/";
					regExp = /\\/g;
					rawStr = rawStr.replace(regExp, "/");
				}
				*/
				
				switch(this.typeMedia) {
					case TYPE_VIDEO:
						urlStr = "data" + separator + "video" + separator + rawStr;
						break;
					case TYPE_PDF:
						urlStr = "data" + separator + "fichier" + separator + rawStr;
						break;
					default:
						urlStr = "data" + separator + rawStr;
					
				}
				
				
				//urlStr = BaseUrl.getInstance().BASE + urlStr;
				urlStr = Urlizer.urlize(urlStr);
				
				/*
				if (this.typeMedia == "video")
					urlStr = "data/video/" + rawStr;
				else
					urlStr = "data/" + rawStr;		
				*/
			}
			_trace.debug("EDMedia -> url : " + urlStr);
			return urlStr;
		}
		
		public function get legend():String {
			return _raw.LEGENDE;
		}
		
		public function get soundUrl():String {
			var urlStr:String = null;
			var fileList:XMLList = new XMLList(_raw.FICHIER.(TYPE == "SON"));
			if (fileList.length() == 1) {
				/*
				var regExp:RegExp = /\\/g;
				var rawStr:String = fileList.ADRESSE;
				rawStr = rawStr.replace(regExp, "/");	
				if (rawStr) {
					//urlStr = BaseUrl.getInstance().BASE + "data/" + rawStr;
					urlStr = "data/" + rawStr;
					_trace.debug("EDMedia -> soundUrl : " + urlStr);
				}
				*/
				var rawStr:String = fileList.ADRESSE;
				if (rawStr) {
					urlStr = "data/" + fileList.ADRESSE;
				}
			}
			if (urlStr != null) urlStr = Urlizer.urlize(urlStr);
			return urlStr;
		}
		
	}
	
}