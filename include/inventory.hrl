%%%-------------------------------------------------------------------
%%% @author stephb
%%% @copyright (C) 2020, Arilia Wireless Inc.
%%% @doc
%%%
%%% @end
%%% Created : 29. Oct 2020 12:16 p.m.
%%%-------------------------------------------------------------------
-author("stephb").

-ifndef(__OWLS_INVENTORY_HRL__).
-define(__OWLS_INVENTORY_HRL__,1).

-include("../include/common.hrl").

-include_lib("stdlib/include/qlc.hrl").

-record(ca_info,{
	name = <<>> :: binary(),   %% You must leave the NAME field first - do not move it...
	sim_name = <<>> :: binary(),
	description = <<>> :: binary(),
	dir_name = <<>> :: binary(),
	clients_dir_name = <<>> :: binary(),
	servers_dir_name = <<>> :: binary(),
	cert_file_name = <<>> :: binary(),
	key_file_name = <<>> :: binary(),
	config_file_name = <<>> :: binary(),
	key = {none,<<>>} :: {atom(), binary()},
	cert = <<>> :: binary(),
	decrypt_data = <<>> :: binary(),
	config_data = <<>> :: binary(),
	password = <<>> :: binary(),
	attributes = #{} :: attribute_list()
}).

-type client_role() :: none | mqtt_client | ovsdb_client.

-record( client_info, {
	name = <<>> :: binary(),
	ca  = <<>> :: binary(),
	cap = [] :: [client_role()],
	mac = <<>> :: binary(),
	serial = <<>> :: binary(),
	description = <<>> :: binary(),
	type = <<>> :: binary(),
	id = <<>> :: binary(),              %% hardware ID
	key = {none,<<>>} :: {atom(), binary()},
	cert = <<>> :: binary(),
	decrypt = <<>> :: binary(),
	csr = <<>> :: binary(),
	cacert = <<>> :: binary(),
	attributes = #{} :: attribute_list()
}).

-type service_role() :: none | mqtt_server | ovsdb_server .

-record( server_info, {
	name  = <<>> :: binary(),
	service = none :: service_role(),
	ca  = <<>> :: binary(),
	description  = <<>> :: binary(),
	type  = <<>> :: binary(),
	version  = <<>> :: binary(),
	ports = [] :: [integer()],
	addresses = [] :: [inet:ip_address()],
	key = {none,<<>>} :: {atom(), binary()},
	cert = <<>> :: binary(),
	decrypt = <<>> :: binary(),
	csr = <<>> :: binary(),
	cacert = <<>> :: binary(),
	attributes = #{} :: attribute_list()
}).

-record( hardware_info, {
	id = <<>> :: binary(),
	description = <<>> :: binary(),
	vendor = <<>> :: binary(),
	model = <<>> :: binary(),
	capabilities = [] :: [ mqtt_client | ovsdb_client ],
	firmware = <<>> :: binary()
}).

-type any_role() :: service_role() | client_role().
-type ca_info() :: #ca_info{}.
-type client_info() :: #client_info{}.
-type server_info() :: #server_info{}.
-type hardware_info() :: #hardware_info{}.

-export_type([client_info/0,server_info/0,ca_info/0,client_role/0,service_role/0,
	any_role/0,hardware_info/0]).

-endif.