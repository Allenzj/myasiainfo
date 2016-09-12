//影响分析 血缘分析
function getData(anaType, rootName, level) {
	if (!level)
		level = 10;
	var workFlow = anaType == 'after' ? "TARGET" : "SOURCE";
	var _opWorkFlow = anaType == 'after' ? "SOURCE" : "TARGET";
	var finalSql="select SOURCE,SOURCETYPE,TARGET,TARGETTYPE from TRANSDATAMAP_DESIGN ";
	var sql = finalSql+" where "+ _opWorkFlow + "='" + rootName+"'";
	var rootStore = ai.getStore(sql);
	var objLinks = [], objArray = [];
	var allObj = {}, allLevel = {};

	var checkKeyUnqi = function(key) {
		var _flag1 = true;
		for (var k = 0; k < objArray.length; k++) {
			if (objArray[k].key == key) {
				_flag1 = false;
			}
		}
		return _flag1;
	};

	var toUpperProp = function(obje) {
		/*
		var _prop = _.keys(obje);
		for (var m = 0; m < _prop.length; m++) {
			if(obje[_prop[m]]){
				obje[_prop[m]] = obje[_prop[m]].toUpperCase();
			} 
		}*/
		return obje;
	};
	var getDataName=function(xmlid){
		var _sql = "select DISTINCT DATANAME,DBNAME from tablefile where XMLID='"+xmlid+"'";
		var tableStore=ai.getStore(_sql);
		var item = tableStore.count>0?tableStore.root[0]['DATANAME']:xmlid;
		return item;
	};
	var rootRealName = getDataName(rootName);
	var rootCategory = rootStore.count>0?toUpperProp(rootStore.root[0])[_opWorkFlow+"TYPE"]:'PROC';

	var _level = 0;
	objArray.push({
		"key" : rootName,
		"text" : "目标：" + rootRealName,
		"level" : _level,
		"nodeType" : "Source",
		"category" : rootCategory
	});
	
	var getChildrenNode = function(arrStr) {
		level++;
		var childSql = finalSql+"  WHERE " + _opWorkFlow + " in ("+arrStr+")";
		var _targetStore = ai.getStore(childSql);
	//	var _sourceStore = ai.getStore(finalSql+"  WHERE " + workFlow + "in ("+arrStr+")");
		var _cNStr = "";
		for (var j = 0; j < _targetStore.count; j++) {
			var _r1 = toUpperProp(_targetStore.root[j]);
			var _preName = _r1[workFlow+"TYPE"] == "DATA" ? "表：" : "程序：";
			if (checkKeyUnqi(_r1[workFlow])) {
				objArray.push({
					"key" : _r1[workFlow],
					"text" :_r1[workFlow+"TYPE"] == "DATA"? _preName +getDataName(_r1[workFlow]):_preName+_r1[workFlow],
					"level" : level,
					"nodeType" : _r1[workFlow+"TYPE"],
					"category" : _r1[workFlow+"TYPE"]
				});
				objLinks.push({
					from : anaType == 'after' ? _r1[_opWorkFlow]: _r1[workFlow],
					to : anaType == 'after' ? _r1[workFlow] : _r1[_opWorkFlow]
				});
				_cNStr += (", '" + _r1[workFlow] + "'");
			}
		}
		if (_cNStr.length > 0) {
			getChildrenNode(_cNStr.slice(1));
		}
	};
	var childrenProcStr = "";
	level++;
	for (var i = 0; i < rootStore.count; i++) {
		var _r = toUpperProp(rootStore.root[i]);
		var preName = _r[workFlow+"TYPE"] == "DATA" ? "表：" : "程序：";
		if (checkKeyUnqi(_r[workFlow])) {
			objArray.push({
				"key" : _r[workFlow],
				"text" :_r[workFlow+"TYPE"] == "DATA"? preName +getDataName(_r[workFlow]):preName+_r[workFlow],
				"level" : _level,
				"nodeType" : _r[workFlow+"TYPE"],
				"category" : _r[workFlow+"TYPE"]
			});
			objLinks.push({
				from : anaType == 'after' ? rootName : _r[workFlow],
				to : anaType == 'after' ? _r[workFlow] : rootName
			});
			childrenProcStr += (i == 0 ? "" : ",");
			childrenProcStr += (" '" + _r[workFlow] + "'");
		}
	}
	if (childrenProcStr.length > 0) {
		getChildrenNode(childrenProcStr);
	}
	return {
		objArray : objArray,
		linkArray : objLinks
	};
};
function nodeDoubleClick(e, node) {
	// alert(node.data.nodeType);
	return;
};
function init(anaType, rootName) {

	if (window.goSamples)
		goSamples(); // init for these samples -- you don't need to call this
	var $ = go.GraphObject.make; // for conciseness in defining templates

	var yellowgrad = $(go.Brush, go.Brush.Linear, {
		0 : "rgb(254, 201, 0)",
		1 : "rgb(254, 162, 0)"
	});
	var greengrad = $(go.Brush, go.Brush.Linear, {
		0 : "#98FB98",
		1 : "#9ACD32"
	});
	var bluegrad = $(go.Brush, go.Brush.Linear, {
		0 : "#B0E0E6",
		1 : "#87CEEB"
	});
	var redgrad = $(go.Brush, go.Brush.Linear, {
		0 : "#C45245",
		1 : "#7D180C"
	});
	var whitegrad = $(go.Brush, go.Brush.Linear, {
		0 : "#F0F8FF",
		1 : "#E6E6FA"
	});

	var bigfont = "bold 13pt Helvetica, Arial, sans-serif";
	var smallfont = "bold 11pt Helvetica, Arial, sans-serif";

	// Common text styling
	function textStyle() {
		return {
			margin : 6,
			wrap : go.TextBlock.WrapFit,
			textAlign : "center",
			editable : true,
			font : bigfont
		}
	}

	myDiagram = $(go.Diagram, "myDiagram");

	var defaultAdornment = $(go.Adornment, go.Panel.Spot, $(go.Panel,
			go.Panel.Auto, $(go.Shape, {
				fill : null,
				stroke : "blue",
				strokeWidth : 2
			}), $(go.Placeholder)),
	// the button to create a "next" node, at the top-right corner
	$("Button", {
		alignment : go.Spot.TopRight,
		click : addNodeAndLink
	}, // this function is defined below
	$(go.Shape, "PlusLine", {
		desiredSize : new go.Size(6, 6)
	})));

	// define the Node template
	// 可以通过 problem控制节点的连线和边框的颜色
	// data.status = 10.1;//控制节点内部图标的颜色
	// data.operation //控制节点内图标的形状
	myDiagram.nodeTemplate = $(go.Node, go.Panel.Auto, {
		selectionAdornmentTemplate : defaultAdornment,
		mouseOver : function(e, obj) {// 鼠标进入响应的事件方法
			nodeDoubleClick(e, obj) // 事件调用方法
		}
	}, {
		click : nodeDoubleClick
	}, // 鼠标单击事件函数

	new go.Binding("location", "loc", go.Point.parse)
			.makeTwoWay(go.Point.stringify),
	// define the node's outer shape, which will surround the TextBlock
	$(go.Shape, "Rectangle", {
		fill : yellowgrad,
		stroke : "black",
		portId : "",
		fromLinkable : true,
		toLinkable : true,
		cursor : "pointer"
	}), $(go.TextBlock, {
		margin : 6,
		font : bigfont,
		editable : true,
		text : 'Page'
	}, new go.Binding("text", "text").makeTwoWay()));

	myDiagram.nodeTemplateMap.add("Source", $(go.Node, go.Panel.Auto, $(
			go.Shape, "RoundedRectangle", {
				fill : bluegrad,
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		click : nodeDoubleClick
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source'
	}, new go.Binding("text", "text").makeTwoWay())));
	myDiagram.nodeTemplateMap.add("PROC", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {
				fill : yellowgrad,
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		click : nodeDoubleClick
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source'
	}, new go.Binding("text", "text").makeTwoWay())));
	myDiagram.nodeTemplateMap.add("DATA", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {
				fill : bluegrad,
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		click : nodeDoubleClick
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source'
	}, new go.Binding("text", "text").makeTwoWay())));
	myDiagram.nodeTemplateMap.add("DesiredEvent", $(go.Node, go.Panel.Auto, $(
			go.Shape, "RoundedRectangle", {
				fill : greengrad,
				portId : "",
				toLinkable : true
			}), $(go.TextBlock, textStyle(), {
		text : 'Success!'
	}, new go.Binding("text", "text").makeTwoWay())));

	// Undesired events have a special adornment that allows adding additional
	// "reasons"
	var UndesiredEventAdornment = $(go.Adornment, go.Panel.Spot, $(go.Panel,
			go.Panel.Auto, $(go.Shape, {
				fill : null,
				stroke : "blue",
				strokeWidth : 2
			}), $(go.Placeholder)),
	// the button to create a "next" node, at the top-right corner
	$("Button", {
		alignment : go.Spot.BottomRight,
		click : addReason
	}, // this function is defined below
	$(go.Shape, "TriangleDown", {
		desiredSize : new go.Size(10, 10)
	})));

	var reasonTemplate = $(go.Panel, go.Panel.Horizontal, $(go.TextBlock, {
		margin : new go.Margin(4, 0, 0, 0),
		maxSize : new go.Size(200, NaN),
		wrap : go.TextBlock.WrapFit,
		stroke : 'whitesmoke',
		text : 'Reason',
		editable : true,
		font : smallfont
	}, new go.Binding('text', 'text').makeTwoWay()));

	myDiagram.nodeTemplateMap.add("UndesiredEvent", $(go.Node, go.Panel.Auto, {
		selectionAdornmentTemplate : UndesiredEventAdornment
	}, $(go.Shape, "RoundedRectangle", {
		fill : redgrad,
		portId : "",
		toLinkable : true
	}), $(go.Panel, go.Panel.Vertical, {
		defaultAlignment : go.Spot.TopLeft
	},

	$(go.TextBlock, textStyle(), {
		stroke : 'whitesmoke',
		text : 'Drop',
		minSize : new go.Size(80, NaN)
	}, new go.Binding("text", "text").makeTwoWay()),

	$(go.Panel, go.Panel.Vertical, {
		name : 'ReasonList',
		defaultAlignment : go.Spot.TopLeft,
		itemTemplate : reasonTemplate
	}, new go.Binding("itemArray", "reasonsList").makeTwoWay()))));

	myDiagram.nodeTemplateMap.add("Comment", $(go.Node, go.Panel.Auto,
			new go.Binding("location", "loc", go.Point.parse)
					.makeTwoWay(go.Point.stringify), $(go.Shape, "Rectangle", {
				portId : "",
				fill : whitegrad,
				fromLinkable : true
			}), $(go.TextBlock, {
				margin : 9,
				maxSize : new go.Size(200, NaN),
				wrap : go.TextBlock.WrapFit,
				editable : true,
				text : 'A comment',
				font : smallfont
			}, new go.Binding("text", "text").makeTwoWay())
	// no ports, because no links are allowed to connect with a comment
	));

	// clicking the button on an UndesiredEvent node inserts a new text object
	// into the panel
	function addReason(e, obj) {
		var adorn = obj.part;
		if (adorn === null)
			return;
		e.handled = true;
		// var list = adorn.adornedPart.findObject('ReasonList');
		var arr = adorn.adornedPart.data.reasonsList;
		// and add it to the Array of port data
		myDiagram.startTransaction('add reason');
		myDiagram.model.addArrayItem(arr, {});
		myDiagram.commitTransaction('add reason');
	}

	// clicking the button of a default node inserts a new node to the right of
	// the selected node,
	// and adds a link to that new node
	function addNodeAndLink(e, obj) {
		var adorn = obj.part;
		if (adorn === null)
			return;
		e.handled = true;
		var diagram = adorn.diagram;
		diagram.startTransaction("Add State");
		// get the node data for which the user clicked the button
		var fromNode = adorn.adornedPart;
		var fromData = fromNode.data;
		// create a new "State" data object, positioned off to the right of the
		// adorned Node
		var toData = {
			text : "new"
		};
		var p = fromNode.location;
		toData.loc = p.x + 200 + " " + p.y; // the "loc" property is a string,
		// not a Point object
		// add the new node data to the model
		var model = diagram.model;
		model.addNodeData(toData);
		// create a link data from the old node data to the new node data
		var linkdata = {};
		linkdata[model.linkFromKeyProperty] = model.getKeyForNodeData(fromData);
		linkdata[model.linkToKeyProperty] = model.getKeyForNodeData(toData);
		// and add the link data to the model
		model.addLinkData(linkdata);
		// select the new Node
		var newnode = diagram.findNodeForData(toData);
		diagram.select(newnode);
		diagram.commitTransaction("Add State");
	}

	// replace the default Link template in the linkTemplateMap
	myDiagram.linkTemplate = $(go.Link, // the whole link panel
	{
		curve : go.Link.Bezier,
		toShortLength : 15
	}, new go.Binding("curviness", "curviness"), $(go.Shape, // the link
	// shape
	{
		isPanelMain : true,
		stroke : "#2F4F4F",
		strokeWidth : 2.5
	}), $(go.Shape, // the arrowhead
	{
		toArrow : "kite",
		fill : '#2F4F4F',
		stroke : null,
		scale : 2
	}));

	myDiagram.linkTemplateMap.add("Comment", $(go.Link, {
		selectable : false
	}, $(go.Shape, {
		strokeWidth : 2,
		stroke : "darkgreen"
	})));

	// have mouse wheel events zoom in and out instead of scroll up and down
	myDiagram.toolManager.mouseWheelBehavior = go.ToolManager.WheelZoom;
	myDiagram.allowDrop = true;

	// read in the JSON-format data from the "mySavedModel" element
	myDiagram.initialAutoScale = go.Diagram.Uniform;
	myDiagram.toolManager.linkingTool.direction = go.LinkingTool.ForwardsOnly;
	myDiagram.initialContentAlignment = go.Spot.Center;
	myDiagram.layout = $(go.LayeredDigraphLayout, {
		isOngoing : false,
		layerSpacing : 50
	});
	var dataInfo = getData(anaType, rootName);
	myDiagram.model = new go.GraphLinksModel(dataInfo.objArray,
			dataInfo.linkArray);
	// load();
}