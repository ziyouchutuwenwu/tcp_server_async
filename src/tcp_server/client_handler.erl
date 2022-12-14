-module(client_handler).

-export([start_link/2, recv_loop/2]).

start_link(Sock, ConfigBehaviorImpl) ->
  Pid = spawn_link(?MODULE, recv_loop, [Sock, ConfigBehaviorImpl]),
  {ok, Pid}.

recv_loop(Sock, ConfigBehaviorImpl) ->
  prim_inet:async_recv(Sock, 0, -1),
  receive
    {tcp_connected, _Sock} ->
      {ok, {ClientIp, ClientPort}} = inet:peername(Sock),
      ClientIpStr = inet:ntoa(ClientIp),
      SocketHandlerModule = ConfigBehaviorImpl:get_socket_handler_module(),
      SocketHandlerModule:on_client_connected(Sock, ClientIpStr, ClientPort),
      recv_loop(Sock, ConfigBehaviorImpl);
    {inet_async, _Sock, _Ref, {ok, Data}} ->
      SocketUnpackModule = ConfigBehaviorImpl:get_socket_package_module(),
      {Cmd, InfoBin} = SocketUnpackModule:unpack(Data),

      SocketHandlerModule = ConfigBehaviorImpl:get_socket_handler_module(),
      SocketHandlerModule:on_client_data(Sock, Cmd, InfoBin),
      recv_loop(Sock, ConfigBehaviorImpl);
    {inet_async, _Sock, _Ref, {error, Reason}} ->
      SocketHandlerModule = ConfigBehaviorImpl:get_socket_handler_module(),
      SocketHandlerModule:on_disconnected(Sock, Reason),
      {error, Reason}
  end.