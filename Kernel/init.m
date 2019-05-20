(* ::Package:: *)

If[Not@OrderedQ[{11.0, 0}, {$VersionNumber, $ReleaseNumber}],
  Print["PrettyColorize requires Mathematica 11.0.0 or later."];
  Abort[]
]

Unprotect["PrettyColorize`*", "PrettyColorize`Private`*"];

SetAttributes[
  Evaluate @ Flatten[Names /@ {"PrettyColorize`*", "PrettyColorize`Private`*"}],
  {Protected, ReadProtected}
]
