package com.thequest.epist {
	
	import flash.events.Event;
	/**
	 * ...
	 * @author nlgd
	 */	
	public class NavEvent extends Event {
		public static const OPEN_RUB:String = "openRub";
		public static const OPEN_CONTENT:String = "openContent";
		public static const PREPARE:String = "prepare";
		
		public static const OPEN_US:String = "openUniteSon";
		public static const US_ADD_LANG:String = "addLang";
		
		public static const OPEN_USLIST:String = "openUsList";
		public static const CLEAN_USLIST:String = "cleanUsList";
		
		public function NavEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false ) {
			super(type, bubbles, cancelable);
		}
	}
}