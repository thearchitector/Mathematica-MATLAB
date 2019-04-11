(* ::Package:: *)

(* 
A utility package for converting Mathematica syntax to MATLAB code. Originally created by Harri Ojanen, and modified for functionality and clarity by Elias Gabriel.

2019 Elias Gabriel
eliasfgabriel@gmail.com
https://www.linkedin.com/in/eliasfgabriel/

1997-1999 Harri Ojanen
harri.ojanen@iki.fi
http://www.iki.fi/~harri.ojanen/

- Last modified April 8, 2019 by EG
- Previously modified April 2, 1999 by HO
*)


(*** Exposed functions *****************************************************)
BeginPackage["ToMatlab`"]

ToMatlab::usage = "ToMatlab[expr, {prop_1 \[Rule] val_1, prop_2 \[Rule] val_2, ...}] converts the expression into MATLAB syntax and returns it as a string."
Begin["`Private`"]
ToMatlab::invtrans = "Matrix transposition option expects True or False, not `1`."

ToMatlab[e_, OptionsPattern[]] := Catch[If[ListQ[e] || MatrixQ[e],
	If[BooleanQ[OptionValue[Transpose]],
		Block[{lm = If[Length[Dimensions[e]] > 1, e, {e}]}, translate[If[OptionValue[Transpose], Transpose[lm], lm]]],
		Throw[Message[ToMatlab::invtrans, OptionValue[Transpose]]]
	],
	translate[e]
] <> If[BooleanQ[OptionValue[SuppressOutput]] && OptionValue[SuppressOutput], ";", ""]]

Options[ToMatlab] = {SuppressOutput -> True, Transpose -> False}


(*** Numbers and strings *****************************************************)

translate[s_String] := s
translate[n_Integer] := If[n >= 0, ToString[n], "(" <> ToString[n] <> ")"]
translate[r_Rational] := "(" <> ToString[Numerator[r]] <> "/" <> ToString[Denominator[r]] <> ")"
translate[r_Real] := Block[{a = MantissaExponent[r]}, If[r >= 0, ToString[N[a[[1]], 18]] <> "E" <> ToString[a[[2]]], "(" <> ToString[N[a[[1]], 18]] <> "E" <> ToString[a[[2]]] <> ")"]]
translate[I] := "sqrt(-1)"
translate[c_Complex] := "(" <> If[Re[c] === 0, "", translate[Re[c]] <> "+"] <> If[Im[c] === 1, "sqrt(-1)", "sqrt(-1)*" <> translate[Im[c]]] <> ")"


(*** Lists, vectors and matrices *********************************************)

isnumericmatrix[m_] := MatrixQ[m] && (And @@ Map[isnumericlist, m])
isnumericlist[l_] := ListQ[l] && (And @@ Map[NumberQ, l])
numbermatrix[m_] := Block[{i, s=""}, 
	For[i=1, i <= Length[m], i++,
	    s = s <> numbermatrixrow[m[[i]]];    
	    If[i < Length[m], s = s <> "; "]
	];
s]

numbermatrixrow[l_] := Block[{i, s=""},
	For[i = 1, i <= Length[l], i++, 
	    s = s <> translate[l[[i]]];
	    If[i < Length[l], s = s <> ", "]
	];
s]

translate[l_List /; MatrixQ[l]] := If[isnumericmatrix[l], "[" <> numbermatrix[l] <> "]", "[" <> matrix[l] <> "]"]
matrix[m_] := If[Length[m] === 1, args[m[[1]]], args[m[[1]]] <> "; " <> matrix[listshift[m]]]
translate[l_List] := "[" <> args[l] <> "]"


(*** Symbols *****************************************************************)

translate[e_Symbol] := ToLowerCase[CharacterName[ToString[e]]]

translate[Colon] = ":"
translate[Abs] = "abs"
translate[Min] = "min"
translate[Max] = "max"
translate[Sin] = "sin"
translate[Cos] = "cos"
translate[Tan] = "tan"
translate[Cot] = "cot"
translate[Csc] = "csc"
translate[Sec] = "sec"
translate[ArcSin] = "asin"
translate[ArcCos] = "acos"
translate[ArcTan] = "atan"
translate[ArcCot] = "acot"
translate[ArcCsc] = "acsc"
translate[ArcSec] = "asec"
translate[Sinh] := "sinh"
translate[Cosh] := "cosh"
translate[Tanh] := "tanh"
translate[Coth] := "coth"
translate[Csch] := "csch"
translate[Sech] := "sech"
translate[ArcSinh] := "asinh"
translate[ArcCosh] := "acosh"
translate[ArcTanh] := "atanh"
translate[ArcCoth] := "acoth"
translate[ArcCsch] := "acsch"
translate[ArcSech] := "asech"
translate[Log] := "log"
translate[Exp] := "exp"
translate[MatrixExp] := "expm"
translate[Pi] := "pi "
translate[E] := "exp(1)"
translate[True] := "1"
translate[False] := "0"


