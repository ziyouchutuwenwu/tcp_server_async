-module(tcp_server_demo).

%% -compile(export_all).
-export([start/0, send_by_socket/1]).

tcp_opts() ->
  [
    binary,
    % active 必须为 false
    {active, false},
    {packet, 2},
    {nodelay, true},
    {reuseaddr, true},
    {keepalive, true},
    {backlog, 500}
  ].

start() ->
  tcp_server:start(9999, tcp_opts(), config_behavior_impl).

send_by_socket(Socket) ->
  InfoBin = utf8_list:list_to_binary("我没有来"),
  tcp_server_send:send_data_by_socket(Socket, 111, InfoBin, config_behavior_impl).
