-module(tcp_server).

-export([start/3]).

start(Port, TcpOptions, ConfigBehaviorImpl) ->
  tcp_server_sup:start_link(Port, TcpOptions, ConfigBehaviorImpl).
