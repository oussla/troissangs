package com.thequest.epist.argu {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.EDMedia;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import com.thequest.epist.BasicFormat;
	import flash.text.StyleSheet;
	import com.thequest.tools.ascenseur.Ascenseur;
	import com.thequest.epist.AscenseurCommand;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MediaSerie extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _elts:Array;
		private var _currentMediaIndex:int;
		private var _currentMedia:MediaElement;
		private var _height:Number;
		private var _mask:Sprite;
		private var _style:BasicFormat;
		private var _css:StyleSheet;
		private var _asc:Ascenseur;
		private var _ascCmd:AscenseurCommand;
		private var _ascMask:Rectangle;
		private var _basicFormat:BasicFormat;
		//
		public var mediaPrev_btn:SimpleButton;
		public var mediaNext_btn:SimpleButton;
		public var nextPrevPicto_mc:MovieClip;
		public var legende_mc:MovieClip;
		//public var legende_tf:TextField;
		public var mediaIndex_tf:TextField;
		public var mediaPrevNext_mc:MovieClip;
		//--------------------------------------------------
		//
		//		Contructor
		//
		//--------------------------------------------------
		public function MediaSerie() {
			_trace = SuperTrace.getTrace();
			_elts = new Array();
			_mask = new Sprite();
			
			// Raccourcis vers les boutons / champs
			mediaPrev_btn = mediaPrevNext_mc.mediaPrev_btn;
			mediaNext_btn = mediaPrevNext_mc.mediaNext_btn;
			mediaIndex_tf = mediaPrevNext_mc.mediaIndex_tf;
			nextPrevPicto_mc = mediaPrevNext_mc.nextPrevPicto_mc;
			
			mediaPrev_btn.addEventListener(MouseEvent.CLICK, _mediaPrev)
			mediaNext_btn.addEventListener(MouseEvent.CLICK, _mediaNext)
			this.addChild(_mask);
			

			//création de l'ascenseur
			_ascMask = new Rectangle(0, 0, legende_mc.width, 35);
			_asc = new Ascenseur(legende_mc.legende_tf, _ascMask);
			legende_mc.addChild(_asc);
			_ascCmd = new AscenseurCommand(_asc);
			_ascCmd.x = legende_mc.width;
			_ascCmd.y = 10;
			_ascCmd.visible = true;
			legende_mc.addChild(_ascCmd);
			
			_basicFormat = BasicFormat.getInstance();
			_css = _basicFormat.getBasicCSS();
			legende_mc.legende_tf.styleSheet = _css;
			legende_mc.legende_tf.width = 510;
			
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Ouvre la série.
		 * @param	p_elts		Tableau contenant les EDMedia.
		 */
		public function openSerie(p_elts:Array) {
			//trace("MediaSerie.openSerie");
			_elts = p_elts;
			if(_elts.length > 0) {
				this._openMedia(0);
			}
		}
		/**
		 * Nettoie la série
		 */
		public function reset() {
			//trace("MediaSerie.reset");
			if (_elts) {
				_elts.splice(0, _elts.length);
			}
			_resetMedia();
			_ascCmd.visible = false;
			mediaPrevNext_mc.visible = false;
		}
		
		public function setAvailableHeight(h:Number) {
			//trace("MediaSerie.setAvailableHeight");
			_height = h - 48;
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xBBB4455);
			_mask.graphics.drawRect(0, 0, 610, _height);//602
			_mask.graphics.endFill();
			mediaPrevNext_mc.y = _height;
		}
		/**
		 * 
		 */
		private function _openMedia(p_index:int) {
			trace("MediaSerie._openMedia");
			var edMedia:EDMedia = _elts[p_index];
			//_trace.debug("MediaSerie._openMedia " + edMedia.typeMedia + ", \"" + edMedia.legend + "\"");
			_resetMedia();
			

			//legende_tf.y = _height;
			legende_mc.y = _height;
			
			
			var legend:String = _basicFormat.transformItaTags(edMedia.legend);
			//var legend:String = edMedia.legend;
			//trace(legend);
			legend = legend.replace(/\r/g, ""); // Supprime les retours chariots
			legend = legend.replace(/\n/g, " "); // Supprime les retours chariots
			legende_mc.legende_tf.autoSize = TextFieldAutoSize.LEFT;
			legende_mc.legende_tf.height = 1;
			legende_mc.legende_tf.htmlText = legend;
			_asc.resetPosition();
			_ascCmd.checkHeights();
			//legende_mc.legende_tf.y = 0;
			
			//trace("---"+"\n" + legend);

			// #### Régler problème sur retours à la ligne parasites...
			//_trace.debug("MediaSerie.openMedia, edMedia.legend : " + edMedia.legend + "\nlegend : " + legend);
			//_trace.debug("Sur original / Retours lignes : " + edMedia.legend.indexOf("\n") + ", chariots : " + edMedia.legend.indexOf("\r"));
			//_trace.debug("Sur original / derniers Retours lignes : " + edMedia.legend.lastIndexOf("\n") + ", derniers chariots : " + edMedia.legend.lastIndexOf("\r"));
			//trace("longueur : " +legend.length);
			//_trace.debug("Sur legend / Retours lignes : " + legend.indexOf("\n") + ", chariots : " + legend.indexOf("\r"));
			
			switch(edMedia.typeMedia) {
				case EDMedia.TYPE_IMAGE :
					_currentMedia = new MEImage(edMedia);
					break;
				case EDMedia.TYPE_SWF :
					_currentMedia = new MEFlash(edMedia);
					break;
				case EDMedia.TYPE_VIDEO :
					_currentMedia = new MEVideo(edMedia);
					break;
				case EDMedia.TYPE_SON :
					_currentMedia = new MESon(edMedia);
					break;
				case EDMedia.TYPE_PDF:
					_currentMedia = new MEPdf(edMedia);
					break;
				case EDMedia.TYPE_SWF_FLUTES:
					_currentMedia = new MEFlutes(edMedia);
					break;
				case EDMedia.TYPE_SWF_PROFERATION:
					_currentMedia = new MEProferation(edMedia);
					break;
				default:
					_trace.error("MediaSerie : tentative d'ouverture d'un media inconnu (" + edMedia.typeMedia + ")");
					break;
			}
			
			//informer le média de la place dont il dispose
			
			if (_currentMedia) {
				_currentMedia.zoneHeight = _height;
				_currentMedia.init();
				_currentMedia.mask = _mask;
				this.addChild(_currentMedia);
			}
			_currentMediaIndex = p_index;
			_setPrevNext();
			
			trace(edMedia.url);
		}
		/**
		 * Nettoie le _currentMedia
		 */
		private function _resetMedia() {
			//trace("MediaSerie._resetMedia : nettoie le _currentMedia");
			if (_currentMedia) {
				if (this.contains(_currentMedia)) {
					this.removeChild(_currentMedia);
				}
				_currentMedia.clear();
				legende_mc.legende_tf.text = "";
			}
		}
		/**
		 * Configure les boutons suivant et précédent
		 */
		private function _setPrevNext() {
			mediaPrevNext_mc.visible = true;
			
			mediaPrev_btn.visible = false;
			mediaNext_btn.visible = false;
			
			if (_currentMediaIndex > 0) {
				mediaPrev_btn.visible = true;
			}
			if (_currentMediaIndex < _elts.length - 1) {
				mediaNext_btn.visible = true;
			}
			
			nextPrevPicto_mc.visible = (_elts.length > 1);
			
			mediaIndex_tf.text = String(_currentMediaIndex + 1) + " / " + _elts.length;
			mediaIndex_tf.visible = (_elts.length > 1);
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _mediaPrev(evt:MouseEvent = null) {
			if (_currentMediaIndex > 0) {
				this._openMedia(_currentMediaIndex - 1);
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _mediaNext(evt:MouseEvent = null) {
			if (_currentMediaIndex < _elts.length - 1) {
				this._openMedia(_currentMediaIndex + 1);
			}
		}		
	}
	
}