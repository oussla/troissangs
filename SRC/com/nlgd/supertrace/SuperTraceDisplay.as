/**
*
*
*	SuperTraceDisplay
*	
*	@author	NLGD
*	@version	0.1
*
*/

package com.nlgd.supertrace {
	
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	
	public class SuperTraceDisplay {		
		
		private var superTrace:SuperTrace;
		private var target:DisplayObjectContainer;
		private var tf:TextField;
		
		
		public function SuperTraceDisplay(p_superTrace:SuperTrace, p_target:DisplayObjectContainer, p_tf:TextField = null) {
			target = p_target;
			
			superTrace = p_superTrace;
			superTrace.addEventListener(SuperTraceEvent.MESSAGE, update);
			
			if(p_tf != null) {
				tf = p_tf;
			} else {
				tf = new TextField();
				tf.x = 10; 
				tf.y = 10;
				tf.width = 250; 
				tf.height = 250;
				//target.addChildAt(tf, 3);
				target.addChild(tf);
				tf.selectable = false;
				tf.multiline = true;
				//tf.embedFonts = true;
				tf.wordWrap = true;
			}

		}
		
		public function update(evt:SuperTraceEvent):void {
			//trace(superTrace.getMessage());
			tf.appendText(superTrace.getMessage() + "\n");
			tf.scrollV = tf.maxScrollV;
		}
		
		public function flush():void {
			tf.text = "";
		}
		
	}
	
}