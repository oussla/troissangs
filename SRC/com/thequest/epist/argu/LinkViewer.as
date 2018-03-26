package com.thequest.epist.argu {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.BasicFormat;
	import com.thequest.epist.EDArticle;
	import com.thequest.epist.EDEtape;
	import com.thequest.epist.EDPropal;
	import com.thequest.epist.Translator;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import com.thequest.epist.argu.NavManagerEvent;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class LinkViewer extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _mgr:NavManager;
		private var _css:StyleSheet;
		private var _bFormat:BasicFormat;
		private var _translator:Translator;
		
		public var infos_tf:TextField;
		public var legend_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function LinkViewer() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello LinkViewer !");
			_mgr = NavManager.getMgr();
			_translator = Translator.getInstance();
			
			_bFormat = BasicFormat.getInstance();
			_css = _bFormat.getBasicCSS();
			_css.setStyle(".article", { color:"#FFFFFF", fontSize:18 } );
			_css.setStyle(".etape", { color:"#FFFFFF", fontSize:18 } );
			_css.setStyle(".propal", { color:"#FFFF99", fontSize:15 } );
			
			
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function getReady() {
			_mgr.removeEventListener(NavManagerEvent.LINKED_PROPAL_READY, _propalIsReady);
			_mgr.addEventListener(NavManagerEvent.LINKED_PROPAL_READY, _propalIsReady);
		}
		/**
		 * Ouvre le viewer, avec ou sans la proposition p_ed
		 * @param	p_ed
		 */
		public function open() {
			this.alpha = 0;
			this.visible = true;
			Tweener.removeTweens(this);
			Tweener.addTween(this, { alpha:1, time:0.75, transition:"easeOutQuart" } );
			_openLinkDatas();
			
		}
		/**
		 * 
		 */
		public function close() {
			this.visible = false;
		}
		/**
		 * Déclenché par l'evt. COMPLETE envoyé par le NavManager
		 * @param	evt
		 */
		private function _propalIsReady(evt:Event) {
			// Supprime l'écouteur sur le manager pour éviter des déclenchements intempestifs
			//_mgr.removeEventListener(Event.COMPLETE, _propalIsReady);
			_mgr.removeEventListener(NavManagerEvent.LINKED_PROPAL_READY, _propalIsReady);
			open();
		}
		/**
		 * Ouvre la proposition p_ed
		 * @param	p_ed
		 */
		private function _openLinkDatas() {
			var edArticle:EDArticle = _mgr.linkedArticle;
			var edEtape:EDEtape = _mgr.linkedEtape;
			var edPropal:EDPropal = _mgr.linkedPropal;
			
			_trace.debug("LinkViewer._openLinkDatas");
			
			legend_tf.text = _translator.translate("linkviewer_legend");
			
			var str:String = "<body>" +
							 "<span class=\"article\">" + edArticle.title.toUpperCase() + "</span>\n\t" +
							 "<span class=\"etape\">" + edEtape.title + "</span>\n\t\t" +
							 "<span class=\"propal\">" + edPropal.P+ " " +edPropal.title + "</span>" +
							 "</body>";
			
			//_trace.debug("_openLinkDatas, str : " + str);
			
			str = _bFormat.transformItaTags(str);
			infos_tf.styleSheet = _css;
			infos_tf.htmlText = str;
			
		}
		
	}
	
}