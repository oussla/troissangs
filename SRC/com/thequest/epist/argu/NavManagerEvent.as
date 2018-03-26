package com.thequest.epist.argu 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class NavManagerEvent extends Event 
	{
		
		public static const LINKED_PROPAL_READY:String = "linkedPropalReady";
		
		public function NavManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new NavManagerEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("NavManagerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}