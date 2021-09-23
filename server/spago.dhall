{-
-}
{ name = "demo"
, dependencies =
  [ "console"
  , "control"
  , "effect"
  , "either"
  , "erl-atom"
  , "erl-binary"
  , "erl-cowboy"
  , "erl-lists"
  , "erl-logger"
  , "erl-maps"
  , "erl-modules"
  , "erl-pinto"
  , "erl-process"
  , "erl-simplebus"
  , "erl-stetson"
  , "erl-tuples"
  , "filterable"
  , "foldable-traversable"
  , "foreign"
  , "maybe"
  , "newtype"
  , "partial"
  , "prelude"
  , "psci-support"
  , "record"
  , "routing-duplex"
  , "simple-json"
  , "transformers"
  , "typelevel-prelude"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
, backend = "purerl"
}
