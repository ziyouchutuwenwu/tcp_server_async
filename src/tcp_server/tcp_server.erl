-module(tcp_server).

-export([start/3]).

start(Port, TcpOptions, ConfigBehaviorImpl) ->
  spawn_link(server_listener, listen, [Port, TcpOptions, ConfigBehaviorImpl]).
