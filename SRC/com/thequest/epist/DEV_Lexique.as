package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class DEV_Lexique extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _xmlLoader:XMLLiteLoader;
		private var _lexique:Lexique;
		private var _lexBox:LexiqueBox;
		private var _strTest:String = "Poème dit par les officiants (to <i><a href=\"event:lexique:minaa\">minaa</a></i> Ne' Ambaa et Ne' Sulo, lors des funérailles de l'officiante (to <i>burake,</i> Indo' Serang, fille de Ne' Banne, le 14octobre 1993, à To' Barana'. \n- v. 2. <i>Saroan:</i> unité locale d'entraide mutuelle et de travail associatif au sein d'un village, en général pour les travaux des champs et les travaux rituels. Ce vers d'ouverture est interchangeable avec <i>to</i> <i>mai</i> <i>sang</i> <i>banuanta:</i> «ceux de notre village». <i>Mai:</i> «répandu, dispersé»\n- v. 4. <i>Balandong:de</i> la racine <i>badong«ronde</i> funéraire pour le défunt». <i>Tabalandongou</i> <i>tama'</i> <i>badong:</i> «dansons». "
		//
		public var test_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function DEV_Lexique() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello DEV_Lexique !");
			
			_xmlLoader = new XMLLiteLoader();
			_xmlLoader.addEventListener(Event.COMPLETE, _xmlLoaded);
			_xmlLoader.load("../PUB/appdata/fr/lexique.xml");
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private function _xmlLoaded(evt:Event) {
			//_xmlLoader.xml
			_lexique = Lexique.getInstance();
			_lexique.init(_xmlLoader.xml);
			var term:String = "a'len";
			//_trace.debug(term + " : " + _lexique.getDef(term));
			//
			_lexBox = LexiqueBox.getInstance();
			this.addChild(_lexBox);
			//
			var cssStyle:StyleSheet = new StyleSheet();
			cssStyle.setStyle("a", { color:"#C7C7C7" } );
			test_tf.styleSheet = cssStyle;
			
			
			test_tf.htmlText = _strTest;
			test_tf.addEventListener(TextEvent.LINK, _textEventHandler);
			
		}
		
		private function _textEventHandler(evt:TextEvent) {
			_trace.debug("_textEventHandler : " + evt.type + ", " + evt.text);
			var term:String;
			var split:Array = evt.text.split(":");
			term = split[1];
			//_trace.debug(term + " : " + _lexique.getDef(term));
			_lexique.openDef(term);
		}
		
		
	}
	
}