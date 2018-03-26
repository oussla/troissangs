package com.thequest.epist {
	
	import com.nlgd.supertrace.SuperTrace;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	//import com.thequest.epist.antho.AnthoManager;

	
	public class BasicFormat {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _instance:BasicFormat;
		//
		private var _trace:SuperTrace;
		//private var _mgr:AnthoManager;
		// Définit les séries de couleurs par corpus (0 : Couchant, 1 : Levant, 2:Neutre)
		/*private var _colors:Array = [	["#E53426", "#FD6A56", "#FA988A", "#F6CDC7"],
										["#9B5A2C", "#C58B49", "#CBA874", "#E3D1A6"],
										["#66666c", "#979797", "#ABB0B0", "#CBD7D7"]
									];*/
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():BasicFormat {
			if (_instance == null) {
				_instance = new BasicFormat(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function BasicFormat(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use BasicFormats.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello BasicFormat !");
				//this.init();
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function getBasicCSS():StyleSheet {
			var css:StyleSheet;
			css = new StyleSheet();
			
			css.setStyle("body", { fontFamily:"SolexRegular" } );
			css.setStyle(".ita", { fontFamily:"SolexRegularItalic" } );
			return css;
		}
		
		public function transformItaTags(strToTransform:String):String {
			var str:String = '';
			var pattern:RegExp = /<i>/gi;
			str = strToTransform.replace(pattern, " <span class='ita'>");
			pattern = /<\/i>/gi;
			str = str.replace(pattern, "</span>");
			return '<body>' + str + '</body>';
		}
	}
}
internal class SingletonBlocker {}