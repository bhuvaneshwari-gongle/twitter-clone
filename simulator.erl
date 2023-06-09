-module(simulator).
-export[start/0].

start() ->
    io:fwrite("\n\n Simulator Running\n\n"),
    
    {ok, [Input_NumClients]} = io:fread("\nNumber of clients to simulate: ", "~s\n"),
    {ok, [Input_MaxSubscribers]} = io:fread("\nMaximum Number of Subscribers a client can have: ", "~s\n"),
    {ok, [Input_DisconnectClients]} = io:fread("\nPercentage of clients to disconnect to simulate periods of live connection and disconnection ", "~s\n"),

    NumClients = list_to_integer(Input_NumClients),
    MaxSubscribers = list_to_integer(Input_MaxSubscribers),
    DisconnectClients = list_to_integer(Input_DisconnectClients),

    ClientsToDisconnect = DisconnectClients * (0.01) * NumClients,

    Main_Table = ets:new(messages, [ordered_set, named_table, public]),
    createClients(1, NumClients, MaxSubscribers, Main_Table),


    Start_Time = erlang:system_time(millisecond),

    End_Time = erlang:system_time(millisecond),
    io:format("\nTime Taken to Converge: ~p milliseconds\n", [End_Time - Start_Time]).

checkAliveClients(Clients) ->
    Alive_Clients = [{C, C_PID} || {C, C_PID} <- Clients, is_process_alive(C_PID) == true],
    if
        Alive_Clients == [] ->
            io:format("\nCONVERGED: ");
        true ->
            checkAliveClients(Alive_Clients)
    end.

createClients(Count, NumClients, MaxSubcribers, Main_Table) ->    
    UserName = Count,
    NumTweets = round(floor(MaxSubcribers/Count)),
    NumSubscribe = round(floor(MaxSubcribers/(NumClients-Count+1))) - 1,

    PID = spawn(client, test, [UserName, NumTweets, NumSubscribe, false]),

    ets:insert(Main_Table, {UserName, PID}),
    if 
        Count == NumClients ->
            ok;
        true ->
            createClients(Count+1, NumClients, MaxSubcribers, Main_Table)
    end.


