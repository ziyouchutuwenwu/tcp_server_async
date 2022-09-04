-module(server_async_listener).

-export([start_link/3, init/3, accept_loop/2]).

start_link(Port, TcpOptions, ConfigBehaviorImpl) ->
  Pid = spawn_link(?MODULE, init, [Port, TcpOptions, ConfigBehaviorImpl]),
  {ok, Pid}.

init(Port, TcpOptions, ConfigBehaviorImpl) ->
  client_handler_sup:start_link(),
  {ok, ListenSocket} = gen_tcp:listen(Port, TcpOptions),
  accept_loop(ListenSocket, ConfigBehaviorImpl).

accept_loop(ListenSocket, ConfigBehaviorImpl) ->
  prim_inet:async_accept(ListenSocket, -1),
  receive
    {inet_async, _ListenSocket, _Ref, {ok, NewSock}} ->
      set_sockopt(ListenSocket, NewSock),
      {ok, Pid} = client_handler_sup:start_child(NewSock, ConfigBehaviorImpl),
      gen_tcp:controlling_process(NewSock, Pid),
      Pid ! {tcp_connected, NewSock},
      accept_loop(ListenSocket, ConfigBehaviorImpl)
  end.

% socket 生成以后，需要通过这个函数设置一下，否则发送数据会崩溃
set_sockopt(ListenSocket, ClientSocket) ->
  true = inet_db:register_socket(ClientSocket, inet_tcp),
  case prim_inet:getopts(ListenSocket,
                         [active, nodelay, keepalive, delay_send, priority, tos])
  of
    {ok, Opts} ->
      case prim_inet:setopts(ClientSocket, Opts) of
        ok ->
          ok;
        Error ->
          gen_tcp:close(ClientSocket),
          Error
      end;
    Error ->
      gen_tcp:close(ClientSocket),
      Error
  end.
