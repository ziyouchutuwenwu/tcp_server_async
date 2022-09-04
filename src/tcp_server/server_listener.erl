-module(server_listener).

-export([start_link/3, init/3, accept/2]).

start_link(Port, TcpOptions, ConfigBehaviorImpl) ->
  Pid = spawn_link(?MODULE,init,[Port, TcpOptions, ConfigBehaviorImpl]),
  {ok, Pid}.

init(Port, TcpOptions, ConfigBehaviorImpl) ->
  client_handler_sup:start_link(),
  {ok, ListenSocket} = gen_tcp:listen(Port, TcpOptions),
  accept(ListenSocket, ConfigBehaviorImpl).

accept(ListenSocket, ConfigBehaviorImpl) ->
  {ok, Sock} = gen_tcp:accept(ListenSocket),

  {ok, {ClientIp, ClientPort}} = inet:peername(Sock),
  ClientIpStr = inet:ntoa(ClientIp),

  % 连接回调
  SocketHandlerModule = ConfigBehaviorImpl:get_socket_handler_module(),
  SocketHandlerModule:on_client_connected(Sock, ClientIpStr, ClientPort),

  {ok, Pid} = client_handler_sup:start_child(Sock, ConfigBehaviorImpl),
  gen_tcp:controlling_process(Sock, Pid),
  accept(ListenSocket, ConfigBehaviorImpl).
