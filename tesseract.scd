(
var window, canvas;
var windowPosition = [1000,400], windowSize = [600,900], canvasPosition = [0.1,0.05], canvasSize = [0.8,0.6], scale = 125,
centerPoint, pointSize = 20, ang = 0!6, frameRate = 12, pointColor, planes = ["XY","XZ","XW","YZ","YW","ZW"], delta = 0.0!6,
knobSize = 50, knobPosition = [[0.25,0.5,0.75,0.25,0.5,0.75],[0.7,0.7,0.7,0.8,0.8,0.8]], maxDelta = 0.025*pi, viewDistance = 2;
var tesseract, project, rotate, drawLine, perspective;
//// =================== INIT PARAMETERS ================== ////
tesseract = [
  [-1, -1, -1, 1],
  [1, -1, -1, 1],
  [1, 1, -1, 1],
  [-1, 1, -1, 1],
  [-1, -1, 1, 1],
  [1, -1, 1, 1],
  [1, 1, 1, 1],
  [-1, 1, 1, 1],
  [-1, -1, -1, -1],
  [1, -1, -1, -1],
  [1, 1, -1, -1],
  [-1, 1, -1, -1],
  [-1, -1, 1, -1],
  [1, -1, 1, -1],
  [1, 1, 1, -1],
  [-1, 1, 1, -1]
];
centerPoint = (windowSize[0]*canvasSize[0]/2)@(windowSize[0]*canvasSize[0]/2);
pointColor = {Color.rand}!tesseract.size;
//// ==================== FUNCTIONS ==================== ////
project = {|point|
	var projectedPoint = [], projectionMatrix, scale;
	case
	{point.size == 4}{
		projectionMatrix = [
			[1,0,0,0],
			[0,1,0,0],
			[0,0,1,0],
		];
	}
	{point.size == 3}{
		projectionMatrix = [
			[1,0,0],
			[0,1,0],
		];
	};
	projectionMatrix.do{|line|
		projectedPoint = projectedPoint.add((line*point).sum);
	};
	projectedPoint
};
rotate = {|point, plane, angle|
	var rotatedPoint = [], rotationMatrix;
	case
	{plane == "ZW"}{
		rotationMatrix = [
			[cos(angle), -1*sin(angle),0,0],
			[sin(angle), cos(angle),0,0],
			[0,0,1,0],
			[0,0,0,1],
		];
	}
	{plane == "YW"}{
		rotationMatrix = [
			[cos(angle),0, -1*sin(angle),0],
			[0,1,0,0],
			[sin(angle), 0,cos(angle),0],
			[0,0,0,1],
		];
	}
	{plane == "YZ"}{
		rotationMatrix = [
			[cos(angle), 0,0,-1*sin(angle)],
			[0,1,0,0],
			[0,0,1,0],
			[sin(angle),0, 0, cos(angle)],
		];
	}
	{plane == "XZ"}{
		rotationMatrix = [
			[1,0,0,0],
			[0,cos(angle),0,-1*sin(angle)],
			[0, 0,1,0],
			[0,sin(angle),0, cos(angle)],
		];
	}
	{plane == "XW"}{
		rotationMatrix = [
			[1,0,0,0],
			[0,cos(angle), -1*sin(angle),0],
			[0,sin(angle), cos(angle),0],
			[0,0,0,1],
		];
	}
	{plane == "XY"}{
		rotationMatrix = [
			[1,0,0,0],
			[0,1,0,0],
			[0,0,cos(angle), -1*sin(angle)],
			[0,0,sin(angle), cos(angle)],
		];
	};
	rotationMatrix.do{|line|
		rotatedPoint = rotatedPoint.add((line*point).sum);
	};
	rotatedPoint
};
drawLine = {|offset, i, j, points|
	var p1, p2;
	p1 = points[offset+i];
	p2 = points[offset+j];
	Pen.line(p1[0]@p1[1],p2[0]@p2[1]);
};
perspective = {|point, distance = 0|
	var perspVector;
	case
	{point.size == 4}{
		perspVector = [point[0]/(distance-point[3]),point[1]/(distance-point[3]),point[2]/(distance-point[3]),1];
	}
	{point.size == 3}{
		perspVector = [point[0]/(distance-point[2]),point[1]/(distance-point[2]),1];
	};
	perspVector
};
//// =================================================== ////
Window.closeAll;
window = Window("TESSERACT",
	Rect(windowPosition[0],
		windowPosition[1],
		windowSize[0],
		windowSize[1])
);
window.background = Color.new(0.2,0.2,0.2);
canvas = UserView(window,
	Rect(canvasPosition[0]*window.bounds.width,
		canvasPosition[1]*window.bounds.height,
		canvasSize[0]*window.bounds.width,
		canvasSize[1]*window.bounds.height));
canvas.background = Color.grey;
canvas.drawFunc = {
	var currentPoints = [];
	Pen.strokeColor_(Color.black);
	tesseract.do{|point, idx|
		var tempPoint = [];
		tempPoint = point;
		Pen.fillColor_(pointColor[idx]);
		planes.do{|plane, idx|
			tempPoint = rotate.value(tempPoint,planes[idx],ang[idx]);
		};
		tempPoint = project.value(tempPoint);
		tempPoint = perspective.value(tempPoint,viewDistance);
		// (project.value(tempPoint) - point).postln;
		tempPoint = project.value(scale*tempPoint);
		currentPoints = currentPoints.add([tempPoint[0] + centerPoint.x + (pointSize/2),tempPoint[1] + centerPoint.y + (pointSize/2)]);
		Pen.fillOval(Rect(
			tempPoint[0] + centerPoint.x,
			tempPoint[1]+ centerPoint.y,
			pointSize,pointSize));
	};
	4.do{|i|
		[0,8].do{|j|
			drawLine.value(j, i, (i+1) % 4, currentPoints );
			drawLine.value(j, i + 4, ( (i+1) % 4 ) + 4, currentPoints);
			drawLine.value(j, i, i + 4, currentPoints);
		};
	};
	8.do{|i|
		drawLine.value(0, i, i + 8, currentPoints);
	};
	Pen.stroke;
	ang.size.do{|idx|
		ang[idx] = ang[idx] + delta[idx];
	};
};
//// ==================== KNOBS ==================== ////
6.do{|idx|
	StaticText(window,
		Rect(knobPosition[0][idx]*window.bounds.width - 45,
			knobPosition[1][idx]*window.bounds.height,
			knobSize,knobSize))
	.stringColor_(Color.white)
	.string_(planes[idx]);
	Knob(window,
		Rect(knobPosition[0][idx]*window.bounds.width,
			knobPosition[1][idx]*window.bounds.height,
			knobSize,knobSize))
	.color_([Color.white,Color.white,Color.grey,Color.grey])
	.value_(0)
	.action_({|obj|
		delta[idx] = obj.value.linlin(0,1,0,maxDelta);
	});
};
StaticText(window,
		Rect(0.5*window.bounds.width - 115,
			0.9*window.bounds.height,
			3*knobSize,knobSize))
	.stringColor_(Color.white)
.string_("DISTANCE");
Knob(window,
		Rect(0.5*window.bounds.width,
			0.9*window.bounds.height,
			knobSize,knobSize))
	.color_([Color.white,Color.white,Color.grey,Color.grey])
	.value_(0)
	.action_({|obj|
		viewDistance = obj.value.linlin(0,1,2,5);
});
Routine(
	{while({window.isClosed.not}, {
			canvas.refresh;
			(1/frameRate).wait
	})}
).play(AppClock);
window.front;
)

