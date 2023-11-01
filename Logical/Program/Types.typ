
TYPE
	ProcessPointsFubsType : 	STRUCT 
		Command : MC_BR_BarrierCommand_AcpTrak;
		BarrierReadInfo : MC_BR_BarrierReadInfo_AcpTrak;
		GetShuttle : MC_BR_BarrierGetShuttle_AcpTrak;
		ElasticMoveAbs : MC_BR_ElasticMoveAbs_AcpTrak;
		RoutedMoveVel : MC_BR_RoutedMoveVel_AcpTrak;
		RoutedMoveAbs : MC_BR_RoutedMoveAbs_AcpTrak;
		TrgEnable : MC_BR_TrgPointEnable_AcpTrak;
		TrgGetInfo : MC_BR_TrgPointGetInfo_AcpTrak;
		Timer : TON := (PT:=T#2s);
		Step : ProcessPointStateEnum;
		Shuttle : McAxisType;
		ReadyForShuttle : BOOL := TRUE;
	END_STRUCT;
	ProcessPointStateEnum : 
		(
		WAIT,
		DIRECTION_CHECK,
		PROCESS,
		SEND_SHUTTLE
		);
END_TYPE
