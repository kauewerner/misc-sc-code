(
~nEpochs = inf;
~waitingTime = 0.15;
~agentValues = (0!20) ++ [1] ++ (0!20);
// ~agentValues = ~agentValues.scramble;
~cellSymbol = ["[]","  "];
~neighborInteraction = [[1,1,1],[1,1,0],[1,0,1],[1,0,0],[0,1,1],[0,1,0],[0,0,1],[0,0,0]];
// ~rules = [0,1,1,0,1,1,1,0]; // rule 110
~rules = [0,0,0,1,1,1,1,0]; // rule 30
// ~rules = [1,0,0,0,1,0,0,1];
~getNextAgent = {
	arg in, rules = ~rules;
	var out;
	~neighborInteraction.size.do{
		arg i;
		if(~neighborInteraction[i] == in,
			{
			out = rules[i];
			}
		);
	};
	out;
};
{
var tempAgent, printCells;
printCells = "";
~agentValues.do{
			arg i;
		if( i == 1 , {printCells = printCells ++ ~cellSymbol[1]}, {printCells = printCells ++ ~cellSymbol[0]} );
		};
		printCells.postln;
~nEpochs.do{
		tempAgent = 0!~agentValues.size;
		~agentValues.size.do{
			arg i;
			var temp;
			if(i == 0,
				{
				temp = [~agentValues[~agentValues.size - 1],~agentValues[i],~agentValues[i+1]];
				},
				{
				if(i == (~agentValues.size - 1),
					{
							temp = [~agentValues[i-1],~agentValues[i],~agentValues[0]];
					},
					{
							temp = [~agentValues[i-1],~agentValues[i],~agentValues[i+1]];
					});
			});
			tempAgent[i] = ~getNextAgent.value(temp);
		};
		~agentValues = tempAgent;
		printCells = "";
		~agentValues.do{
			arg i;
			if( i == 1 , {printCells = printCells ++ ~cellSymbol[1]}, {printCells = printCells ++ ~cellSymbol[0]} );
		};
		printCells.postln;
	~waitingTime.wait;
	}
}.fork;
)


