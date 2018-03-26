package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	/**
	 * ...
	 * @author nlgd
	 */
	public class EDAntec extends ElementData {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		public static const TYPE_PERTINENT:String = "pertinent";
		public static const TYPE_LIEN:String = "lien";
		//
		private var _trace:SuperTrace;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function EDAntec(p_raw:XML, p_index:int = 0) {
			super(p_raw, p_index);
			_trace = SuperTrace.getTrace();
			//_trace.debug("Hello EDAntec !");
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 */
		public function get comment():String {
			return _raw.COMMENTAIRE;
		}
		/**
		 * 
		 */
		public function get type():String {
			var type:String;
			var rawType:String = new String(_raw.TYPE_ANTECEDENT);
			switch(rawType) {
				case "AVEC LIEN":
					type = EDAntec.TYPE_LIEN;
					break;
				case "PERTINENT":
					type = EDAntec.TYPE_PERTINENT;
					break;
				default: 
					type = _raw.TYPE_ANTECEDENT;
					break;
			}
			return type;			
		}
		/**
		 * Renvoi l'id de la base vers laquelle renvoi le lien (si cet antécédent est un lien)
		 */
		public function get linkBaseId():int {
			var rawId:int = new int(_raw.BASE_LIEN);
			return rawId;
		}
		/**
		 * Renvoi l'id de ll'étape vers laquelle renvoi le lien (si cet antécédent est un lien)
		 */
		public function get linkEtapeId():int {
			var rawId:int = new int(_raw.ETAPE_LIEN);
			return rawId;
		}
		/**
		 * Renvoi l'id de la proposition vers laquelle renvoi le lien (si cet antécédent est un lien)
		 */
		public function get linkPropalId():int {
			var rawId:int = new int(_raw.PROPOSITION_LIEN);
			return rawId;
		}
		
	}
	
}