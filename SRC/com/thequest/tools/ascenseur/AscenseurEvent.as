package com.thequest.tools.ascenseur{

	
	import flash.events.Event;
	
	public class AscenseurEvent extends Event {
		public static const MAX_DOWN:String = "maxDown";
		public static const MAX_UP:String = "maxUp";

		public function AscenseurEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false ) {
			super(type, bubbles, cancelable);
		}
	}
}