%%%-------------------------------------------------------------------
%%% @author stephb
%%% @copyright (C) 2020, Arilia Wireless Inc.
%%% @doc
%%%
%%% @end
%%% Created : 25. Oct 2020 3:21 p.m.
%%%-------------------------------------------------------------------
-module(manager_rest_api).
-author("stephb").

-compile({parse_transform, lager_transform}).

-behaviour(gen_server).

-include("../include/common.hrl").
-include("../include/mqtt_definitions.hrl").

%% API
-export([start_link/0,creation_info/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
	code_change/3]).

-define(SERVER, ?MODULE).

-record(rest_api_state, { env }).

%%%===================================================================
%%% API
%%%===================================================================
creation_info() ->
	[	#{	id => ?MODULE ,
		start => { ?MODULE , start_link, [] },
		restart => permanent,
		shutdown => 100,
		type => worker,
		modules => [?MODULE]} ].

%% @doc Spawns the server and registers the local name (unique)
-spec(start_link() ->
	{ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
%% @doc Initializes the server
-spec(init(Args :: term()) ->
	{ok, State :: #rest_api_state{}} | {ok, State :: #rest_api_state{}, timeout() | hibernate} |
	{stop, Reason :: term()} | ignore).
init([]) ->
	process_flag(trap_exit, true),
	Port = utils:app_env( rest_api_port, 9090),
	Secure = utils:app_env( rest_api_tls, false),
	PrivDir = utils:priv_dir(),
	Dispatch = cowboy_router:compile([
		{
			'_', [
			{ "/api/v1/oauth2/[:token]", web_token_manager, [] },
			{ "/api/v1/:restype/[:resid/[:subres/[:subid]]]", manager_api_rest_handler, [] },
			{ "/ws", web_socket_handler, [] },
			{ "/", cowboy_static, {file,filename:join([PrivDir,"www/index.html"])} },
			{ "/[...]", cowboy_static, {dir, filename:join([PrivDir,"www"])} }
		]}
	]),
	{ok, CB } = case Secure of
		            true ->
			            ?L_I("Starting in secure mode."),
			            cowboy:start_tls(
				            rest_http_listener,
				            [
					            {port,Port},{sndbuf,250000},
					            {certfile, filename:join([PrivDir,"ssl","rest-api-cert.pem"])},
					            {keyfile, filename:join([PrivDir,"ssl","rest-api-key.pem"])}				            ],
				            #{env => #{dispatch => Dispatch}} );
		            false ->
			            ?L_I("Starting in clear mode."),
			            cowboy:start_clear(
				            rest_http_listener,
				            [
					            {port,Port},{sndbuf,250000}
				            ],
				            #{env => #{dispatch => Dispatch}} )
	            end,
	{ok, #rest_api_state{ env = CB }}.

%% @private
%% @doc Handling call messages
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
		State :: #rest_api_state{}) ->
	{reply, Reply :: term(), NewState :: #rest_api_state{}} |
	{reply, Reply :: term(), NewState :: #rest_api_state{}, timeout() | hibernate} |
	{noreply, NewState :: #rest_api_state{}} |
	{noreply, NewState :: #rest_api_state{}, timeout() | hibernate} |
	{stop, Reason :: term(), Reply :: term(), NewState :: #rest_api_state{}} |
	{stop, Reason :: term(), NewState :: #rest_api_state{}}).
handle_call(_Request, _From, State = #rest_api_state{}) ->
	{reply, ok, State}.

%% @private
%% @doc Handling cast messages
-spec(handle_cast(Request :: term(), State :: #rest_api_state{}) ->
	{noreply, NewState :: #rest_api_state{}} |
	{noreply, NewState :: #rest_api_state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #rest_api_state{}}).
handle_cast(_Request, State = #rest_api_state{}) ->
	{noreply, State}.

%% @private
%% @doc Handling all non call/cast messages
-spec(handle_info(Info :: timeout() | term(), State :: #rest_api_state{}) ->
	{noreply, NewState :: #rest_api_state{}} |
	{noreply, NewState :: #rest_api_state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #rest_api_state{}}).
handle_info(_Info, State = #rest_api_state{}) ->
	{noreply, State}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
		State :: #rest_api_state{}) -> term()).
terminate(_Reason, _State = #rest_api_state{}) ->
	ok.

%% @private
%% @doc Convert process state when code is changed
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #rest_api_state{},
		Extra :: term()) ->
	{ok, NewState :: #rest_api_state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State = #rest_api_state{}, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
