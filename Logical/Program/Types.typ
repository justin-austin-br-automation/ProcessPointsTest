
TYPE
	ShuttleControlType : 	STRUCT 
		ShuttleReference : McAxisType;
		RoutedMoveVel : MC_BR_RoutedMoveVel_AcpTrak;
		ElasticMoveVel : MC_BR_ElasticMoveVel_AcpTrak;
	END_STRUCT;
	ProcessPointsFubsType : 	STRUCT 
		Command : MC_BR_BarrierCommand_AcpTrak;
		ReadInfo : MC_BR_BarrierReadInfo_AcpTrak;
		GetShuttle : MC_BR_BarrierGetShuttle_AcpTrak;
		ElasticMoveVel : MC_BR_ElasticMoveVel_AcpTrak;
		RoutedMoveVel : MC_BR_RoutedMoveVel_AcpTrak;
		Timer : TON := (PT:=T#2s);
		Step : ProcessPointStateEnum;
	END_STRUCT;
	ProcessPointStateEnum : 
		(
		WAIT,
		PROCESS
		);
END_TYPE
