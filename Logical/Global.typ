(*Structures*)

TYPE
	TrakAssemblyControlType : 	STRUCT 
		Command : TrakAssemblyCommandType;
		Parameter : TrakAssemblyParameterType;
		Status : TrakAssemblyStatusType;
		ShuttleCnt : UINT;
	END_STRUCT;
	TrakAssemblyCommandType : 	STRUCT 
		Power : BOOL;
		StartMovement : BOOL;
		StopMovement : BOOL;
		Reset : BOOL;
	END_STRUCT;
	TrakAssemblyParameterType : 	STRUCT 
		Velocity : REAL := 2.0;
		Acceleration : REAL := 20.0;
		Deceleration : REAL := 20.0;
	END_STRUCT;
	TrakAssemblyStatusType : 	STRUCT 
		Disabled : BOOL;
		Ready : BOOL;
		Homing : BOOL;
		Stopping : BOOL;
		ErrorStop : BOOL;
	END_STRUCT;
	ShuttleControlType : 	STRUCT 
		Axis : McAxisType;
		RoutedMoveVel : MC_BR_RoutedMoveVel_AcpTrak;
		State : ShuttleStateEnum := RTE_TO_BUFFER;
	END_STRUCT;
END_TYPE

(*Enumerations*)

TYPE
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
	ShuttleStateEnum : 
		(
		RTE_TO_BUFFER := 10,
		AT_BUFFER := 15,
		RTE_TO_STATION_1 := 20,
		AT_STATION_1 := 25,
		RTE_TO_STATION_2 := 30,
		AT_STATION_2 := 35,
		RTE_TO_STATION_3 := 40,
		AT_STATION_3 := 45,
		RTE_TO_STATION_4 := 50,
		AT_STATION_4 := 55,
		RTE_TO_MAINT := 60,
		AT_MAINT := 65
		);
END_TYPE
