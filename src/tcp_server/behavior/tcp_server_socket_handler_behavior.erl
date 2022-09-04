-module(tcp_server_socket_handler_behavior).

-callback on_client_connected(Socket :: port(), IP :: string(), Port :: integer()) ->
  noreplay.

-callback on_client_data(Socket :: port(), Cmd :: integer(), InfoBin :: any()) ->
  noreplay.

-callback on_disconnected(Socket :: port(), Reason :: string()) ->
  noreplay.