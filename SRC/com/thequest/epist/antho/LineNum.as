package com.thequest.epist.antho 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	/**
	 * ...
	 * @author 
	 */
	
	public class LineNum extends MovieClip {
		
		public var numTf:TextField;
		
		public function LineNum() {
			
		}
		
		public function setNum(num:String):void {
			//trace("LineNum.setNum : "+num);
			numTf.text = num;
		}
		
		public function clear():void {
			//trace("LineNum.clear");
			numTf.text = "";
		}
	}

}