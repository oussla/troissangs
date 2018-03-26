package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.tools.baseurl.BaseUrl;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class RepData {
		
		private var _raw:XML;
		private var _trace:SuperTrace;
		private var _corpus:int;
		private var _lengthSup:Number;
		
		public function RepData(p_raw:XML) {
			_raw = p_raw;
			_trace = SuperTrace.getTrace();
		}
		/**
		 * Renvoi le titre du répertoire
		 */
		public function get title():String {
			var t:String;
			if (_raw.TITRE == "") {
				t = "(sans titre)";
			} else {
				t = _raw.TITRE;
			}

			return _toHTML(t);
		}
		/**
		 * Renvoi le titre, en brut, sans aucun traitement
		 */
		public function get rawTitle():String {
			return _raw.TITRE;
		}
		/**
		 * Renvoi un échantillon du titre
		 * @param	sl	longueur de l'échantillon
		 */
		public function getTitleSample(sl:int) {
			var t:String;
			if (_raw.TITRE == "") {
				t = "(sans titre)";
			} else {
				t = _raw.TITRE;
			}
			
			// ##### Passer par un test HORS HTML pour vérifier la longueur de la chaine.
			/*
			if (t.length > sl) {
				t = t.substr(0, sl) + "...";
			}
			*/
			
			return _toHTML(t);
		}
		/**
		 * 
		 * @return
		 */
		public function getChilds():Array {
			var i, N:int;
			var xmlList:XMLList = new XMLList(_raw.REPERTOIRE);
			var repDatas:Array = new Array();
			N = xmlList.length();
			for (i = 0; i < N; i++) {
				var rd:RepData = new RepData(xmlList[i]);
				repDatas.push(rd);
			}
			return repDatas;
		}
		/**
		 * 
		 */
		public function get hasChilds():Boolean {
			var xmlList:XMLList = new XMLList(_raw.REPERTOIRE);
			return (xmlList.length() > 0);
		}
		/**
		 * 
		 */
		public function get level():int {
			return int(_raw.@niveau);
		}
		/**
		 * Est-ce que ce répertoire contient des unités de son ?
		 * @return
		 */
		public function get hasUS():Boolean {
			var usList:XMLList = new XMLList(_raw.LISTE_US.US);
			return usList.length() > 0;
		}
		/**
		 * Renvoi la liste complète, si disponible, de tous les US de ce répertoire.
		 * @return
		 */
		public function getUSList():Array {
			var i:int;
			var udElts:Array = new Array();
			var usList:XMLList = new XMLList(_raw.LISTE_US.US);
			var N:int = usList.length();
			//_trace.debug("RepData, nombre d'US : " + N);
			for (i = 0; i < N; i++) {
				var ud:USData = new USData(usList[i]);
				udElts.push(ud);
			}
			return udElts;
		}
		/**
		 * Renvoi la première US de la liste (si elle existe)
		 * @return
		 */
		public function getFirstUS():USData {
			var usList:XMLList = new XMLList(_raw.LISTE_US.US);
			var ud:USData;
			if (usList.length() > 0) {
				ud = new USData(usList[0]);
			}
			return ud;
		}		
		/**
		 * Renvoi la dernière US de la liste (si elle existe)
		 * @return
		 */
		public function getLastUS():USData {
			//_trace.debug("Cherche la dernière US de ce répertoire : "+title);
			var usList:XMLList = new XMLList(_raw.LISTE_US.US);
			var ud:USData;
			var nbUS:int = usList.length();
			if (nbUS > 0) {
				ud = new USData(usList[nbUS-1]);
			}
			return ud;
		}
		
		
		public function get repName():String {
			var t:String = "";
			if (_raw.NAME) {
				t = _raw.NAME;
			}
			return _toHTML(t);
		}
		
		public function get repLength():Number {
			var t:Number = -1;
			if (_raw.LEN) {
				t = _raw.LEN;
			}
			return t;
		}
		
		public function get totalVerses():int {
			var vt:int = -1;
			if (_raw.VNB != undefined) {
				vt = int(_raw.VNB);
			}
			return vt;
		}
		
		public function get date():String {
			var t:String = "";
			if (_raw.DATE) {
				t = _raw.DATE;
			}
			return t;
		}
		
		public function get place():String {
			var t:String = "";
			if (String(_raw.LIEU).length > 0) {
				t = _toHTML(_raw.LIEU);
			}
			return t;
		}
		
		public function get cast():String {
			var t:String = "";
			if (_raw.CAST) {
				t = _toHTML(_raw.CAST);
			}
			return t;
		}
		
		public function get desc():String {
			var t:String = "";
			if (String(_raw.DSC).length > 0) {
				t = _toHTML(_raw.DSC);
			}
			return t;
		}
		
		public function get vernaculaire():String {
			var t:String = "";
			if (String(_raw.NOM).length > 0) {
				t = _toHTML(_raw.NOM);
			}
			return t;
		}
		/**
		 * Renvoi l'URL du fichier image, ou null si non définie
		 */
		public function get imageUrl():String {
			var url:String = null;
			//if (_raw.IMG) {
			if (_raw.IMG != null && String(_raw.IMG).length > 0) {
				url = _raw.IMG;
				var reg:RegExp = /:/g;
				url = url.replace(reg, "/");
				reg = /\\/g;
				url = url.replace(reg, "/");
				url = "data/" + url;
			}
			if (url != null) url = BaseUrl.getInstance().BASE + url;
			return url;
		}
		
		/**
		 * Définit le corpus du répertoire
		 * @param	p_corpus
		 */
		public function setCorpus(p_corpus:int) {
			_corpus = p_corpus;
		}
		/**
		 * Renvoi le corpus
		 */
		public function get corpus():int {
			return _corpus;
		}
		/**
		 * Renvoi le parent du répertoire
		 * @return
		 */
		public function getRepParent():RepData {
			var rd:RepData;
			
			if(this._raw.parent()) {
				rd = new RepData(this._raw.parent());
			}
			
			return rd;
		}
		/**
		 * Détermine s'il s'agit d'un répertoire avec continuité dans sa numérotation de vers
		 * @return
		 */
		public function isContinuum():Boolean {
			var isIt:Boolean = false;
			
			if (_raw.@continu == 1) {
				isIt = true;
			}
			
			return isIt;
		}
		/**
		 * Renvoi "true" si la numérotation de vers est ignorée dans ce répertoire (et tous ses enfants)
		 */
		public function get ignoreNum():Boolean {
			var isIt:Boolean = false;
			
			if (_raw.@ignoreNum == 1) {
				isIt = true;
			}
			
			return isIt;
		}
		/**
		 * Convertit la chaine au format HTML, avec balises "body" et mise en forme spéciale des italiques.
		 * @param	str
		 * @return
		 */
		private function _toHTML(str:String):String {
			// Remplace les "<i>" par des "<span class=ita>"
			var regIStart:RegExp = /<i>/g;
			str = str.replace(regIStart, "<span class=\"ita\">");
			var regIEnd:RegExp = /<\/i>/g;
			str = str.replace(regIEnd, "</span>");
			str = "<body>" + str + "</body>";
			
			return str;
		}
		/**
		 * Renvoi le XML en brut.
		 */
		public function get raw():XML {
			return _raw;
		}
		/**
		 * Sauve la durée des répertoires précédents
		 * @param	len
		 */
		public function setLengthSup(len:Number) {
			_trace.debug("RepData.setLengthSup : " + len);
			_lengthSup = len;
		}
		/**
		 * Durée des répertoires précédents
		 */
		public function get lengthSup():Number {
			return _lengthSup;
		}
		/**
		 * Recherche la chaine str. Récursive.
		 * @param	str
		 * @return
		 */
		public function search(str):SearchResults {
			var sr:SearchResults = new SearchResults();
			var N, i:int;
			//
			if (this.hasUS) {
				// Recherche la chaîne str dans toute la liste d'US
				var usList:Array = this.getUSList();
				var us:USData;
				N = usList.length;
				for (i = 0; i < N; i++) {
					us = usList[i];
					// Si us est positive, l'ajouter à sr
					if (us.search(str)) sr.addUs(us);
				}
			} else {
				// Le répertoire de contient pas d'US : appelle la fct des répertoires enfants. 
				var childList:Array = this.getChilds();
				var rd:RepData;
				N = childList.length;
				for (i = 0; i < N; i++) {
					rd = childList[i];
					// -> Rappelle la fonction sur le rép enfant.
					sr.fusion(rd.search(str));
				}
			}
			
			return sr;			
		}
		
		/**
		 * Recherche un numéro de vers. Récursive.
		 * @param	vn
		 * @return
		 */
		public function searchVerseNum(vn:int):SearchResults {
			var sr:SearchResults = new SearchResults();
			var N, i:int;
			//
			if (this.hasUS) {
				// Recherche la chaîne str dans toute la liste d'US
				var usList:Array = this.getUSList();
				var us:USData;
				N = usList.length;
				for (i = 0; i < N; i++) {
					us = usList[i];
					// Si us est positive, l'ajouter à sr
					if (us.searchVerseNum(vn)) sr.addUs(us);
				}
			} else {
				// Le répertoire de contient pas d'US : appelle la fct des répertoires enfants. 
				var childList:Array = this.getChilds();
				var rd:RepData;
				N = childList.length;
				for (i = 0; i < N; i++) {
					rd = childList[i];
					// -> Rappelle la fonction sur le rép enfant et fusionne les résultats
					sr.fusion(rd.searchVerseNum(vn));
				}
			}
			
			return sr;
		}
		
		
		
		
		
		
		/**
		 * 
		 * 	TRAITEMENT DES DONNEES
		 * 
		 */
		
		/**
		 * Sauvegarde le numéro du premier vers, et le nombre de vers
		 * @param	first
		 * @param	nb
		 */
		public function setVersesDatas(first:int, nb:int) {
			_trace.debug("RepData \"" + this.rawTitle + "\", setVersesDatas(" + first + ", " + nb + ")");
		}
		
		public function saveSoundLength(len:Number) {
			if (_raw.LEN == undefined) {
				_raw.insertChildBefore(_raw.DATE, new XML("<LEN>" + len + "</LEN>"));
			} else {
				_raw.LEN = len;
			}
		}
		
		public function saveVersesNumber(vnb:int) {
			if(_raw.VNB == undefined) {
				_raw.insertChildBefore(_raw.NOM, new XML("<VNB>" + vnb + "</VNB>"));
			} else {
				_raw.VNB = vnb;
			}
		}
		
		/**
		 * 
		 * @return
		 */
		public function processRepVersesNumber():DEV_DataCargo {
			var cargo:DEV_DataCargo = new DEV_DataCargo();
			var prefix:String = "";
			// Nombre de vers
			var vnb:int = 0;
			// Durée des sons
			var rlen:Number = 0;
			var N, i:int;
			
			// Le rep contient des unités de son
			if (this.hasUS) {
				var usList:Array = this.getUSList();
				var us:USData;
				N = usList.length;
				for (i = 0; i < N; i++) {
					us = usList[i];
					if (us.totalVerses > 0) {
						vnb += us.totalVerses;
					}
					if (us.usLength > 0) {
						rlen += us.usLength;
					}
				}
			} else {
				// Le répertoire de contient pas d'US : appelle la fct des répertoires enfants. 
				var childList:Array = this.getChilds();
				var rd:RepData;
				N = childList.length;
				for (i = 0; i < N; i++) {
					rd = childList[i];
					// -> Rappelle la fonction sur le rép enfant.
					var childCargo:DEV_DataCargo = rd.processRepVersesNumber();
					if(childCargo) {
						vnb += childCargo.vnb;
						rlen += childCargo.len;
					}
				}
			}
			
			// Arrondi la durée
			cargo.len = Math.round(rlen * 100)/100;
			cargo.vnb = vnb;
			
			this.saveSoundLength(cargo.len);
			this.saveVersesNumber(cargo.vnb);
			
			// Affichage
			for (i = 0; i < this.level; i++) {
				prefix += "----|";
			}
			_trace.debug(prefix + " process : \"" + this.rawTitle + "\" vnb:" + cargo.vnb + ", rlen:" + cargo.len);
			//
			
			return cargo;
		}
	}
	
}