package com.thequest.epist {
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class ContentScreen extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		// Définit le contexte de l'écran
		public static const DEFAULT:String = "Default";
		public static const ARGU:String = "Argumentaire";
		public static const ANTHO:String = "Anthologie";
		//		
		protected var _appNav:AppNav;
		protected var _context:String = DEFAULT;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function ContentScreen() {
			_appNav = AppNav.getInstance();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Affichage
		 */
		public function show() {
			this.alpha = 0;
			this.visible = true;
			Tweener.addTween(this, { alpha:1, time:1.5, transition:"easeInOutQuart" } );
		}
		/**
		 * Fermeture
		 */
		public function close() {
			this.dispatchEvent(new Event(Event.CLOSE));
			/*
			Tweener.addTween(this, { alpha:0, time:0.75, transition:"easeInOutQuart", onComplete:function() {
				dispatchEvent(new Event(Event.CLOSE));
			} } );
			*/
		}
		
		public function get context():String {
			return _context;
		}
		
	}
	
}