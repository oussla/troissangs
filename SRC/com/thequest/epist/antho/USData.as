package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.Urlizer;
	import com.thequest.tools.baseurl.BaseUrl;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class USData {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _raw:XML;
		private var _searchSample:String;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function USData(p_raw:XML) {
			_raw = p_raw;
			_trace = SuperTrace.getTrace();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Renvoi la liste des médias associés à cette unité de son
		 * @return
		 */
		public function getMediaList():Array {
			//_trace.debug("USData.getMediaList");
			var i:int;
			var mdElts:Array = new Array();
			var mdList:XMLList = new XMLList(_raw.LISTE_MEDIAS.MEDIA);
			var N:int = mdList.length();
			for (i = 0; i < N; i++) {
				var md:MediaData = new MediaData(mdList[i]);
				mdElts.push(md);
			}
			return mdElts;
		}
		/**
		 * 
		 */
		public function get soundURL():String {
			var url:String = _raw.FICHIER;
			/*
			var reg:RegExp = /:/g;
			url = url.replace(reg, "/");
			reg = /\\/g;
			url = url.replace(reg, "/");
			return BaseUrl.getInstance().BASE + "data/" + url;
			*/
			return Urlizer.urlize("data/" + url);
		}
		/**
		 * 
		 */
		public function get strophe():String {
			var str:String = _raw.STROPHE;
			/*
			var pattern:RegExp = /\r\n/g;
			str = str.replace(pattern, "\n");
			var pattern2:RegExp = /\n\t\n/g;
			str = str.replace(pattern2, "\n");
			*/
			var pattern:RegExp = /\r\n/g;
			str = str.replace(pattern, "\n");
			pattern = /\t/g;
			str = str.replace(pattern, "");
			return str;
		}
		/**
		 * Renvoi une chaine correspondant à la numérotation des lignes de la strophe ; prend en compte les sauts de lignes vides.
		 * @return
		 */
		public function getLineNums():String {
			_trace.debug("USData.getLineNums");
			var str:String = this.strophe;
			var firstNum:int = this.firstVerseNumber;
			var lNum:int = firstNum;
			var lineNums:String = "";
			// Si le premier vers n'est pas correctement numéroté, renvoi une chaine vide.
			if(firstNum > 0) {
				var arr:Array = str.split("\n");
				var N:int = arr.length;
				var pattern:RegExp = /\r/g;
				for (var i:int = 0; i < N; i++) {
					var iStr:String = arr[i];
					iStr = iStr.replace(pattern, "");
					if (iStr.length > 0 ) {
						lineNums += lNum + "\n";
						lNum++;
					} else {
						lineNums += "\n";
					}
				}
				// Supprime le dernier retour à la ligne
				if (lineNums.charAt(lineNums.length - 1) == "\n") lineNums = lineNums.substr(0, -1);
			} else {
				_trace.error("USData.getLineNums : numérotation du premier vers incorrecte.");
			}
			
			return lineNums;
		}
		

		
		
		/**
		 * Renvoie le commentaire
		 */
		public function get comment():String {
			return _toHTML(_raw.COMMENTAIRE);
		}
		/**
		 * Numéro du premier vers
		 */
		public function get firstVerseNumber():int {
			var vd:int = -1;
			if (_raw.VD != undefined) {
				vd = int(_raw.VD);
			}
			return vd;
		}
		/**
		 * Nombre total de vers dans cette unité de son
		 */
		public function get totalVerses():int {
			var vt:int = -1;
			if (_raw.VNB != undefined) {
				vt = int(_raw.VNB);
			}
			return vt;
		}
		
		public function get lastVerseNumber():int {
			var vl:int = -1;
			if (this.firstVerseNumber != -1) {
				vl = this.firstVerseNumber + this.totalVerses - 1;
			}
			return vl;
		}
		/**
		 * 
		 * @return
		 */
		public function getBegin():String {
			var endIndex:int = this.strophe.indexOf("\n");
			var begin:String = this.strophe;
			if(endIndex != -1) {
				begin = this.strophe.substr(0, endIndex);
			}
			
			// Vérifie que la chaine commmence bien par un caractère alphanumérique.
			/*
			var exp:RegExp = /^[a-zA-Z0-9]/;
			if(!exp.exec(begin)) {
				_trace.debug("USData.getBegin : Attention chaine invalide.");
				begin = "..." + begin;
			}
			*/
			return begin;
		}
		
		public function getFirstLine():String {
			return "";
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
		 * Renvoi la durée du son de cette US
		 */
		public function get usLength():Number {
			var t:Number = -1;
			if (_raw.LEN) {
				t = _raw.LEN;
			}
			return t;
		}
		/**
		 * Recherche une chaine dans les champs de l'US.
		 * @param	str
		 * @return
		 */
		public function search(str:String):USData {
			var returnUS:USData;
			var found:int = String(_raw.STROPHE).search(str);
			if (found >= 0) {
				//_trace.debug("Trouvé \"" + str + "\" dans US \"" + this.getBegin() + "\"");
				_searchSample = this.getSearchResultSample(str);
				returnUS = this; 
			}
			return returnUS;
		}
		/**
		 * Renvoi un échantillon de la strophe contenant la chaine pattern.
		 * @param	pattern
		 * @return
		 */
		public function getSearchResultSample(pattern:String):String {
			var suspensDeb:String = "";
			var suspensFin:String = "";
			var str:String = this.strophe;
			str = str.replace(/\r/g, " ");
			str = str.replace(/\n\n/g, "\n");
			str = str.replace(/\n/g, " / ");
			var found:int = str.search(pattern);
			var deb:int = Math.max(found - 20, 0);
			if (deb > 0) {
				deb = str.indexOf(" ", deb);
				if (deb >= 0) deb++;
				if (str.charAt(deb) == "/") deb += 2;
				suspensDeb = "...";
			}
			
			var fin:int = str.indexOf(" ", deb + 45);
			if (fin < 0) { 
				fin = str.length;
			} else {
				suspensFin = "...";
			}
			str = suspensDeb + str.substring(deb, fin) + suspensFin;
			str = str.replace(pattern, "<span class=\"pattern\">" + pattern + "</span>");
			
			//str = str.substr(Math.max(found - 10, 0), 40) + "...";
			return str;
		}
		/**
		 * 
		 */
		public function get searchSample():String {
			var str:String;
			if (_searchSample && _searchSample.length > 0) {
				str = _searchSample;
			} else {
				str = this.getBegin() + "...";
			}
			return str;
		}
		/**
		 * Recherche par numéro de vers. 
		 * @param	vn
		 * @return
		 */
		public function searchVerseNum(vn:int):USData {
			var returnUS:USData;
			if (vn >= this.firstVerseNumber && vn <= this.lastVerseNumber) {
				returnUS = this;
			}
			return returnUS;
		}
		
		/**
		 * Renvoi le contenu brut
		 */
		public function get raw():XML {
			return _raw;
		}
		
		
		
		
		
		
		/**
		 * 
		 * 	TRAITEMENT DES DONNEES
		 * 
		 */
		/**
		 * Strophe, version brute, sans HTML
		 * @return
		 */
		public function getRawStrophe():String {
			var str:String = _raw.STROPHE;
			var pattern:RegExp = /\r\n/g;
			str = str.replace(pattern, "\n");
			pattern = /\t/g;
			str = str.replace(pattern, "");
			return str;
		}
		/**
		 * Commentaire, version brute, sans HTML
		 * @return
		 */
		public function getRawComment():String {
			var str:String = _raw.COMMENTAIRE;
			return str;
		}
		/**
		 * Sauvegarde une nouvelle version de la strophe
		 * @param	str
		 */
		public function saveStrophe(str:String) {
			_raw.STROPHE = str;
		}
		/**
		 * Sauvegarde une nouvelle version du commentaire
		 * @param	str
		 */
		public function saveComment(str:String) {
			_raw.COMMENTAIRE = str;
		}
		/**
		 * Sauvegarde la durée du son
		 * @param	len	durée du son
		 */
		public function saveSoundLength(len:Number) {
			if (_raw.LEN == undefined) {
				_raw.insertChildBefore(_raw.STROPHE, new XML("<LEN>" + len + "</LEN>"));
			} else {
				_raw.LEN = len;
			}
		}
		/**
		 * Sauve le numéro du premier vers et le nombre de vers
		 * @param	first
		 * @param	nb
		 */
		public function saveVersesDatas(first:int, nb:int) {
			if(_raw.VNB == undefined) {
				_raw.prependChild(new XML("<VNB>" + nb + "</VNB>"));
			} else {
				_raw.VNB = nb;
			}
			if(_raw.VD == undefined) {
				_raw.prependChild(new XML("<VD>" + first + "</VD>"));
			} else {
				_raw.VD = first;
			}
		}
	}
	
}