package com.thequest.epist.argu {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.AscenseurCommand;
	import com.thequest.epist.CustomTextButton;
	import com.thequest.epist.EDAntec;
	import com.thequest.epist.EDIllust;
	import com.thequest.epist.EDPropal;
	import com.thequest.tools.ascenseur.Ascenseur;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import com.thequest.epist.Translator;
	import flash.text.StyleSheet;
	import com.thequest.epist.BasicFormat;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class PropalViewer extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _mgr:NavManager;
		private var _ed:EDPropal;
		private var _antecs:Array;
		private var _antecsContainer:Sprite;
		private var _mediaViewer:MediaViewer;
		private var _translator:Translator;
		private var _asc:Ascenseur;
		private var _ascCmd:AscenseurCommand;
		private var _style:BasicFormat;
		private var _css:StyleSheet;
		private var _mask:Rectangle;
		private var _linkViewer:LinkViewer;
		private var _propalsLinks:PropalsLinks;
		private var _lectureRapideBtn:CustomTextButton;
		private var _separationTexts:Shape;
		private var _propalIsOpen:Boolean = false;
		//
		public var close_btn:SimpleButton;
		public var propal_ct:SimpleButton;
		public var level_tf:TextField;
		public var label_tf:TextField;
		public var comment_tf:TextField;
		public var activePropal_mc:MovieClip;
		public var lectureRapide_tf:TextField;
		public var arguDonnees_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function PropalViewer() {
			this.visible = false;
			_trace = SuperTrace.getTrace();
			_mgr = NavManager.getMgr();
			_translator = Translator.getInstance();
			activePropal_mc.alpha = 0;
			_antecsContainer = new Sprite();
			_antecsContainer.x = 24;
			_antecsContainer.y = 110;
			this.addChild(_antecsContainer);
			_antecs = new Array();
			_mediaViewer = new MediaViewer();
			_mediaViewer.x = 370;
			_mediaViewer.y = 168;
			this.addChild(_mediaViewer);
			_linkViewer = new LinkViewer();
			_linkViewer.x = 370;
			_linkViewer.y = 168;
			this.addChild(_linkViewer);
			propal_ct.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { openPropal(_ed); } );
			close_btn.addEventListener(MouseEvent.CLICK, close);
			
			//création de l'ascenseur
			_mask = new Rectangle(comment_tf.x, comment_tf.y, comment_tf.width, 66);
			_asc = new Ascenseur(comment_tf, _mask);
			this.addChild(_asc);
			_ascCmd = new AscenseurCommand(_asc);
			_ascCmd.x = 980;
			_ascCmd.y = 135;
			this.addChild(_ascCmd);
			
			// Onglets "Propositions"
			_propalsLinks = new PropalsLinks;
			_propalsLinks.x = 356;
			_propalsLinks.y = 45;
			this.addChild(_propalsLinks);
			_propalsLinks.addEventListener(Event.OPEN, function(evt:Event) { 
				openPropal(_propalsLinks.clickedElementData);
			});
			
			_lectureRapideBtn = new CustomTextButton(_translator.translate("retour_lecture_rapide").toUpperCase());
			_lectureRapideBtn.setPosition(new Point(694, 638));
			_lectureRapideBtn.addEventListener(MouseEvent.CLICK, close);
			this.addChild(_lectureRapideBtn);
			
			_separationTexts = new Shape();
			_separationTexts.graphics.lineStyle(1, 0xFFFFFF);
			_separationTexts.graphics.moveTo(0, 4);
			_separationTexts.graphics.lineTo(0, 15);
			this.addChild(_separationTexts);
			_separationTexts.y = _lectureRapideBtn.y;
			_separationTexts.x = _lectureRapideBtn.x + _lectureRapideBtn.width + 7;
			arguDonnees_tf.x = _separationTexts.x + 7;
			arguDonnees_tf.text = _translator.translate("argu_donnees");
			
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 * @param	p_ed
		 */
		public function open(p_ed:EDPropal = null) {
			this.alpha = 0;
			this.visible = true;
			Tweener.removeTweens(this);
			Tweener.addTween(this, { alpha:1, time:0.75, transition:"easeOutQuart" } );
			if (p_ed) {
				openPropal(p_ed);
			}
			
			_propalsLinks.open();
		}
		/**
		 * 
		 * @param	p_ed
		 */
		public function openPropal(p_ed:EDPropal) {
			_trace.debug("PropalViewer.openPropal.");
			if(!_propalIsOpen || p_ed != _ed) {
				_style = BasicFormat.getInstance();
				_css = _style.getBasicCSS();
				
				_ed = p_ed;
				level_tf.text = _ed.P;
				
				label_tf.styleSheet = _css;
				label_tf.htmlText = _style.transformItaTags(_ed.title);
				
				comment_tf.y = 82;
				comment_tf.styleSheet = _css;
				comment_tf.htmlText = _style.transformItaTags(_ed.comment);
				comment_tf.height = comment_tf.textHeight + 10;
				//_ascCmd.visible = true;
				_ascCmd.checkHeights();

				_createAntecs();
				//_setPrevNext();
				_mediaViewer.openIllust(new EDIllust(_ed.raw));
				_linkViewer.close();
				activePropal_mc.alpha = 0;
				
				_propalsLinks.update();
				
				_propalIsOpen = true;
				
				this.dispatchEvent(new Event(Event.OPEN));
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		public function close(evt:MouseEvent = null) {
			Tweener.removeTweens(this);
			Tweener.addTween(this, { alpha:0, time:0.5, transition:"easeOutQuart", onComplete:function() {
				visible = false;
			}});
			_mediaViewer.close();
			this.dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**
		 * Crée la liste des antécédents associés à cette proposition
		 */
		private function _createAntecs() {
			var elts:Array = _mgr.getAntecs(_ed.id);
			var i:int;
			var N:int = elts.length;
			
			_trace.debug("createAntecs, N : " + N);
			
			_resetAntecs();
			
			for (i = 0; i < N; i++) {
				var btn:AntecButton = new AntecButton(elts[i]);
				btn.setPosition(new Point(0, i * 57));
				
				//btn.addEventListener(MouseEvent.MOUSE_OVER, _btnOver);
				//btn.addEventListener(MouseEvent.MOUSE_OUT, _btnOut);
				btn.addEventListener(MouseEvent.CLICK, _antecClick);
				
				_antecsContainer.addChild(btn);
				_antecs.push(btn);
			}
			
		}
		/**
		 * Supprime toute la liste des antécédents
		 */
		private function _resetAntecs() {
			var i:int;
			var N:int = _antecs.length;
			for (i = 0; i < N; i++) {
				var btn:AntecButton = _antecs.shift();
				_antecsContainer.removeChild(btn);
			}
		}
		/**
		 * Clic sur un antédécent
		 * @param	evt
		 */
		private function _antecClick(evt:MouseEvent) {
			var eb:AntecButton = evt.target as AntecButton;
			var ed:EDAntec = eb.elementData;
			_trace.debug("Ouverture antecedant " + eb.elementData.id);
			eb.setActive();
			var nbAntecs:int = _antecs.length;
			for (var i:int = 0; i < nbAntecs; i++) {
				if (eb != _antecs[i] && _antecs[i].active == true) {
					_antecs[i].setNormal();
				}
				activePropal_mc.alpha = 1;
			}
			
			switch(ed.type) {
				case EDAntec.TYPE_PERTINENT:
					_mediaViewer.openIllust(new EDIllust(eb.elementData.raw));
					_linkViewer.close();
					_ascCmd.visible = true;
					break;
				case EDAntec.TYPE_LIEN:
					// L'antécédent est du type Lien
					//_trace.debug("### L'antécédent est du type lien : " + ed.linkBaseId + " / " + ed.linkEtapeId + " / " + ed.linkPropalId);
					_mediaViewer.close();
					_linkViewer.getReady();
					_mgr.openLinkedPropal(ed);
					_ascCmd.visible = false;
					break;
				default: 
					_trace.error("PropalViewer : type d'antécédent inconnu (" + ed.type + ")");
					break;				
			}
			
			comment_tf.y = 82;
			comment_tf.htmlText = _style.transformItaTags(eb.elementData.comment);
			comment_tf.height = comment_tf.textHeight + 10;
			_ascCmd.checkHeights();
			
			_propalIsOpen = false;
		}
		/**
		 * Passe à la proposition suivante
		 * @param	evt
		 */
		private function _propalPrev(evt:MouseEvent = null) {
			var newED:EDPropal;
			if (_ed.listIndex > 0) {
				newED = _mgr.getPropalByIndex(_ed.listIndex - 1)
				this.openPropal(newED);
			}
		}
		/**
		 * Passe à la proposition précédente
		 * @param	evt
		 */
		private function _propalNext(evt:MouseEvent = null) {
			var newED:EDPropal;
			if (_ed.listIndex < _mgr.getMaxPropals()) {
				newED = _mgr.getPropalByIndex(_ed.listIndex + 1)
				this.openPropal(newED);
			}
		}
		
		
		public function get openedEDPropal():EDPropal {	return _ed;	}
		
	}
	
}