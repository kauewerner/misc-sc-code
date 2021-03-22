(
s.waitForBoot{
// GUI objects
var window, canvas, graph, multiSlider, minBox, minKnob, maxBox, maxKnob, ampKnob, busValues;
// GUI parameters
var height = 1000, width = 1200, numberOfRegions, sizePoint = 3, canvasSize = 0.4@0.8, canvasPosition = 0.4@0.025, graphSize = 0.275@0.275, graphPosition = 0.05@0.025, colorArray, numberOfSteps, frameRate = 120, frameRateRange = [4,240];
// Mathematical parameters and variables
var r = 2.85, yn, xn = 0.01, t = 0, dt = 0.05, rRange = [2.0,4.0], mapType = "logistic", rAmplitude = 2.0, rFrequency = 1.0, rType = "ramp", nIterations = 1, rArray, ri, mapRange = (
		'logistic': [2.0,3.99],
		'tent': [1.0,1.99],
		'sine': [0.25,0.99],
		'parabola': [1.0,1.99]
	);
// Functions
var regression, compute_value, set_r, set_r_range, draw_regions, send_to_bus;
//// BUSSES =============================================================== ////
~labels = ['bus 1','bus 2','bus 3','bus 4',
	       'bus 5','bus 6','bus 7','bus 8'];
~busses = ();
~labels.do{|label|
	~busses[label.asSymbol] = Bus.control(s,1);
};
//// ====================================================================== ////
Window.closeAll;
numberOfSteps = (canvasSize.x*width).asInteger;
rArray = rRange[0]!numberOfSteps;
numberOfRegions = ~labels.size;
busValues = 0!numberOfRegions;
colorArray = {Color.rand}!numberOfRegions;
numberOfRegions.do{| idx |
		var col = idx/(1.5*numberOfRegions);
		colorArray[idx] = Color.new(0.8,0.8,0.8);
	};

//// ====================================================================== ////
window = Window("THE BIFURCATOR",Rect(1350,100,width,height));
canvas = UserView(window, Rect(canvasPosition.x*width,canvasPosition.y*height,width*canvasSize.x,height*canvasSize.y));
graph = UserView(window, Rect(graphPosition.x*width,graphPosition.y*height,width*graphSize.x,width*graphSize.y));
window.background = Color.new(0.2,0.2,0.2);
canvas.background = Color.new(0.2,0.2,0.2);
graph.background = Color.new(0.3,0.3,0.3);
//// Set initial R
ri = 0;
rArray.size.do{|idx|
	rArray[idx] = (ri.linlin(0,(rArray.size-1),rRange[0],rRange[1]));
	ri = ri + 1;
};
//// ====================================================================== ////
regression = {|n, function, input, factor, type|
		n.do{
			input = function.value(input, factor, type);
		};
		input
};
//// ====================================================================== ////
compute_value = {|input, factor, type|
		var return = 0;
		case
		{type == "logistic"}{
			return = factor*input*(1.0 - input);
		}
		{type ==  "tent"}{
			if(input < 0.5,
			{return = factor*input},
			{return = factor*(1 - input)}
			);
		}
		{type == "sine"}{
			return = factor*sin(3.1415*input);
		}
		{type ==  "parabola"}{
			return = factor*(input-0.5)**2;
		};
		return
};
//// ====================================================================== ////
set_r = {|type|
		case
		{type == "constant"}{
			rArray.size.do{|idx|
				rArray[idx] = rAmplitude;
			};
			multiSlider.value_(rArray.linlin(rRange[0],rRange[1],0,1));
		}
		{type ==  "ramp"}{
			var j = 0;
			rArray.size.do{|idx|
				rArray[idx] = (j.linlin(0,(rArray.size-1)/rFrequency,rAmplitude,rRange[1]));
				j = j + 1;
				if(j >= (((rArray.size-1)/rFrequency).asInteger +1)){j = 0};
			};
			multiSlider.value_(rArray.linlin(rRange[0],rRange[1],0,1));
		}
		{type ==  "sine"}{
			var j = 0;
			rArray.size.do{|idx|
				rArray[idx] = (0.5*(1 + sin((2*3.1415*2*rFrequency/(rArray.size-1))*j - 3.1415/2)) - 0.5).linlin(-0.5,0.5,rAmplitude,rRange[1]);
				j = j + 1;
				if(j > (2*3.1415*(rArray.size-1)/rFrequency + 1) ){j = 0};
			};
			multiSlider.value_(rArray.linlin(rRange[0],rRange[1],0,1));
		};
	};
//// ====================================================================== ////
set_r_range = {|min,max|
		var currentRange = [rRange[0],rRange[1]];
		rArray.size.do{|idx|
			rArray[idx] = rArray[idx].linlin(currentRange[0],currentRange[1],min,max);
		};
		rRange[0] = min;
		rRange[1] = max;
	};
//// ====================================================================== ////
draw_regions = {|n,w,h|
	n.do{|idx|
			Pen.fillColor = colorArray[idx];
			Pen.strokeColor = Color.black;
			Pen.fillRect(Rect(0,idx*h/n,w,h/n));
			Pen.strokeRect(Rect(0,idx*h/n,w,h/n));
	};
};
//// ====================================================================== ////
send_to_bus = {|n,pos,h|
	n.do{|idx|
		if( ( pos.y < ((idx+1)*h/n) ) && ( pos.y > (idx*h/n) ) , {
			~busses[~labels[idx]].set(pos.y.linlin(idx*h/n,(idx+1)*h/n,0,1));
			busValues[idx].value = ~busses[~labels[idx]].getSynchronous;
		});
	};
};
//// ====================================================================== ////
canvas.drawFunc = {
	var pos;
	r = rArray[t];
	yn = regression.value(nIterations,compute_value,xn,r,mapType);
	pos = Point(t, yn*height*canvasSize.y);
	if(t ==0, {
			draw_regions.value(numberOfRegions,width*canvasSize.x,height*canvasSize.y);
			set_r_range.value(rRange[0],rRange[1]);
			/*set_r.value(rType);*/
		});
		Pen.fillColor = Color.new(0.2,0.2,0.2);
	Pen.fillOval(Rect.aboutPoint(pos, sizePoint, sizePoint));
	send_to_bus.value(numberOfRegions,pos,canvasSize.y*height);
	t = (t + 1) % numberOfSteps;
	xn = yn;
	if(t == 0,{canvas.clearOnRefresh = true; xn = 0.75},{canvas.clearOnRefresh = false});
};
//// ====================================================================== ////
graph.drawFunc = {
		var pos, xg, factor = (graphSize.x*width).asInteger, prev;
		var initialPoint = (xn*width*graphSize.x)@(width*graphSize.y);
		xg = (0..( factor - 1) )/factor;
		Pen.strokeColor = Color.black;
		Pen.strokeRect(Rect(0,0,graphSize.x*width,graphSize.y*width));
		Pen.fillColor = Color.black;
		Pen.strokeColor = Color.new(0.6,0.6,0.6);
		Pen.width_(4);
		Pen.moveTo(initialPoint);
		Pen.lineTo(Point((xn*width*graphSize.x),
			((regression.value(nIterations,compute_value,xn,rArray[t],mapType)).linlin(0,1,width*graphSize.y,0))));
Pen.lineTo(
			0@(regression.value(nIterations,compute_value,xn,rArray[t],mapType).linlin(0,1,width*graphSize.y,0)));
		Pen.stroke;

		Pen.strokeColor = Color.grey;
		Pen.width_(1);
		Pen.line((width*graphSize.x/2)@0,(width*graphSize.x/2)@(width*graphSize.y));
		Pen.line(0@(width*graphSize.y),(width*graphSize.x)@0);
		Pen.stroke;

		Pen.strokeColor = Color.white;
		Pen.width_(6);
		prev = Point(xg[0]*width*graphSize.x,regression.value(nIterations,compute_value,xg[0],rArray[t],mapType).linlin(0,1,width*(graphSize.y),0));
		(1..(xg.size-1)).do{|idx|
			pos = Point(xg[idx]*width*graphSize.x,
				regression.value(nIterations,compute_value,xg[idx],rArray[t],mapType).linlin(0,1,width*(graphSize.y),0));
			// Pen.fillOval(Rect.aboutPoint(pos, sizePoint, sizePoint));
			Pen.line(prev,pos);
			prev = pos.x@pos.y;
		};
		Pen.stroke;
		// if(t == 0,{graph.clearOnRefresh = true},{graph.clearOnRefresh = false});
};
//// ====================================================================== ////
	numberOfRegions.do{|idx|
		StaticText(window,
			Rect(width*(canvasSize.x + canvasPosition.x + 0.025),
				height*canvasPosition.y + (idx*canvasSize.y*height/numberOfRegions),
				width*0.1,canvasSize.y*height/numberOfRegions))
		.stringColor_(colorArray[idx])
		.string_(~labels[idx].asString);
		busValues[idx] = NumberBox(window,
			Rect(width*(canvasSize.x + canvasPosition.x + 0.1),
			height*(0.025+ canvasPosition.y) + (idx*(canvasSize.y)*height/numberOfRegions),
				width*0.065,canvasSize.y*0.5*height/numberOfRegions))
		.maxDecimals_(3)
		.background_(colorArray[idx])
		.value_(0);
	};
//// ====================================================================== ////
	multiSlider = MultiSliderView(window,Rect(canvasPosition.x*width,
		(canvasSize.y + canvasPosition.y)*height,
		width*canvasSize.x,0.1*height))
	.size_(numberOfSteps)
	.drawLines_(true)
	.background_(Color.new(0.3,0.3,0.3))
	.colors_(Color.white)
	.drawRects_(false)
	.elasticMode_(true)
	.value_(rArray.linlin(rRange[0],rRange[1],0,1))
	.action_({|obj|
		var temp = obj.value;
		temp.size.do{|idx|
			rArray[idx] = temp[idx].linlin(0,1,rRange[0],rRange[1]);
		};
	});
//// ====================================================================== ////
	StaticText(window,Rect(0.05*width,0.4*height,0.2*width,0.05*height))
		.stringColor_(Color.white)
	.string_("function type: ");
	PopUpMenu(window,Rect(0.225*width,0.4*height,0.1*width,0.05*height))
	.items_(["logistic","tent","sine","parabola"])
	.action_({|obj|
		var min, max;
		mapType = obj.item.asString;
		min = mapRange[mapType.asSymbol][0];
		max = mapRange[mapType.asSymbol][1];
		minKnob.value = 0;
		minBox.value = min;
		set_r_range.value(min, max);
		rAmplitude = ampKnob.value.linlin(0,1,min,max);
		set_r.value(rType);
	});
//// ====================================================================== ////
	StaticText(window,Rect(0.05*width,0.475*height,0.2*width,0.05*height))
		.stringColor_(Color.white)
	.string_("# of iterations: ");
	NumberBox(window,Rect(0.225*width,0.475*height,0.035*width,0.05*height))
	.value_(nIterations)
	.step_(1)
	.action_({|obj|
		if(obj.value < 1){obj.value_(1)};
		nIterations = obj.value.asInteger;
	});
//// ====================================================================== ////
	StaticText(window,Rect(0.05*width,0.5375*height,0.2*width,0.05*height))

		.stringColor_(Color.white)
	.string_("frame rate: ");
	Knob(window,Rect(0.225*width,0.5375*height,60, 60))
	.value_(frameRate.linlin(frameRateRange[0],frameRateRange[1],0,1))
	.color_([Color.white,Color.white,Color.grey,Color.grey])
	.action_({|obj|
		frameRate = obj.value.linlin(0,1,frameRateRange[0],frameRateRange[1]).asInteger;
	});
//// ====================================================================== ////
	StaticText(window,Rect(0.05*width,0.625*height,0.2*width,0.05*height))

		.stringColor_(Color.white)
	.string_("r function: ");
	PopUpMenu(window,Rect(0.225*width,0.625*height,0.1*width,0.05*height))
	.items_(["constant","ramp","sine"])
	.value_(1)
	.action_({|obj|
		rType = obj.item.asString;
		// rAmplitude = obj.value.linlin(0,1,rRange[0],rRange[1]);
		set_r.value(rType);
	});
//// ====================================================================== ////
	StaticText(window,Rect(0.05*width,0.7*height,0.2*width,0.05*height))

		.stringColor_(Color.white)
	.string_("r compression: ");
	ampKnob = Knob(window,Rect(0.225*width,0.7*height,60, 60))
	.value_(0)
	.color_([Color.white,Color.white,Color.grey,Color.grey])
	.action_({|obj|
		rAmplitude = obj.value.linlin(0,1,rRange[0],rRange[1]);
		set_r.value(rType);
	});
//// ====================================================================== ////
	StaticText(window,Rect(0.05*width,0.775*height,0.2*width,0.05*height))

		.stringColor_(Color.white)
	.string_("r frequency: ");
	Knob(window,Rect(0.225*width,0.775*height,60, 60))
	.value_(0)
	.color_([Color.white,Color.white,Color.grey,Color.grey])
	.action_({|obj|
		rFrequency = obj.value.linlin(0,1,1,5);
		set_r.value(rType);
	});
//// ====================================================================== ////
	StaticText(window,Rect(0.05*width,0.85*height,0.2*width,0.05*height))
		.stringColor_(Color.white)
	.string_("r min: ");
	minKnob = Knob(window,Rect(0.225*width,0.85*height,60, 60))
	.value_(0)
	.color_([Color.white,Color.white,Color.grey,Color.grey])
	.action_({|obj|
		var min, max;
		min = mapRange[mapType.asSymbol][0];
		max = mapRange[mapType.asSymbol][1];
		rRange[0] = obj.value.linlin(0,1,min,max);
		minBox.value_(obj.value.linlin(0,1,min,max));
		rAmplitude = obj.value.linlin(0,1,rRange[0],rRange[1]);
		ampKnob.valueAction = obj.value.linlin(rRange[0],rRange[1],0,1);
	});
	minBox = NumberBox(window,Rect(0.2875*width,0.855*height,0.035*width,0.05*height))
	.value_(rRange[0])
	.action_({|obj|
		var min, max;
		min = mapRange[mapType.asSymbol][0];
		max = mapRange[mapType.asSymbol][1];
		if(obj.value > max) {rRange[0] = max; obj.value = max}{rRange[0] = obj.value};
		if(obj.value < min) {rRange[0] = min; obj.value = min}{rRange[0] = obj.value};
		minKnob.value_(obj.value.linlin(min,max,0,1));
		rAmplitude = ampKnob.value.linlin(0,1,rRange[0],rRange[1]);
		ampKnob.value = obj.value.linlin(rRange[0],rRange[1],0,1);
	});
//// ====================================================================== ////
StaticText(window,Rect(0.385*width,0.8425*height,0.035*width,0.05*height))
	.stringColor_(Color.white)
	.string_("r");
StaticText(window,Rect(0.6*width,0.9125*height,0.035*width,0.05*height))
	.stringColor_(Color.white)
	.string_("t");
Routine(
	{while({window.isClosed.not}, {
			canvas.refresh;
			graph.refresh;
			(1/frameRate).wait
	})}
).play(AppClock);
window.front;
window.alwaysOnTop_(true);
}
)

