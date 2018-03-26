package com.thequest.epist.antho {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import com.thequest.epist.NavEvent;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import com.thequest.epist.NavEvent;
	
		public class USList extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _usListArray:Array;
		private var _nbUsData:int;
		private var _USButtonArray:Array;
		private var _posY:int = 0;
		private var _isOpen:Boolean = false;
		
		public var label_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function USList() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello USList!");
			_usListArray = new Array();
			_USButtonArray = new Array();
		}
		
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		
		public function update(repData:RepData) {
			_trace.debug("USList.update");
			
			var cf:CorpusFormats = CorpusFormats.getInstance();
			var css:StyleSheet = cf.getCSS(repData.corpus, repData.level);
			
			label_tf.styleSheet = css;
			label_tf.htmlText = repData.title;
			label_tf.x = 90;
			this.addChild(label_tf);
			_usListArray = repData.getUSList();
			_nbUsData = _usListArray.length;
			
			for (var i:int = 0; i < _nbUsData; i++) {
				var usD:USData = _usListArray[i] as USData;
				_USButtonArray[i] = new USButton(usD);
				_USButtonArray[i].x = 0;
				_USButtonArray[i].y = _posY;
				this.addChild(_USButtonArray[i]);
				_posY = 5 + _posY + _USButtonArray[i].height;
			}
			
			this.show();
		}
		/**
		 * 
		 */
		public function show() {
			if (!_isOpen) {
				_isOpen = true;
				this.alpha = 0;
				this.visible = true;
				Tweener.addTween(this, { alpha:1, time:1, transition:"easeOutQuart" } );
			}
		}
		/**
		 * 
		 */
		public function hide() {
			this.visible = false;
			this.alpha = 0;
			_isOpen = false;
		}
		/**
		 * 
		 */
		public function cleanList() {
			//_trace.debug("USList.cleanList");
			var tmpLength:int = _USButtonArray.length;
			for (var i:int = 0; i < tmpLength; i++) {
				if (this.contains(_USButtonArray[i]))
					this.removeChild(_USButtonArray[i])
			}
			label_tf.text = "";
			if (this.contains(label_tf))
				this.removeChild(label_tf);
				
			_usListArray = new Array();
			_USButtonArray = new Array();
			_posY = label_tf.height + 20;
		}

	}
}