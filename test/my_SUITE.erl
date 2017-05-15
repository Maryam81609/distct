-module(my_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("kernel/include/inet.hrl").
-compile(export_all).
%% common_test callbacks
-export([%% suite/0,
         init_per_suite/1,
         end_per_suite/1,
         init_per_testcase/2,
         end_per_testcase/2,
         all/0]).

all() -> [test1].

init_per_suite(Config) ->
  Node = init(Config),
  [{remnode, Node} | Config].

end_per_suite(Config) ->
    Config.

init_per_testcase(_Case, Config) ->
    Config.

end_per_testcase(_, _) ->
    ok.

init(Config) ->
  ct:print("~n=======node: ~p~n========", [node()]),
  os:cmd(os:find_executable("epmd") ++ " -daemon"),
 % {ok, Hostname} = inet:gethostname(),
  case net_kernel:start([list_to_atom("runner@"++"127.0.0.1"), longnames]) of
    {ok, _} -> erlang:set_cookie(node(), antidote);
    {error, Reason} -> throw(io_lib:format("~p", [Reason]))
  end,
  ct:print("~n=======node: ~p~n========", [node()]),

  A = [1, 2, 3],
  3 = length(A),
  NodeConfig = [
    {monitor_master, true},
    {erl_flags, "-smp"},
    {startup_functions, [{erlang, set_cookie, [node(), antidote]}]}],
  case ct_slave:start('127.0.0.1', dev1, NodeConfig) of
    {ok, Node} -> 
      ct:print("~n========New node: ~p=======~n", [Node]),
      Node;
    {error, Reason2} -> throw(io_lib:format("~p", [Reason2]))
  end.

test1(Config) ->
  Node = proplists:get_value(remnode, Config),
  ct:print("~n=======Remote node: ~p=======~n", [Node]),
  pass.
