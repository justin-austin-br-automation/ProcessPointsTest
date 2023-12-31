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
		RoutedMoveAbs : MC_BR_RoutedMoveAbs_AcpTrak;
		State : ShuttleStateEnum := RTE_TO_BUFFER;
	END_STRUCT;
	ProcessPointLocations : 	STRUCT 
		THROUGHPUT : REAL;
		BUFFER : REAL;
		WORK_ZONE : REAL;
		WORK_ZONE_TRG_POINT : REAL;
		WORK_STATION1 : REAL;
		WORK_STATION2 : REAL;
		WORK_STATION3 : REAL;
		WORK_STATION4 : REAL;
		MAINTENANCE_POINT : REAL;
	END_STRUCT;
END_TYPE

(*Enumerations*)

TYPE
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
	ProcessPointStateEnum : 
		(
		WAIT,
		DO_NOTHING,
		DIRECTION_CHECK,
		PROCESS,
		SEND_SHUTTLE
		);
END_TYPE
