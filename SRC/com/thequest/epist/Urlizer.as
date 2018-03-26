package com.thequest.epist 
{
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.system.Capabilities;
	import mdm.*;
	/**
	 * ...
	 * @author nlgd
	 */
	public class Urlizer
	{
		
		private static var _trace:SuperTrace;
		
		public function Urlizer() 
		{
			
		}
		
		/**
		 * Transforms the url according to the OS and other stuffs.
		 * @param	url
		 * @return
		 */
		public static function urlize(url:String):String {
			var isZinc:Boolean = (mdm.Application.filename != "" && mdm.Application.filename != null);
			var os:String = Capabilities.os;
			os = os.substr(0, 3).toLowerCase();
			var regExp:RegExp;
			
			regExp = /:/g;
			url = url.replace(regExp, "/");
			
			if (os == "mac") {
				// replace all \ with /
				regExp = /\\/g;
				url = url.replace(regExp, "/");
			} else {
				// replace all / with \
				regExp = /\//g;
				url = url.replace(regExp, "\\");
			}
			
			return BaseUrl.getInstance().BASE + url;
			
		}
		
	}

}