%%%-------------------------------------------------------------------
%%% @author stephb
%%% @copyright (C) 2020, Arilia Wireless Inc.
%%% @doc
%%%
%%% @end
%%% Created : 15. Nov 2020 9:47 a.m.
%%%-------------------------------------------------------------------
-module(utils).
-author("stephb").

%% API
-export([make_dir/1,uuid/0,get_addr/0,get_addr2/0,app_name/0,app_name/1,priv_dir/0,app_env/2,to_string_list/2,to_binary_list/2,print_nodes_info/1,
					do/2]).

-spec make_dir( DirName::string() ) -> ok | { error, atom() }.
make_dir(DirName)->
	case file:make_dir(DirName) of
		ok -> ok;
		{error,eexist} -> ok;
		Error -> Error
	end.

-spec uuid()->string().
uuid()->
	uuid:uuid_to_string(uuid:get_v4()).

-spec get_addr() -> IpAddress::string().
get_addr()->
	{ok,Ifs} = inet:getifaddrs(),
	case strip_ifs(Ifs) of
		none -> "0.0.0.0";
		[A|_] -> inet:ntoa(A)
	end.

-spec get_addr2() -> IpAddress::string().
get_addr2()->
	Node=atom_to_list(node()),
	[_,Host]=string:tokens(Node,"@"),
	case inet:gethostbyname(Host) of
		{ok,{hostent,_Host2,_,inet,4,[Address1|_]}} ->
			inet:ntoa(Address1);
		Error->
			Error
	end.

-spec app_name( AppName::atom() )->ok.
app_name(AppName)->
	persistent_term:put(running_app,AppName),
	persistent_term:put(priv_dir,code:priv_dir(AppName)).

-spec app_name()->AppName::atom().
app_name()->
	persistent_term:get(running_app).

-spec priv_dir()->DirName::string().
priv_dir()->
	persistent_term:get(priv_dir).

-spec app_env(Key::atom(),Default::term())->Value::term().
app_env(Key,Default)->
	application:get_env(app_name(),Key,Default).


print_nodes_info(Nodes)->
	io:format("---------------------------------------------------------------------------------------------~n"),
	io:format("|Node name                             | Total       | Allocated   | Biggest      |  Procs  |~n"),
	io:format("|--------------------------------------|-------------|-------------|-------------------------~n"),
	print_line(Nodes),
	io:format("---------------------------------------------------------------------------------------------~n").

print_line([])->
	ok;
print_line([H|T])->
	NodeInfo = node_info(H),
	#{ total := Total , allocated := Allocated , worst := Worst , processes := Processes } = NodeInfo,
	io:format("|~37s |~9.2f MB |~9.2f MB | ~9.2f MB | ~7b |~n",[atom_to_list(H),Total,Allocated,Worst,Processes]),
	print_line(T).

node_info(Node)->
	try
		{Total,Allocated,{ _Pid, Worst}}=rpc:call(Node,memsup,get_memory_data,[]),
		Processes = rpc:call(Node,cpu_sup,nprocs,[]),
		#{ total => Total/(1 bsl 20), allocated => Allocated/(1 bsl 20), worst => Worst/(1 bsl 20), processes => Processes }
	catch
		_:_ ->
			#{ total => 0, allocated => 0, worst => 0, processes => 0 }
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
strip_ifs(Ifs)->
	strip_ifs(Ifs,[]).

strip_ifs([],[])->
	none;
strip_ifs([],GoodAddresses)->
	lists:reverse(GoodAddresses);
strip_ifs([{_IfName,Ifprops}|Tail],Addrs)->
	Ifs=proplists:lookup_all(addr,Ifprops),
	case Ifs of
		[] ->
			strip_ifs(Tail,Addrs);
		Ifs ->
			case good_address(Ifs) of
				none ->
					strip_ifs(Tail,Addrs);
				Addr->
					strip_ifs(Tail,[Addr|Addrs])
			end
	end.

good_address([])->
	none;
good_address([{addr,{127,_,_,_}}|T]) ->
	good_address(T);
good_address([{addr,{A,B,C,D}}|_Tail]) when A=/=127 ->
	{A,B,C,D};
good_address([_|T])->
	good_address(T).

-spec to_string_list([term()],[term()])->[string()].
to_string_list([],R)->
	lists:reverse(R);
to_string_list([H|T],R) when is_list(H)->
	to_string_list(T,[H|R]);
to_string_list([H|T],R) when is_atom(H)->
	to_string_list(T,[atom_to_list(H)|R]);
to_string_list([H|T],R) when is_binary(H)->
	to_string_list(T,[binary_to_list(H)|R]).

-spec to_binary_list([term()],[term()])->[string()].
to_binary_list([],R)->
	lists:reverse(R);
to_binary_list([H|T],R) when is_list(H)->
	to_binary_list(T,[list_to_binary(H)|R]);
to_binary_list([H|T],R) when is_atom(H)->
	to_binary_list(T,[list_to_binary(atom_to_list(H))|R]);
to_binary_list([H|T],R) when is_binary(H)->
	to_binary_list(T,[H|R]).

-spec do(boolean(),{atom(),atom(),term()})->ok.
do(true,{M,F,A})->
	_=apply(M,F,A), ok;
do(false,_)->
	ok.



