package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CorpusFormats {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _instance:CorpusFormats;
		//
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		// Définit les séries de couleurs par corpus (0 : Couchant, 1 : Levant, 2:Neutre)
		private var _colors:Array = [	["#E53426", "#FD6A56", "#FA988A", "#F6CDC7"],
										["#9B5A2C", "#C58B49", "#CBA874", "#E3D1A6"],
										["#66666c", "#979797", "#ABB0B0", "#CBD7D7"]
									];
		private var _sizes:Array = [15, 13, 14, 14];
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():CorpusFormats {
			if (_instance == null) {
				_instance = new CorpusFormats(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function CorpusFormats(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use CorpusFormats.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello CorpusFormats !");
				this.init();
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function init() {
			_mgr = AnthoManager.getInstance();
		}
		/**
		 * Renvoi une feuille de style d'après le corpus et le niveau d'arbo demandés
		 * @param	corpus
		 * @param	lvl
		 * @return	StyleSheet
		 */
		public function getCSS(corpus:int, lvl:int):StyleSheet {
			var css:StyleSheet;
			css = new StyleSheet();
			//css.setStyle(".ita", { fontFamily:"SolexRegularItalic", color:"#00FF00" } );
			css.setStyle(".ita", { fontFamily:"SolexRegularItalic" } );
			
			
			switch(lvl) {
				case 0, 1, 2:
					css.setStyle("body", {color:_colors[corpus][0], fontSize:15} );
					break;
				case 3:
					css.setStyle("body", {color:_colors[corpus][1], fontSize:13} );
					break;
				case 4:
					css.setStyle("body", {color:_colors[corpus][2], fontSize:14} );
					break;
				default:
					css.setStyle("body", {color:_colors[corpus][3], fontSize:14, fontFamily:"SolexRegularItalic"} );
					break;
			}
			
			return css;
		}
		/**
		 * Renvoi un CSS définissant un ensemble de styles pour tout un ensemble de niveau dans l'arbo
		 * @param	corpus
		 * @return
		 */
		public function getMultiLevelsCSS(corpus:int):StyleSheet {
			//_trace.debug("CorpusFormat.getMultiLevelCSS : " + corpus);
			var css:StyleSheet = new StyleSheet();
			var N:int = _colors[corpus].length;
			
			// Ajoute un style "body"
			css.setStyle("body", { fontFamily:"SolexRegular" } );
			// Style pour les italiques
			css.setStyle(".ita", { fontFamily:"SolexRegularItalic" } );
			// Crée les styles par niveau
			css.setStyle(".level0", {color:_colors[corpus][0], fontSize:15} );
			css.setStyle(".level1", {color:_colors[corpus][1], fontSize:13} );
			css.setStyle(".level2", {color:_colors[corpus][2], fontSize:14} );
			css.setStyle(".level3", {color:_colors[corpus][3], fontSize:14, fontFamily:"SolexRegularItalic"} );
			
			return css;			
		}
		/**
		 * Renvoi une feuille basique, dans laquelle seule la police "ita" est définie.
		 * @return
		 */
		public function getBasicCSS():StyleSheet {
			var css:StyleSheet;
			css = new StyleSheet();
			//css.setStyle(".ita", { fontFamily:"SolexRegularItalic", color:"#00FF00" } );
			css.setStyle(".ita", { fontFamily:"SolexRegularItalic" } );
			
			return css;
		}
	}
	
}

internal class SingletonBlocker {}