-module(config_behavior_impl).

-export([get_socket_handler_module/0, get_socket_package_module/0]).

% 用于定义各种回调模块

get_socket_handler_module() ->
  demo_server_socket_handler_impl.

%% 业务级别拆包
get_socket_package_module() ->
  demo_server_socket_package_impl.