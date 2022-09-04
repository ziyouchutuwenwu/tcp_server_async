-module(server_listener).

-export([start_link/3, init/3, accept/2]).

start_link(Port, TcpOptions, ConfigBehaviorImpl) ->
  Pid = spawn_link(?MODULE, init, [Port, TcpOptions, ConfigBehaviorImpl]),
  {ok, Pid}.

init(Port, TcpOptions, ConfigBehaviorImpl) ->
  client_handler_sup:start_link(),
  {ok, ListenSocket} = gen_tcp:listen(Port, TcpOptions),
  accept(ListenSocket, ConfigBehaviorImpl).

accept(ListenSocket, ConfigBehaviorImpl) ->
  {ok, NewSock} = gen_tcp:accept(ListenSocket),
  {ok, Pid} = client_handler_sup:start_child(NewSock, ConfigBehaviorImpl),
  gen_tcp:controlling_process(NewSock, Pid),
  Pid ! {connected, NewSock},
  accept(ListenSocket, ConfigBehaviorImpl).
