(* ::Package:: *)

(*Package PrettyColorize: colorize graphics, figures, plottings*)
(*Author: Luyan Yu*)
(*Version: v0.0.1*)
(*Github: https://github.com/yuluyan/PrettyColorize*)

Package["PrettyColorize`"]

PackageImport["PrettyRandomColor`"]

PackageExport["Pretty"]
PackageExport["PrettyColorize"]


(*Generate color*)
(*TODO: generate new colors according to stored colors*)
generateColors[count_, luminosity_, basicColors_] :=
	Module[{},
		If[luminosity == 0,
		PrettyRandomColor[ColorCount -> count],
		PrettyRandomColor[ColorCount -> count, Luminosity -> luminosity]
	]
];


colorButtonShape[color_, scale_] :=
	Graphics[
		{color, EdgeForm[Darker @ color],
		Rectangle[0.5 (1 - scale * {1, 1}), 0.5 (1 + scale * {1, 1}), RoundingRadius -> 0.3]
	},
	PlotRange -> {{0, 1}, {0, 1}},
	ImageSize -> 30
];

colorChoiceButton[color_, callbackLeft_, callbackRight_] := DynamicModule[
	{buttonColor = color, buttonScale = 0.8, displayColor = color},
	EventHandler[
		Button[Dynamic[colorButtonShape[displayColor, buttonScale]], Appearance -> None],
			{
				{"MouseDown", 1} :> (displayColor = Darker @ buttonColor; buttonScale = 0.85),
				{"MouseUp", 1} :> (displayColor = buttonColor; buttonScale = 0.8),
				{"MouseClicked", 1} :> (callbackLeft[]),
				{"MouseDown", 2} :> (displayColor = Lighter @ buttonColor; buttonScale = 0.85),
				{"MouseUp", 2} :> (displayColor = buttonColor; buttonScale = 0.8),
				{"MouseClicked", 2} :> (callbackRight[])
			}
		]
];

placeholderButton = Button[
	Graphics[
		{White, EdgeForm[Darker @ White],
		Rectangle[0.5 (1 - 0.8 * {1, 1}),0.5 (1 + 0.8 * {1, 1}), RoundingRadius -> 0.3]
	},
	PlotRange -> {{0, 1}, {0, 1}},
	ImageSize -> 30
	],
Appearance -> None, Enabled -> False];

sortColor[colors_] :=
	SortBy[colors, ColorConvert[#1, "HSB"][[1]]&];

assignHSBA[color_] := Module[{h, s, b, a, l},
	l = List @@ ColorConvert[color, "HSB"];
	If[Length[l] == 3, {h, s, b} = l; a = 1.0;, {h, s, b, a} = l;];
	{h, s, b, a}
];

SetAttributes[createColorPalette, HoldFirst];
createColorPalette[items_] := DynamicModule[{
	colorList, storedColorList = <||>, selectedColor,
	colorButtons, storedColorButtons = {},
	colorColumn = 6, colorRow = 2, storedColorRow = 1,
	totalColor, totalStoredColor, storedColorId = 1,
	activeItem,
	h, s, b, a,
	luminosity = 0
},

	totalColor = colorColumn * colorRow;
	totalStoredColor = colorColumn * storedColorRow;

	colorList = sortColor @ generateColors[totalColor, luminosity, Keys[storedColorList]];
	selectedColor = colorList[[1]];

	activeItem = Keys[items][[1]];
	Table[items[[k]] = colorList[[k]], {k, 1, Min[Length[items], Length[colorList]]}];

	colorButtons=Table[
		colorChoiceButton[
			bcolor,
			(*Choice button left click*)
			With[{bcolor = bcolor},(
				selectedColor = bcolor;
				items[[activeItem]] = selectedColor;
				{h, s, b, a} = assignHSBA[selectedColor];
			)&],
			(*Choice button right click*)
			With[{bcolor = bcolor},
				(If[Length[storedColorButtons] < totalStoredColor && (!KeyExistsQ[storedColorList, bcolor]),
					AppendTo[storedColorButtons, colorChoiceButton[
						bcolor,
						(*History button left click*)
						With[{bcolori = bcolor},(
							selectedColor = bcolori;
							items[[activeItem]] = selectedColor;
							{h, s, b, a} = assignHSBA[selectedColor];
						)&],
						(*History button right click*)
						With[{bcolori = bcolor}, (
							storedColorButtons = Drop[storedColorButtons, {storedColorList[bcolori]}];
							storedColorList = If[# > storedColorList[bcolori], # - 1, #]& /@ storedColorList;
							storedColorList = KeyDrop[storedColorList, bcolori];
							storedColorId -= 1;
						)&]
					]];
				storedColorList[bcolor] = storedColorId;
				storedColorId += 1;
				])&
			]
		],
	{bcolor, colorList}];

	{h, s, b, a} = assignHSBA[selectedColor];

	Column@{
		(*Choice buttons*)
		Style["Colors:", Bold],
		Row[{
			RadioButtonBar[
				Dynamic[luminosity],
				{0 -> "Normal", "Light" -> "Light", "Bright" -> "Bright", "Dark" -> "Dark"}, 
				Appearance -> "Vertical" -> {2, 2}
			],
			Spacer[If[detectOS[] === "mac", 5, 20]],
			(*Generate button*)
			Button["Gen",
				colorList = sortColor @ generateColors[totalColor, luminosity,  Keys[storedColorList]];
				colorButtons = Table[
					colorChoiceButton[
						bcolor,
						(*Choice button left click*)
						With[{bcolor = bcolor},(
							selectedColor = bcolor;
							items[[activeItem]] = selectedColor;
							{h, s, b, a} = assignHSBA[selectedColor];
						)&],
						(*Choice button right click*)
						With[{bcolor = bcolor},
							(If[Length[storedColorButtons] < totalStoredColor && (!KeyExistsQ[storedColorList, bcolor]),
								AppendTo[storedColorButtons, colorChoiceButton[
									bcolor,
									(*History button left click*)
									With[{bcolori = bcolor},(
										selectedColor  bcolori;
										items[[activeItem]] = selectedColor;
										{h, s, b, a} = assignHSBA[selectedColor];
									)&],
									(*History button right click*)
									With[{bcolori = bcolor},
										(storedColorButtons = Drop[storedColorButtons, {storedColorList[bcolori]}];
										storedColorList = If[#>storedColorList[bcolori], # - 1, #]& /@ storedColorList;
										storedColorList = KeyDrop[storedColorList, bcolori];
										storedColorId -= 1;
									)&]
								]];
								storedColorList[bcolor] = storedColorId;
								storedColorId += 1;
							])&
						]
					],
				{bcolor,colorList}];,
				Appearance -> If[detectOS[] === "mac", Automatic, "Palette"],
				ImageSize -> If[detectOS[] === "mac", {45,40}, {30,30}],
				FrameMargins -> If[detectOS[] === "mac", -5, Automatic]
			]
		}],
		Dynamic[
			Multicolumn[colorButtons, colorColumn, Appearance -> "Horizontal", Spacings -> {0, 0}],
			TrackedSymbols :> {colorButtons}
		],
		(*Stored buttons*)
		Style["Storage:", Bold],
		Dynamic[Multicolumn[
				PadRight[storedColorButtons, totalStoredColor, placeholderButton],
				colorColumn,
				Appearance -> "Horizontal", Spacings -> {0, 0}
			],
			TrackedSymbols :> {storedColorButtons}
		],
		(*Color sliders*)
		Style["Palette:", Bold],
		Row[{
			Dynamic[colorChoiceButton[selectedColor,
				(*Color preview button left click*)
				(items[[activeItem]] = selectedColor;)&,
				(*Color preview button right click*)
				With[{bcolor = selectedColor},
					(If[Length[storedColorButtons] < totalStoredColor && (!KeyExistsQ[storedColorList, bcolor]),
						AppendTo[storedColorButtons, colorChoiceButton[
							bcolor,
							(*History button left click*)
							With[{bcolori = bcolor},(
								selectedColor = bcolori;
								items[[activeItem]] = selectedColor;
								{h, s, b, a} = assignHSBA[selectedColor];
							)&],
							(*History button right click*)
							With[{bcolori = bcolor}, (
								storedColorButtons = Drop[storedColorButtons, {storedColorList[bcolori]}];
								storedColorList = If[# > storedColorList[bcolori], # - 1, #]& /@ storedColorList;
								storedColorList = KeyDrop[storedColorList, bcolori];
								storedColorId -= 1;
							)&]
						]];
						storedColorList[bcolor] = storedColorId;
						storedColorId += 1;
					])&
				]
			], TrackedSymbols :> {selectedColor}],
			Spacer[15],
			Column[{
				Row[{Style["H:", Bold], Spacer[15], Slider[Dynamic[h, (
						h = #;
						selectedColor = Hue[#, s, b, a];
						items[[activeItem]] = selectedColor;
					)&],
					Appearance -> "DownArrow", ImageSize -> 105]}
				],
				Row[{Style["S:", Bold], Spacer[15], Slider[Dynamic[s, (
						s = #;
						selectedColor = Hue[h, #, b, a];
						items[[activeItem]] = selectedColor;
					)&],
					Appearance -> "DownArrow", ImageSize -> 105]}
				],
				Row[{Style["B:", Bold], Spacer[15], Slider[Dynamic[b, (
						b = #;
						selectedColor = Hue[h, s, #, a];
						items[[activeItem]] = selectedColor;
					)&],
					Appearance -> "DownArrow", ImageSize -> 105]}],
				Row[{Style["A:", Bold], Spacer[15], Slider[Dynamic[a, (
						a = #;
						selectedColor = Hue[h, s, b, #];
						items[[activeItem]] = selectedColor;
					)&],
					Appearance -> "DownArrow", ImageSize -> 105]}]
			}]
		}],
		(*Content buttons*)
		Style["Targets:", Bold],
		SetterBar[
			Dynamic[activeItem, (
				activeItem = #;
				selectedColor = items[[#]];
				{h, s, b, a} = assignHSBA[selectedColor];
			)&],
			Thread[Rule[
				Keys[items],
				If[StringLength[#] >= 9, StringTake[#, 6] <> "...", StringPadRight[#, 9, " "]]& /@ Keys[items]
			]],
		Appearance -> "Horizontal" -> {Automatic, 3}]
	},
	SynchronousInitialization -> False];


variableQ = (# =!= Null) && (Quiet @ ListQ @ Solve[{}, #])&;

detectOS[]:=
	StringCases[ToLowerCase @ SystemInformation["Kernel", "Version"], {"mac", "windows"}][[1]];

Unprotect@Hold;
mk:MakeBoxes[Blank[Hold],_]/;!TrueQ[$hldGfx]^:=Block[{$hldGfx=True,Graphics,Graphics3D},mk];
Protect@Hold;

SetAttributes[PrettyColorize, HoldFirst];
PrettyColorize[graphics_] :=
	DynamicModule[{items, colorAsso, imageSize, aspectRatio, gname=Null},
		items = Cases[Hold @ graphics, Pretty[label___] :> label, All];
		If[Length[items] === 0,
			(*No slot*)
			graphics,
			(*Has slot*)
			colorAsso = Association @ Thread[Rule[items, ConstantArray[Black, Length[items]]]];

			(*Extract ImageSize*)
			imageSize = Cases[ReleaseHold[List @@@ Hold[graphics]], HoldPattern[ImageSize -> s_] :> s];
			If[imageSize =!= {},
				imageSize = imageSize[[1]],
				imageSize = Automatic
			];
			(*Print[imageSize];*)

			(*Extract AspectRatio*)
			aspectRatio = Cases[ReleaseHold[Hold[graphics] /. Pretty[___] -> Black], HoldPattern[AspectRatio -> ar_] :> ar, {2}];
			If[aspectRatio =!= {},
				aspectRatio = aspectRatio[[1]],
				aspectRatio = 1/GoldenRatio
			];
			(*Print[aspectRatio];*)

			Framed @ Panel[
				Row[{Deploy @ Panel[Column[{
					createColorPalette[colorAsso],
					(*Actions*)
					Row[{
						Style["Name:",Bold],
						Spacer[15],
						InputField[Dynamic[gname], Boxes,
							ContinuousAction -> True,
							FieldHint -> "Graphics name",
							ImageSize -> {If[detectOS[] === "mac", 130, 115], 20}
						]
					}],
					Row[{
						Button[Style["Confirm", Bold],
							If[variableQ @ ToExpression @ gname,
								CellPrint[Cell[BoxData[RowBox[
									{gname, "=", ToBoxes[Defer[graphics] /. Normal[KeyMap[Pretty, colorAsso]]]}
								]], "Input"]]
								,
								CellPrint[Cell[BoxData[RowBox[
									{ToBoxes[Defer[graphics] /. Normal[KeyMap[Pretty, colorAsso]]]}
								]], "Input"]] 
							];,
							Appearance -> If[detectOS[] === "mac", Automatic, "Palette"],
							ImageSize -> {100, 20}
						],
						Spacer[12],
						Button[Style["Help", Bold],
							MessageDialog["Help", WindowTitle -> "Help"],
							Appearance -> If[detectOS[] === "mac", Automatic, "Palette"],
							ImageSize -> {60, 20}
						]
					}]
				}], Appearance -> "Palette", Background -> White],
				Framed[Panel[Dynamic[
					Graphics[
						ReleaseHold[
							(Hold[graphics] /. Normal[KeyMap[Pretty, colorAsso]]) /. {
								HoldPattern[ImageSize -> s_] :> ImageSize -> If[imageSize === Automatic, Automatic, Min[350 / aspectRatio, imageSize]]
							}
						],
					ImageSize -> 1000],
					TrackedSymbols :> {colorAsso}
				], Background -> White, Alignment -> Center],
				Alignment -> Center, FrameStyle -> LightGray, 
				ImageSize -> {If[imageSize === Automatic, 380 / aspectRatio, Min[380 / aspectRatio, imageSize + 30]], 380}
				],
				Spacer[5]}], Background -> White
			]
		]
	,
	SynchronousInitialization -> False];
