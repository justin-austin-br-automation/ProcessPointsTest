
TYPE
	TrakAssemblyControlType : 	STRUCT 
		Command : TrakAssemblyCommandType;
		Parameter : TrakAssemblyParameterType;
		Status : TrakAssemblyStatusType;
	END_STRUCT;
	TrakAssemblyCommandType : 	STRUCT 
		PowerOn : BOOL;
		StartMovement : BOOL;
		StopMovement : BOOL;
		PowerOff : BOOL;
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
