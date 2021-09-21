module OneForOneGen where

import Prelude
import Erl.Process.Raw (Pid)
import Erl.Process ((!))
import Erl.Atom (atom)
import Erl.Data.Tuple (tuple2, tuple3)
import Data.Either (Either(..))
import Erl.Data.Binary (Binary(..))
import Data.Maybe (Maybe(..))
import Erl.Data.Map as Map
import Erl.Process (Process)
import Data.Traversable (traverse)
import Data.Newtype (wrap, unwrap)
import Effect (Effect)
import Erl.Data.List (List)
import Pinto as Pinto
import Pinto (ServerName(..), StartLinkResult)
import Pinto.GenServer (CallResult(..), CastResult(..))
import Pinto.GenServer as GenServer
import Pinto.Timer as Timer
import Pinto.Monitor as Monitor
import Books (Book, Isbn)
import Redis (ConnectionString, DbId, RedisConnection)
import Redis as Redis
import SimpleBus as SimpleBus
import BookLibrary as BookLibrary
import Erl.ModuleName (NativeModuleName(..))
import Foreign (unsafeToForeign)
import Logger as Logger

foreign import getDataFromSomeNativeCode :: Effect Binary

type MessageHandler
  = (Binary -> Effect Unit)

type State
  = { clientPid :: Pid
    , handler :: MessageHandler
    , dataSent :: Int
    }

data Msg
  = ClientDisconnected
  | Tick

type OneForOneGenServerStartArgs
  = { clientPid :: Pid
    , handler :: MessageHandler
    }

serverName :: Pid -> ServerName State Msg
serverName pid = Via (NativeModuleName $ atom "gproc") $ unsafeToForeign (tuple3 (atom "n") (atom "l") $ (tuple2 "one_for_one_example" pid))

startLink :: OneForOneGenServerStartArgs -> Effect StartLinkResult
startLink args = GenServer.buildStartLink (serverName args.clientPid) (init args) $ GenServer.defaultStartLink { handleInfo = handleInfo }

init :: OneForOneGenServerStartArgs -> GenServer.Init State Msg
init { clientPid, handler } = do
  self <- GenServer.self
  GenServer.lift do
    void $ Monitor.pid clientPid (\_ -> self ! ClientDisconnected)
    void $ Timer.sendAfter 500 Tick self
    pure $ { clientPid, handler, dataSent: 0 }

handleInfo :: Msg -> State -> GenServer.HandleInfo State Msg
handleInfo msg state@{ handler, clientPid, dataSent } = do
  case msg of
    ClientDisconnected -> do
      pure $ CastStop state
    Tick -> do
      self <- GenServer.self
      GenServer.lift do
        void $ handler =<< getDataFromSomeNativeCode
        void $ Timer.sendAfter 500 Tick self
        pure $ CastNoReply $ state { dataSent = dataSent + 1 }
