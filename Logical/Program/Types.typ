
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
	StateMachineEnum : 
		(
		POWER_OFF := 10,
		WAIT_POWER_OFF := 20,
		POWERED_OFF := 30,
		POWER_ON := 40,
		WAIT_POWER_ON := 50,
		GET_SHUTTLE := 60,
		READY := 70,
		START_MOVEMENT := 80,
		WAIT_START_MOVEMENT := 90,
		MOVING := 100,
		STOPPING := 110,
		WAIT_STOPPING := 120,
		ERROR := 500,
		RESET := 510
		);
END_TYPE
