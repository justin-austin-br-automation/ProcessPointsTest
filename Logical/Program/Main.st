PROGRAM _INIT
	(* Initializing function blocks and their inputs *)
	AsmPowerOn.Assembly := ADR(gAssembly_1);
	AsmPowerOff.Assembly := ADR(gAssembly_1);
	AsmGetShuttle.Assembly := ADR(gAssembly_1);
	AsmStop.Assembly := ADR(gAssembly_1);
	AsmStop.StopMode := mcSTOPMODE_JERK_LIMIT;
	AsmReadStatus.Assembly := ADR(gAssembly_1);
	AsmReadStatus.Enable := TRUE;
	
	(* Initializing parameters for shuttle movements *)
	gTrakAsm.Parameter := SHUTTLE_PARAMETERS;
END_PROGRAM

PROGRAM _CYCLIC
	IF gTrakAsm.Status.ErrorStop THEN
		Step := ERROR;
	END_IF
	
	CASE Step OF
		
		POWER_OFF:
			
		WAIT_POWER_OFF:
			
		POWERED_OFF:
			
		POWER_ON:
			
		WAIT_POWER_ON:
			
		GET_SHUTTLE:
			
		READY:
			
		START_MOVEMENT:
			
		WAIT_START_MOVEMENT:
			
		MOVING:
			
		STOPPING:
			
		WAIT_STOPPING:
			
		ERROR:
			
		RESET:
			
	END_CASE

	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	
END_PROGRAM