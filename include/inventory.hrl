%%%-------------------------------------------------------------------
%%% @author stephb
%%% @copyright (C) 2020, Arilia Wireless Inc.
%%% @doc
%%%
%%% @end
%%% Created : 29. Oct 2020 12:16 p.m.
%%%-------------------------------------------------------------------
-author("stephb").

-include_lib("stdlib/include/qlc.hrl").

-type attribute_list() :: [{string(),string()}].
-type record_index() :: { string() , string() }.

-record(ca_info,{
	uuid = "" :: string(),
	name = "" :: string(),   %% You must leave the NAME field first - do not move it...
	description = "" :: string(),
	dir_name = "" :: string(),
	clients_dir_name = "" :: string(),
	servers_dir_name = "" :: string(),
	cert_file_name = "" :: string(),
	key_file_name = "" :: string(),
	config_file_name = "" :: string(),
	cert_data = <<>> :: binary(),
	key_data = <<>> :: binary(),
	decrypt_data = <<>> :: binary(),
	config_data = <<>> :: binary(),
	password = "" :: string(),
	attributes = [] :: attribute_list()
}).

-type client_role() :: none | mqtt_client | ovsdb_client.

-record( client_info, {
	uuid = "" :: string(),
	index = {} :: record_index(),    %% should be a tuple { CA, Name }, must be in position 1
	name = "" :: string(),
	cap = [] :: [client_role()],
	mac = "" :: string(),
	serial = "" :: string(),
	description = "" :: string(),
	type = "" :: string(),
	firmware = "" :: string(),
	vendor = "" :: string(),
	device_model = "" :: string(),
	key = <<>> :: binary(),
	cert = <<>> :: binary(),
	decrypt = <<>> :: binary(),
	csr = <<>> :: binary(),
	attributes = [] :: attribute_list()
}).

-type service_role() :: none | mqtt_server | ovsdb_server .

-record( server_info, {
	uuid = "" :: string(),
	index = {} :: record_index(),    %% should be a tuple { CA, Name }, must be in position 1
	name  = "" :: string(),
	service = none :: service_role(),
	ca  = "" :: string(),
	description  = "" :: string(),
	type  = "" :: string(),
	version  = "" :: string(),
	ports = "" :: string(),
	addresses = "" :: list(string()),
	key = <<>> :: binary(),
	cert = <<>> :: binary(),
	decrypt = <<>> :: binary(),
	csr = <<>> :: binary(),
	attributes = [] :: attribute_list()
}).

-type any_role() :: service_role() | client_role().
-type ca_info() :: #ca_info{}.
-type client_info() :: #client_info{}.
-type server_info() :: #server_info{}.

-export_type([client_info/0,server_info/0,ca_info/0,record_index/0,attribute_list/0,client_role/0,service_role/0,
	any_role/0]).