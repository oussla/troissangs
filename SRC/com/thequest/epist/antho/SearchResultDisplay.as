package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.BasicFormat;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class SearchResultDisplay extends Sprite	{
		private var _trace:SuperTrace;
		private var _us:USData;
		private var _tf:TextField;
		
		public function SearchResultDisplay(p_us:USData, p_corpus:int) {
			_trace = SuperTrace.getTrace();
			var cFormat:CorpusFormats = CorpusFormats.getInstance();
			var bFormat:BasicFormat = BasicFormat.getInstance();
			
			var css:StyleSheet = cFormat.getMultiLevelsCSS(p_corpus);
			// Ajoute un style pour les US
			css.setStyle(".us", { color:"#FFFFFF", fontSize:14 } );
			css.setStyle(".pattern", { color:"#0099FF", fontSize:14 } );
			css.setStyle(".verses", { color:"#CCCCCC", fontSize:10 } );
			
			_us = p_us;
			_tf = new TextField();
			_tf.width = 470;
			_tf.height = 20;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.styleSheet = css;
			_tf.embedFonts = true;
			_tf.selectable = false;
			_tf.wordWrap = true;
			
			var rdList:Array = AnthoManager.getInstance().getPathSup(_us);
			var rd:RepData;
			var N:int = rdList.length;
			var alinea:String = "";
			var title:String;
			var str:String = "<body>";
			for (var i:int = 0; i < N; i++) {
				rd = rdList[i];
				title = rd.rawTitle;
				if (i < 3) title = title.toUpperCase();
				title = bFormat.transformItaTags(title);
				str += alinea + "<span class=\"level" + i + "\">" + title + "</span>\n";
				alinea += "&nbsp;&nbsp;&nbsp;";
			}
			str += "<span class=\"verses\">" + _us.firstVerseNumber + " - " + _us.lastVerseNumber + "</span>" + alinea + "<a href=\"event:open\"><span class=\"us\">" + bFormat.transformItaTags(_us.searchSample) + "</span></a>";
			str += "</body>";
			_tf.htmlText = str;
			_tf.addEventListener(TextEvent.LINK, function(evt:TextEvent) {
				dispatchEvent(new Event(Event.OPEN, false, true));
			});
			this.addChild(_tf);
			// Trace ligne en fin
			this.graphics.beginFill(0x959A9E);
			//this.graphics.beginGradientFill(GradientType.LINEAR, [0x959A9E, 0x959A9E], [1, 0], [0, 128]);
			this.graphics.drawRect(0, _tf.height + 5, 470, 1);
			this.graphics.endFill();
			
		}
		
		public function get usData():USData {
			return _us;
		}

		
	}
	
}