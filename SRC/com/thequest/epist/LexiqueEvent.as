package com.thequest.epist 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class LexiqueEvent extends Event 
	{
		
		public static const READY:String = "ready";
		
		public function LexiqueEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new LexiqueEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LexiqueEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}