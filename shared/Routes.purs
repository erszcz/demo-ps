module Routes where

import Prelude hiding ((/))

import Data.Either (Either(..))
import Data.Generic.Rep (class Generic, NoArguments(..), Product(..))
import Data.Generic.Rep.Show (genericShow)
import Data.Newtype (class Newtype, unwrap, wrap)
import Data.Profunctor (dimap)
import Routing.Duplex (RouteDuplex', as, path, rest, segment)
import Routing.Duplex as RouteDuplex
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))

import Books (Isbn)

data Route
  = Books
  | Book Isbn
  | Assets (Array String)
  | EventsWs
  | EventsFirehoseRest
  | DataStream
  | Index
  | Index2 String (Array String)

derive instance genericRoute :: Generic Route _

instance showRoute :: Show Route where
  show = genericShow

asNewtype :: forall a. Newtype a String => RouteDuplex' String -> RouteDuplex' a
asNewtype = as unwrap (pure <<< wrap)

-- | This combinator transforms a codec over `String` into one that operates on the `Isbn` type.
isbn :: RouteDuplex' String -> RouteDuplex' Isbn
isbn = asNewtype

segmentExcept :: String -> RouteDuplex' String 
segmentExcept s = as identity f $ segment
  where
  f x = if x == s then Left "matched except" else Right x

apiRoute :: RouteDuplex' Route
apiRoute = path "" $ sum
  { "Books": "api" / "books" / noArgs
  , "Book": "api" / "books" / isbn segment
  , "EventsWs": "api" / "events" / "ws" / noArgs
  , "EventsFirehoseRest": "api" / "events" / "stream" / noArgs
  , "DataStream": "api" / "stream" / noArgs
  , "Assets" : "assets" / rest
  , "Index" : noArgs
  , "Index2" : segmentExcept "api" / rest
  }

routeUrl :: Route -> String
routeUrl = RouteDuplex.print apiRoute
