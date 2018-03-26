package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.CustomTextButton;
	import com.thequest.epist.Translator;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class DescUsSwitch extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		public static const DESC:String = "desc";
		public static const US:String = "us";
		//
		private var _trace:SuperTrace;
		private var _translator:Translator;
		private var _barre:Sprite;
		private var _selected:String;
		
		private var desc_btn:CustomTextButton;
		private var us_btn:CustomTextButton;
		//
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function DescUsSwitch() {
			_trace = SuperTrace.getTrace();
			_translator = Translator.getInstance();
			_barre = new Sprite();
			_barre.graphics.lineStyle(1, 0x545454);
			_barre.graphics.moveTo(0, 0);
			_barre.graphics.lineTo(0, 9);
			_barre.y = 5;
			this.addChild(_barre);
			
			desc_btn = new CustomTextButton(_translator.translate("description").toUpperCase(), TextFieldAutoSize.LEFT, 0x7D7D7D, 0xFFFFFF, 0xFFFFFF);
			us_btn = new CustomTextButton(_translator.translate("unite_son").toUpperCase(), TextFieldAutoSize.LEFT, 0x7D7D7D, 0xFFFFFF, 0xFFFFFF);
			us_btn.x = desc_btn.x + desc_btn.width + 10;
			_barre.x = desc_btn.x + desc_btn.width + 5;
			
			desc_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				selectDesc();
				dispatchEvent(new Event(Event.CHANGE));
			} );
			us_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				selectUs();
				dispatchEvent(new Event(Event.CHANGE));
			} );
			
			this.addChild(desc_btn);
			this.addChild(us_btn);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 */
		public function selectUs() {
			_trace.debug("DescUsSwitch.selectUs");
			_selected = DescUsSwitch.US;
			us_btn.enable();
			desc_btn.enable();
			us_btn.setActive();
			desc_btn.setNormal();
		}
		/**
		 * Désactive le bouton US
		 */
		public function desactiveUs() {
			_trace.debug("DescUsSwitch.desactiveUs");
			us_btn.disable();
		}
		/**
		 * Selon bool, change l'état de DESC en sélectionné / non sélectionné
		 * @param	bool
		 */
		public function selectDesc() {
			_trace.debug("DescUsSwitch.selectDesc");
			_selected = DescUsSwitch.DESC;
			us_btn.enable();
			desc_btn.enable();
			us_btn.setNormal();
			desc_btn.setActive();
		}
		/**
		 * Désactive le bouton Desc
		 */
		public function desactiveDesc() {
			_trace.debug("DescUsSwitch.desactiveDesc");
		}
		/**
		 * Renvoi l'indicateur sur la partie sélectionnée
		 */
		public function get selected():String {
			return _selected;
		}
	}
	
}