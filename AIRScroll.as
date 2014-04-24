package com.erichlotto
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class AIRScroll
	{
		
		//==========================================================//
		//															//
		//							VARS							//
		//															//
		//==========================================================//
		
		private var ATRITO:Number=.8;
		private var _mc:MovieClip;
		private var scrollArea:Rectangle;
		private var speed:Point=new Point();
		private var _prev_mouse_pos:Point=new Point();
		private var _mouseIsDown:Boolean=false;
		private var barrinha:MovieClip;
		private var areaMascara:Rectangle; // variavel usada apenas na funcao de ajuste da barrinha
		private var _orientacao:String;
		private var mascara:MovieClip;
		private var visibility:Boolean;
		public var IsDragging:Boolean=false;
		private var touchedPoint:Point;
		
		//==========================================================//
		//															//
		//						FUNCTIONS							//
		//															//
		//==========================================================//
		public function addAIRScroll(mc:MovieClip,		//MovieClip a ganhar o scroll
								  retangulo:Rectangle,
								  orientacao:String='VERTICAL',
								  _visibility:Boolean=true
								  ):void
		{
			if((mc.height<retangulo.height && orientacao=='VERTICAL') || (mc.width<retangulo.width && orientacao=='HORIZONTAL'))return;
			visibility=_visibility;
			_mc = mc;
			_orientacao=orientacao;
			if(orientacao=='VERTICAL')scrollArea=new Rectangle(retangulo.x,retangulo.y-mc.height+retangulo.height,0,mc.height-retangulo.height);
			else if(orientacao=='HORIZONTAL')scrollArea=new Rectangle(retangulo.x-mc.width+retangulo.width,mc.y,mc.width-retangulo.width,0);
			else trace("Stupid orientation will not be accepted! Use HORIZONTAL or VERTICAL");
			_mc.addEventListener(MouseEvent.MOUSE_DOWN, MOUSE_DOWN);
			mascara=new MovieClip();
			_mc.parent.addChild(mascara);
			mascara.name='mascara';
//			mascara.x=_mc.x;
//			mascara.y=_mc.y;
			var my_shape:Shape=new Shape();
			mascara.addChild(my_shape);
			my_shape.graphics.beginFill(0x000000,1); 
			my_shape.graphics.drawRect(retangulo.x,retangulo.y,retangulo.width,retangulo.height);
			my_shape.graphics.endFill();
			areaMascara=new Rectangle(retangulo.x,retangulo.y,retangulo.width,retangulo.height);
			_mc.mask=mascara;
			
			
			var myshape:Shape=new Shape();
			if(orientacao=='VERTICAL')
			{
				barrinha = new MovieClip();
				_mc.parent.addChild(barrinha);
				barrinha.name='barrinha';
				barrinha.x=_mc.x+_mc.width-10;
				barrinha.y=_mc.y;
				barrinha.addChild(myshape);
				myshape.graphics.beginFill(0xCCCCCC,.8); 
				myshape.graphics.drawRoundRect(0,0,10,retangulo.height*(retangulo.height/_mc.height), 10);
//				myshape.graphics.drawRect(0,0,10,retangulo.height*(retangulo.height/_mc.height));
				myshape.graphics.endFill();
				barrinha.alpha=0;
			}
			if(orientacao=='HORIZONTAL')
			{
				barrinha = new MovieClip();
				_mc.parent.addChild(barrinha);
				barrinha.name='barrinha';
				barrinha.x=_mc.x;
				barrinha.y=_mc.y+_mc.height-10;
				barrinha.addChild(myshape);
				myshape.graphics.beginFill(0xCCCCCC,.8);
				myshape.graphics.drawRoundRect(0, 0, retangulo.width*(retangulo.width/_mc.width),10, 10);
//				myshape.graphics.drawRect(0,0,retangulo.width*(retangulo.width/_mc.width),10);
				myshape.graphics.endFill();
				barrinha.alpha=0;
			}
			if(!visibility)barrinha.visible=false;
						
			
		}
		
		public function removeAIRScroll():void
		{
			if(_mc)_mc.stage.removeEventListener(MouseEvent.MOUSE_UP, MOUSE_UP);
			if(_mc)_mc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, MOUSE_MOVE);
			if(_orientacao)_orientacao=undefined;
			if(scrollArea)scrollArea=null;
			if(areaMascara)areaMascara=null;
			if(_mc)_mc.mask=null;
			if(_mc)_mc.stopDrag();
			_mouseIsDown=false;
			if(mascara)mascara.parent.removeChild(mascara);
			
			if(_mc)_mc.removeEventListener(MouseEvent.MOUSE_DOWN, MOUSE_DOWN);
			if(_mc)_mc.removeEventListener(Event.ENTER_FRAME, ENTER_FRAME);
			if(barrinha)barrinha.removeEventListener(Event.ENTER_FRAME,alphaDown);
			if(barrinha)barrinha.parent.removeChild(barrinha);
			if(_mc)_mc = null;
			
			if(mascara)mascara=null;
			if(barrinha)barrinha=null;
			IsDragging=false;
		}
		
		private function MOUSE_DOWN(e:MouseEvent):void
		{
			touchedPoint=new Point(_mc.stage.mouseX,_mc.stage.mouseY);
			trace(touchedPoint.x+" "+touchedPoint.y);
			IsDragging=false;
			barrinha.removeEventListener(Event.ENTER_FRAME,alphaDown);
			barrinha.alpha=1;
			_mouseIsDown=true;
			_mc.addEventListener(Event.ENTER_FRAME, ENTER_FRAME);
			_mc.stage.addEventListener(MouseEvent.MOUSE_UP, MOUSE_UP);
			_mc.stage.addEventListener(MouseEvent.MOUSE_MOVE, MOUSE_MOVE);
			_mc.startDrag(false, scrollArea);
		}
		
		private function ENTER_FRAME(e:Event):void
		{
			if (_mouseIsDown) {
				// Set speed here, but don't use it while mouse is pressed
				speed.x = _mc.x - _prev_mouse_pos.x;
				speed.y = _mc.y - _prev_mouse_pos.y;
			}
			else {
				// Mouse is released, meaning that it has been tossed, so move
				// object according to speed vector, and decrease speed.
				_mc.x += speed.x*1.5;//Math.min(speed.x, 50);
				_mc.y += speed.y*1.5;//Math.min(speed.y, 50);
				
				speed.x *= ATRITO;
				speed.y *= ATRITO;
				
				
				// Negligible speed, so stop the processing to save resources
				if (speed.length < 0.05) {
					_mc.removeEventListener(Event.ENTER_FRAME, ENTER_FRAME);
					barrinha.addEventListener(Event.ENTER_FRAME,alphaDown);
				}
			}
			_prev_mouse_pos.x = _mc.x;
			_prev_mouse_pos.y = _mc.y;
			if(_mc.y<scrollArea.y)_mc.y=scrollArea.y;
			if(_mc.y>scrollArea.y+scrollArea.height)_mc.y=scrollArea.y+scrollArea.height;
			if(_mc.x<scrollArea.x)_mc.x=scrollArea.x;
			if(_mc.x>scrollArea.x+scrollArea.width)_mc.x=scrollArea.x+scrollArea.width;
			
			if(_orientacao=='VERTICAL')barrinha.y = areaMascara.y + (areaMascara.height - barrinha.height) * map(_mc.y, areaMascara.y, (areaMascara.y+areaMascara.height-_mc.height),0,1);
			else if(_orientacao=='HORIZONTAL')barrinha.x = areaMascara.x + (areaMascara.width - barrinha.width) * map(_mc.x, areaMascara.x, (areaMascara.x+areaMascara.width-_mc.width),0,1);
		}
		
		private function map(v:Number, a:Number, b:Number, x:Number = 0, y:Number = 1):Number
		{
			return (v == a) ? x : (v - a) * (y - x) / (b - a) + x;
		}
		
		private function MOUSE_UP(e:MouseEvent):void
		{
			_mc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, MOUSE_MOVE);
			_mouseIsDown=false;
			//_mc.removeEventListener(Event.ENTER_FRAME, ENTER_FRAME);
			_mc.stage.removeEventListener(MouseEvent.MOUSE_UP, MOUSE_UP);
			_mc.stopDrag();
		}
		
		private function MOUSE_MOVE(e:MouseEvent):void
		{
			if(_mc.stage.mouseX<touchedPoint.x-10
			|| _mc.stage.mouseX>touchedPoint.x+10
			|| _mc.stage.mouseY<touchedPoint.y-10
			|| _mc.stage.mouseY<touchedPoint.y-10)   {

			IsDragging=true;
			e.updateAfterEvent(); //Makes the animation smoother;
			}
		}
		
		private function alphaDown(e:Event):void
		{
			e.currentTarget.alpha-=.05;
			if(e.currentTarget.alpha<=0)e.currentTarget.removeEventListener(Event.ENTER_FRAME,alphaDown);
		}
	}
}