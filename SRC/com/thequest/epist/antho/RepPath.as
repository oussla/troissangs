package com.thequest.epist.antho {
	import caurina.transitions.properties.CurveModifiers;
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import com.thequest.epist.Translator;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class RepPath extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _rd:RepData;
		private var _sndMgr:SoundManager;
		private var _elementsContainer:Sprite;
		private var _mgr:AnthoManager;
		//
		public var label_tf:TextField;
		public var leftLine:MovieClip;
		public var rightLine:MovieClip;
		public var degrade:MovieClip;
		public var toolbar:MovieClip;
		public var tps_tf:TextField;
		public var nbvers_tf:TextField;
		public var separation:TextField;
		public var temp_tf:TextField;
		public var ct:SimpleButton;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function RepPath(p_rd:RepData) {
			_trace = SuperTrace.getTrace();
			_rd = p_rd;
			_sndMgr = SoundManager.getInstance();
			_mgr = AnthoManager.getInstance();
			_elementsContainer = new Sprite();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function init() {
			//_trace.debug("RepPath.init");
			//intitulé du répertoire
			this._setLabel(_rd.title);
			
			//éléments visuels
			this._setElements();
			this._setLine();
			
			//barre de progression
			this._setToolbar();
			
			_updateSeekbar();
			
			//écoute du SoundManager
			_sndMgr.addEventListener(MediaEvent.MOVED_SEEK, _updateSeekbar);
			_sndMgr.addEventListener(MediaEvent.SOUND_PLAYING, _updateSeekbar);

			
			this.ct.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) { 
				//_trace.debug("RepPath.mouseOver");
				leftLine.alpha = 1;
				rightLine.alpha = 1;
				degrade.alpha = 1;
				_elementsContainer.alpha = 1;
				toolbar.alpha = 1;
			} );
			this.ct.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) { 
				//_trace.debug("RepPath.mouseOut");
				leftLine.alpha = 0;
				rightLine.alpha = 0;
				degrade.alpha = 0;
				_elementsContainer.alpha = 0;
				toolbar.alpha = 0;
			} );
			
			ct.useHandCursor = false;
			this.addChild(ct);
			
		}
		/**
		 * 
		 * @param	p_label
		 */
		private function _setLabel(p_label:String) {
			if (_rd.level <= 3) p_label = p_label.toUpperCase();
			label_tf.embedFonts = true;
			label_tf.wordWrap = false;
			
			var cf:CorpusFormats = CorpusFormats.getInstance();
			var css:StyleSheet = cf.getCSS(AnthoManager.NEUTRE, _rd.level);
			label_tf.styleSheet = css;
			label_tf.autoSize = TextFieldAutoSize.LEFT;
			label_tf.htmlText = p_label;
			//label_tf.x = _rd.level * 10;
			//label_tf.setTextFormat(this._getTextFormat());
			//label_tf.textColor = RepButton.TEXT_COLORS[_rd.level];
		}
		
		private function _setLine() {
			leftLine.x = label_tf.x + label_tf.width;
			leftLine.width = 375 - nbvers_tf.textWidth - leftLine.x - this.x;
			rightLine.x = label_tf.x + label_tf.width+leftLine.width+_elementsContainer.width+5;
			rightLine.width = 155-this.x;
			degrade.x = rightLine.x + rightLine.width;
			
			leftLine.alpha = 0;
			rightLine.alpha = 0;
			degrade.alpha = 0;
		}
		
		private function _setElements() {
			//_trace.debug("RepPath._setElements");
			var translator:Translator = Translator.getInstance();
			separation.text = translator.translate("vers")+" | ";
			//nombre de vers
			nbvers_tf.text = ""+_rd.totalVerses;
			nbvers_tf.autoSize = TextFieldAutoSize.RIGHT;
			nbvers_tf.x = separation.x - nbvers_tf.width;
			nbvers_tf.x = separation.x - nbvers_tf.width;
			
			//durée des US contenus dans le répertoire
			tps_tf.text = "" + this.getTimeToString(_rd.repLength);
			tps_tf.autoSize = TextFieldAutoSize.LEFT;
			tps_tf.x = separation.x+separation.width;
			tps_tf.x = separation.x + separation.width;
			
			//conteneur
			_elementsContainer.addChild(nbvers_tf);
			_elementsContainer.addChild(separation);
			_elementsContainer.addChild(tps_tf);
			
			_elementsContainer.x = 380-this.x;
			this.addChild(_elementsContainer);
			
			_elementsContainer.alpha = 0;
		}
		
		private function _setToolbar() {
			//_trace.debug("RepPath._setToolbar");
			toolbar.seekbar.backgroundSeekbar.alpha = 0.4;
			toolbar.seekbar.fullness.alpha = 0.4;
			toolbar.seekbar.progress.alpha = 0.25;
			toolbar.seekbar.ct.visible = false;
			toolbar.x = 663 - this.x;
			//_trace.debug("Longueur rep supérieurs = "+_rd.lengthSup)
			//_trace.debug("toolbar.x = " + toolbar.x);
			
			toolbar.alpha = 0;
		}
		
		/**
		 * A VERIFIER QUAND LES FICHIERS DE l'ANTHOLOGY SERONT PRETS (LEN)
		 */
		private function _updateSeekbar(evt:Event = null) {
			var lu:Number;
			var position:Number;
			var percent:Number;
			
			var repLu:Number = _rd.lengthSup; // durée des répertoire précédents et de même niveau
			var usSup:Number = _mgr.lengthUsSup; // durée des us précédentes dans le rep en cours
			var playPosition:Number; // durée lue de l'us en cours
			if (_sndMgr.isPlaying)
				playPosition = _sndMgr.soundPosition;
			else
				playPosition = _sndMgr.pausePosition;
				
			// Le SoundManager traite en millisecondes, le reste est en secondes. Donc conversion.
			playPosition = playPosition / 1000;
			
			if (isNaN(repLu))
				repLu = 0;
			if (isNaN(usSup))
				usSup = 0;
			if (isNaN(playPosition))
				playPosition = 0;
				
			lu = playPosition + repLu + usSup;
			//_trace.debug(lu + " / " + _rd.repLength);
			
			percent = (lu * 100) / _rd.repLength;
			//_trace.debug(int(percent) + "%");
			
			//temp_tf.text = "repLu:"+repLu+" / usSup:"+usSup+" / playPosition:"+playPosition+" = "+ int(lu) + " sur " + _rd.repLength + " - " + Math.round(percent) + "%";
		
			position = ((percent / 100) * (toolbar.width));
			toolbar.seekbar.fullness.width = position;
		}
		
		private function getTimeToString(time:Number):String {
			//_trace.debug("RepPath.getTimeToString");
			time *= 1000;
			
			var result:String = "";
			var msToS:Number = 1000;
			var msToM:Number = msToS * 60;
			var msToH:Number = msToM * 60;
			var rest:int;
			
			var H:int = int(time / msToH);
			rest = time % msToH;
			var M:int = int(rest / msToM);
			rest = rest % msToM;
			var S:int = int(rest / msToS);
			rest = rest % msToS;
			
			if (H < 10)
				result = "0" + H;
			else
				result = result + H;
			
			if (M < 10)
				result = result + " : 0" + M;
			else
				result = result + " : " + M;
				
			if (M < 10)
				result = result + " : 0" + S;
			else
				result = result + " : " + S;
			
			return result;
		}

		/**
		 * Renvoi un objet TextFormat d'après le niveau du bouton
		 * @param	lvl
		 * @return
		 */
		/*
		private function _getTextFormat():TextFormat {
			var lvl:int = _rd.level;
			var font:Font = new ImportedFontRegular();
			var format:TextFormat = new TextFormat();
			format.font = font.fontName;
			//[0x9B5A2C, 0x9B5A2C, 0x9B5A2C, 0xC58B49, 0xCBA874, 0xE3D1A6];
			switch(lvl) {
				case 0,1,2:
					format.size = 15;
					format.color = 0x66666c;
					break;
				case 3:
					format.size = 13;
					format.color = 0x979797;
					break;
				case 4:
					format.size = 14;
					format.color = 0xabb0b0;
					break;
				default:
					format.size = 14;
					format.italic = true;
					format.color = 0xcbd7d7;
					break;
			}
			return format;
		}
		*/
	}
	
}