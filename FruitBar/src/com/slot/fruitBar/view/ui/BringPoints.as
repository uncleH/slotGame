package com.slot.fruitBar.view.ui
{
	import com.slot.fruitBar.events.PlayGameEvent;
	import com.slot.fruitBar.view.View;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	
	/**带入点数视图*/
	public class BringPoints extends View
	{
		private var _btnPool:Vector.<GameBtn>;
		private var _pointsTextfield:GameText;
		private var _cancleBtn:GameBtn;
		private var _allinBtn:GameBtn;
		private var _submitBtn:GameBtn;
		private var _closeBtn:Button;
		private var _checkbox:Checkbox;
		private var _tips3:GameText;
		
		private var _totalPoint:int;
		private var _recentPoint:int;
		private var _currentPoint:int;
		private var _isChecked:Boolean;
		private var _minPoint:int;
		
		public function BringPoints()
		{
			drawScene();
		}
		
		override protected function drawScene():void
		{ 
			//创建半透明黑色背景
			var mShape:Shape = new Shape();
			mShape.graphics.beginFill(0,1);
			mShape.graphics.drawRect(0,0,1098,720);
			mShape.graphics.endFill();
			
			var mBitmapData:BitmapData = new BitmapData(mShape.width,mShape.height);
			mBitmapData.draw(mShape);
			
			var colorBg:Image = new Image(Texture.fromBitmapData(mBitmapData,false));
			colorBg.touchable = false;
			colorBg.alpha = 0.5;
			addChild(colorBg);
			
			mBitmapData.dispose();
			mBitmapData = null;
			mShape = null;
			
			//显示框的背景图片
			var bgImage:Image = new Image(Assets.getTexture("ALERTBG",true));
			bgImage.touchable = false;
			bgImage.x = (colorBg.width - bgImage.width) * 0.5;
			bgImage.y = (colorBg.height - bgImage.height) *0.5;
			addChild(bgImage);
			
			//标题
			var titleChar:Image = new Image(Assets.getTextureAtlas().getTexture("bringPointString"));
			titleChar.touchable = false;
			titleChar.y = bgImage.y + 30;
			titleChar.x = bgImage.x + (bgImage.width - titleChar.width ) * 0.5;
			addChild(titleChar);
			
			//点数显示文本框背景
			var textfieldBg:Image = new Image(Assets.getTextureAtlas().getTexture("textfieldBg2"));
			textfieldBg.touchable = false;
			textfieldBg.x = bgImage.x + 70;
			textfieldBg.y = titleChar.y + 80;
			addChild(textfieldBg);
			
			//点数显示文本框
			_pointsTextfield = new GameText(258,46,"0","Verdana",30);
			_pointsTextfield.x = textfieldBg.x;
			_pointsTextfield.y = textfieldBg.y;
			addChild(_pointsTextfield);
			
			
			_btnPool = new Vector.<GameBtn>();
			var btn:GameBtn;
			var colorfilter:ColorMatrixFilter = new ColorMatrixFilter();
			colorfilter.matrix = Vector.<Number>([
				1,0,0,0,0,
				1,0,0,0,0,
				1,0,0,0,0,
				0,0,0,1,0
			]);
			
			for(var i:int = 0; i < 10; i++)
			{
				btn = new GameBtn("blueBtn-01","blueBtn-02","goldenNumber-0"+i);
				btn.x = bgImage.x + 70 + (i%5) * (btn.width +  4);
				btn.y = bgImage.y + 170 + Math.floor(i/5) * (btn.height + 4);
				btn.addEventListener(Event.TRIGGERED,onTrigger);
				btn.setIconFilter(colorfilter);
//				btn.scaleIcon(1.8);
				_btnPool[i] = btn;
				addChild(_btnPool[i]);
			}
			
			_cancleBtn = new GameBtn("redBtn-01","redBtn-02","cancelChar");
			_cancleBtn.addEventListener(Event.TRIGGERED,onTrigger);
			_cancleBtn.y = textfieldBg.y;
			_cancleBtn.x = titleChar.x + titleChar.width;
			addChild(_cancleBtn);
			
			_allinBtn = new GameBtn("greenBtn-01","greenBtn-02","allChar");
			_allinBtn.addEventListener(Event.TRIGGERED,onTrigger);
			_allinBtn.y = _cancleBtn.y + _cancleBtn.height + 10;
			_allinBtn.x = _cancleBtn.x;
			addChild(_allinBtn);
			
			_submitBtn = new GameBtn("greenBtn-01","greenBtn-02","submitChar");
			_submitBtn.addEventListener(Event.TRIGGERED,onTrigger);
			_submitBtn.y = _allinBtn.y + _allinBtn.height + 10;
			_submitBtn.x = _cancleBtn.x;
			addChild(_submitBtn);
			
			_closeBtn = new Button(Assets.getTextureAtlas().getTexture("x"));
			_closeBtn.addEventListener(Event.TRIGGERED,onTrigger);
			_closeBtn.y = bgImage.y + 15;
			_closeBtn.x = bgImage.x + bgImage.width - _closeBtn.width - 15;
			addChild(_closeBtn);
			
			var tips1:GameText = new GameText(150,32,"最低攜帶點數 ","Verdana",18,0xffffff);
			tips1.x = Math.round(textfieldBg.x + (textfieldBg.width - tips1.width)*0.5);
			tips1.y = _btnPool[6].y + _btnPool[6].height + 10;
			addChild(tips1);
			
			var tips2:GameText = new GameText(76,32,"記憶點數 ","Verdana",18,0xffffff);
			tips2.y = tips1.y;
			tips2.x = _cancleBtn.x;
			addChild(tips2);
			
			_checkbox = new Checkbox();;
			_checkbox.addEventListener(Event.TRIGGERED,onTrigger);
			_checkbox.y = tips2.y + (tips2.height - _checkbox.height) * 0.8;
			_checkbox.x = tips2.x + tips2.width + 10;
			addChild(_checkbox);

			//点数输入错误，显示错误提示
			_tips3 = new GameText(76,32,"点数不够","Verdana",18,0xff0000);
			_tips3.y = textfieldBg.y - 30;
			_tips3.x = textfieldBg.x + (textfieldBg.width - _tips3.width) * 0.5;
			_tips3.visible = false;
			addChild(_tips3);
		}
		
		/**
		 * 初始化带入点数的基本数据 
		 * @param totalPoint		最多能带入的点数
		 * @param recentPoint		历史带入的点数
		 * @param minPoint          最低带入的点数
		 * 
		 */		
		public function initBringPoint(totalPoint:int,recentPoint:int,minPoint:int):void
		{
			_minPoint = minPoint;
			_totalPoint = totalPoint;
			_recentPoint = recentPoint;
			
			//如果有历史的带入点数，则历史带入点数，否则显示玩家的总点数
			_currentPoint = _recentPoint == 0?_totalPoint:_recentPoint;
			updateCurrentPoint();
		}
		
		private function onTrigger(event:Event):void
		{
			var index:int = _btnPool.indexOf(event.currentTarget as GameBtn);
			if(index != -1)
			{
				if(_currentPoint > 0)
				{
					_currentPoint = _currentPoint * 10 + index;
				}
				else
				{
					_currentPoint = index;
				}
				updateCurrentPoint();
				return;
			}
			
			switch(event.currentTarget)
			{
				case _cancleBtn:
					_tips3.visible = false;
					_currentPoint = 0;
					updateCurrentPoint();
					break;
				case _allinBtn:
					_currentPoint = _totalPoint;
					updateCurrentPoint();
					break;
				case _submitBtn:
					if(_currentPoint > _totalPoint)
					{
						_tips3.text = "点数不够";
						_tips3.visible = true;
					}
					else if(_currentPoint < _minPoint)
					{
						_tips3.text = "小於最小帶入點數";
						_tips3.visible = true;
					}
					else
					{
						dispatchEvent(new PlayGameEvent(PlayGameEvent.BRINGPINTS,false,{bringPoints:_currentPoint}));
					}
					break;
				case _closeBtn:
					dispatchEvent(new PlayGameEvent(PlayGameEvent.BACKTODESKLOBBY));
					break;
				default:
					break;
			}
		}
		
		private function updateCurrentPoint():void
		{
			_pointsTextfield.text = _currentPoint.toString();
		}
		
		override public function dealloc():void
		{
			var child:*;
			while(numChildren > 0)
			{
				child = getChildAt(0);
				if(child as GameBtn)
				{
					(child as GameBtn).dealloc();
					continue;
				}
				else if(child as Image)
				{
					(child as Image).texture.dispose();
				}
				child.removeFromParent(true);
			}
			super.dealloc();
		}
	}
}