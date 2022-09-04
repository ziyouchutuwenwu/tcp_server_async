-module(server_listener_sup).

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

  ChildSpec =
    #{id => server_listener,
      start => {server_listener, start_link, [Port, TcpOptions, ConfigBehaviorImpl]},
      restart => transient,
      shutdown => brutal_kill,
      type => worker,
      modules => [server_listener]},

  Children = [ChildSpec],
  {ok, {SupervisorFlags, Children}}.