-module(tcp_server_sup).

-behaviour(supervisor).

-export([start_link/3]).
-export([init/1]).

start_link(Port, TcpOptions, ConfigBehaviorImpl) ->
  supervisor:start_link({local,?MODULE}, ?MODULE, [Port, TcpOptions, ConfigBehaviorImpl]).

init([Port, TcpOptions, ConfigBehaviorImpl]) ->
  MaxRestarts = 5,
  MaxSecondsBetweenRestarts = 10,

  SupervisorFlags =
    #{strategy => one_for_one,
      intensity => MaxRestarts,
      period => MaxSecondsBetweenRestarts},

  ChildSpecs =
    [
      #{
        id => server_async_listener,
        start => {server_async_listener, start_link, [Port, TcpOptions, ConfigBehaviorImpl]},
        restart => transient,
        shutdown => brutal_kill,
        type => worker,
        modules => [server_async_listener]
      },
      #{
        id => client_handler_sup,
        start => {client_handler_sup, start_link, []},
        restart => permanent,
        shutdown => infinity,
        type => supervisor,
        modules => [client_handler_sup]
      }
  ],

  {ok, {SupervisorFlags, ChildSpecs}}.