(*** Relational operators ****************************************************)

relop[e_, o_] := If[Length[e] === 1,  "(" <> translate[e[[1]]] <> ")", "(" <> translate[e[[1]]] <> ")" <> o <> relop[listshift[e], o]]

translate[e_ /; Head[e] === Equal] := relop[list[e], "=="]
translate[e_ /; Head[e] === Unequal] := relop[list[e], "~="]
translate[e_ /; Head[e] === Less] := relop[list[e], "<"]
translate[e_ /; Head[e] === Greater] := relop[list[e], ">"]
translate[e_ /; Head[e] === LessEqual] := relop[list[e], "<="]
translate[e_ /; Head[e] === GreaterEqual] := relop[list[e], ">="]
translate[e_ /; Head[e] === And] := relop[list[e], "&"]
translate[e_ /; Head[e] === Or] := relop[list[e], "|"]
translate[e_ /; Head[e] === Not] := "~(" <> translate[e[[1]]] <> ")"

isrelop[e_] := MemberQ[{Equal, Unequal, Less, Greater, LessEqual, GreaterEqual, And, Or, Not}, Head[e]]


(*** Addition, multiplication and powers *************************************)

translate[e_ /; Head[e] === Plus] := If[isrelop[e[[1]]], "(" <> translate[e[[1]]] <> ")", translate[e[[1]]]] <> "+" <> If[Length[e] === 2,
	If[isrelop[e[[2]]], "(" <> translate[e[[2]]] <> ")", translate[e[[2]]]],
	translate[listshiftretain[e]]
]

translate[e_ /; Head[e] === Times] := If[Head[e[[1]]] === Plus, "(" <> translate[e[[1]]] <> ")", translate[e[[1]]]] <> ".*" <> If[Length[e] === 2,
	If[Head[e[[2]]] === Plus, "(" <> translate[e[[2]]] <> ")", translate[e[[2]]]],
	translate[listshiftretain[e]]
]

translate[e_ /; Head[e] === Power] := If[Head[e[[1]]] === Plus || Head[e[[1]]] === Times || Head[e[[1]]] === Power, "(" <> translate[e[[1]]] <> ")", translate[e[[1]]]] <> ".^" <> If[Length[e] === 2,
	If[Head[e[[2]]] === Plus || Head[e[[2]]] === Times || Head[e[[2]]] === Power, "(" <> translate[e[[2]]] <> ")", translate[e[[2]]]],
	translate[listshiftretain[e]]
]


(*** Special function cases **********************************************)

translate[Rule[_,r_]] := translate[r]
translate[Log[10, z_]] := "log10(" <> translate[z] <> ")"
translate[Log[b_, z_]] := "log(" <> translate[z] <> ")./log(" <> translate[b] <> ")"
translate[Power[e_, 1/2]] := "sqrt(" <> translate[e] <> ")"
translate[Power[E, z_]] := "exp(" <> translate[z] <> ")"
translate[If[test_, t_, f_]] := Block[{teststr = translate[test]}, "((" <> teststr <> ").*(" <> translate[t] <> ")+(~(" <> teststr <> ")).*(" <> translate[f] <> "))"]
translate[e__ /; (Head[e] === Max || Head[e] == Min)] := translate[Head[e]] <> "(" <> If[Length[e] === 2, args[e] <> ")", translate[e[[1]]] <> ", " <> translate[listshiftretain[e]] <> ")"]
translate[Colon[a_,b_]] := "((" <> translate[a] <> "):(" <> translate[b] <> "))"
translate[Colon[a_,b_,c_]] := "((" <> translate[a] <> "):(" <> translate[b] <> "):(" <> \[AliasDelimiter][c] <> "))"


(*** Internal functions *******************************************************)

translate[e_] := translate[Head[e]] <> "(" <> args[list[e]] <> ")"
args[e_] := If[Length[e] === 1, translate[e[[1]]], translate[e[[1]]] <> ", " <> args[listshift[e]]]
list[e_] := Block[{ARGSLISTINDEX}, Table[ e[[ARGSLISTINDEX]], {ARGSLISTINDEX, 1, Length[e]}]]
listshift[e_] := Block[{ARGSLISTINDEX}, Table[e[[ARGSLISTINDEX]], {ARGSLISTINDEX, 2, Length[e]}]] (* Removes HEAD *)
listshiftretain[e_] := e[[Block[{i}, Table[i, {i, 2, Length[e]}]]]] (* Keeps HEAD *)

End[]
EndPackage[]
