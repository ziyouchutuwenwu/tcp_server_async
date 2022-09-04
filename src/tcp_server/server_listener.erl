-module(server_listener).

-export([listen/3, accept/2]).

listen(Port, TcpOptions, ConfigBehaviorImpl) ->
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

  % client_handler:recv_loop(Sock, ConfigBehaviorImpl),
  client_handler_sup:start_child(Sock, ConfigBehaviorImpl),
  accept(ListenSocket, ConfigBehaviorImpl).
