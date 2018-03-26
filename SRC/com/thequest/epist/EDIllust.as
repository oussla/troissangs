package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	/**
	 * ...
	 * @author nlgd
	 */
	public class EDIllust extends ElementData {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		public static var UNIQUE:String = "image_unique";
		public static var SERIE_SIMPLE:String = "serie_simple";
		public static var SERIE_DOUBLE:String = "serie_double";
		//
		private var _trace:SuperTrace;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function EDIllust(p_raw:XML, p_index:int = 0) {
			super(p_raw, p_index);
			_trace = SuperTrace.getTrace();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function get typeSerie():String {
			var type:String;
			var rawType:String = new String(_raw.TYPE_ILLUSTRATION);
			switch(rawType) {
				case "IMAGE SEULE":
					type = EDIllust.UNIQUE;
					break;
				case "SERIE 1 FENETRE":
					type = EDIllust.SERIE_SIMPLE;
					break;
				case "SERIE 2 FENETRES":
					type = EDIllust.SERIE_DOUBLE;
					break;
			}
			return type;
		}
		
		/**
		 * Si disponible (IMAGE_UNIQUE), renvoi l'élément média unique.
		 * @return
		 */
		public function getUniqueImage():EDMedia {
			var xml:XML = new XML("<Donnee_Media><LEGENDE>" + _raw.LEGENDE + "</LEGENDE>"+ _raw.FICHIER + "</Donnee_Media>");
			return new EDMedia(xml);
		}
		/**
		 * Si disponible (SERIE_SIMPLE), renvoi la liste d'éléments de la série simple.
		 * @return
		 */
		public function getSimpleMediaSerie():Array {
			var elts:Array = new Array();
			var eltList:XMLList = new XMLList(_raw.SERIE_1_FENETRE.Donnee_Media);
			_trace.debug("EDIllust.getSimpleMediaSerie, trouvé " + eltList.length() + " elements");
			var i:int;
			var N:int = eltList.length();
			for (i = 0; i < N; i++) {
				var ed:EDMedia = new EDMedia(eltList[i], i);
				elts.push(ed);
			}
			return elts;			
		}
		/**
		 * Si disponible (SERIE_DOUBLE), renvoi la liste d'éléments de la série du haut.
		 * @return
		 */
		public function getTopMediaSerie():Array {
			var elts:Array = new Array();
			var eltList:XMLList = new XMLList(_raw.SERIE_HAUT_ECRAN.Donnee_Media);
			_trace.debug("EDIllust.getTopMediaSerie, trouvé " + eltList.length() + " elements");
			var i:int;
			var N:int = eltList.length();
			for (i = 0; i < N; i++) {
				var ed:EDMedia = new EDMedia(eltList[i], i);
				//_trace.debug("média = "+ed.url);
				elts.push(ed);
			}
			return elts;
		}
		/**
		 * Si disponible (SERIE_DOUBLE), renvoi la liste d'éléments de la série du bas
		 * @return
		 */
		public function getBottomMediaSerie():Array {
			var elts:Array = new Array();
			var eltList:XMLList = new XMLList(_raw.SERIE_BAS_ECRAN.Donnee_Media);
			_trace.debug("EDIllust.getBottomMediaSerie, trouvé " + eltList.length() + " elements");
			var i:int;
			var N:int = eltList.length();
			for (i = 0; i < N; i++) {
				var ed:EDMedia = new EDMedia(eltList[i], i);
				//_trace.debug("média = "+ed.url);
				elts.push(ed);
			}
			return elts;
		}
		
	}
	
}