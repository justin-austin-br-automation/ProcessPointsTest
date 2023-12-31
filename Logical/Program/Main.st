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
			IF gTrakAsm.Status.Disabled THEN
				AsmPowerOff.Execute := FALSE;
				Step := POWERED_OFF;
			END_IF
			
		WAIT_POWER_OFF:
			
		POWERED_OFF:
			IF gTrakAsm.Command.Power AND gTrakAsm.Status.Disabled THEN
				AsmPowerOn.Execute := TRUE;
				Step := POWER_ON;
			END_IF
			
		POWER_ON:
			IF AsmPowerOn.Done AND gTrakAsm.Status.Ready THEN
				AsmPowerOn.Execute := FALSE;
				FOR i := 1 TO gMAX_SHUTTLE_CNT DO
					brsmemset(ADR(gShuttleList[i].Axis), 0, SIZEOF(gShuttleList[i].Axis));
				END_FOR
				CurrentShuttleNumber := 1;
				Step := GET_SHUTTLE;
			END_IF
			
		WAIT_POWER_ON:
			
		GET_SHUTTLE:
			AsmGetShuttle.Enable := TRUE;

			IF AsmGetShuttle.Valid THEN
				(* There are no shuttles on the assembly. *)
				IF AsmGetShuttle.TotalCount = 0 THEN
					gTrakAsm.ShuttleCnt := 0;
					AsmGetShuttle.Enable := FALSE;
					AsmGetShuttle.Next := FALSE;

					Step := READY;
                (* As soon as the next shuttle has been output by the function block, RemainingCount
                   is reduced and this condition becomes true. *)
				ELSIF (AsmGetShuttle.RemainingCount <> (AsmGetShuttle.TotalCount - CurrentShuttleNumber)) THEN
					CurrentShuttleNumber := CurrentShuttleNumber + 1;
					AsmGetShuttle.Next := FALSE;
				ELSE
					(* Store all axis references in an array for global movement commands. *)
					gShuttleList[CurrentShuttleNumber].Axis := AsmGetShuttle.Axis;
					(* Get next shuttle reference with positive edge on .Next. *)
					AsmGetShuttle.Next := TRUE;
                
					(* All shuttles have been stored. *)
					IF (AsmGetShuttle.RemainingCount = 0) THEN
						gTrakAsm.ShuttleCnt := AsmGetShuttle.TotalCount;
						AsmGetShuttle.Enable := FALSE;
						AsmGetShuttle.Next := FALSE;
                        
						Step := READY;
					END_IF
				END_IF
			END_IF
			
		READY:
			IF NOT gTrakAsm.Command.Power THEN
				AsmPowerOff.Execute := TRUE;
				Step := POWER_OFF;
			ELSIF gTrakAsm.Command.StartMovement AND gTrakAsm.ShuttleCnt > 0 THEN
				gTrakAsm.Command.StartMovement := FALSE;
				Step := START_MOVEMENT;
			END_IF
			
		START_MOVEMENT:
			FOR CurrentShuttleNumber := 1 TO gTrakAsm.ShuttleCnt DO
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Axis := ADR(gShuttleList[CurrentShuttleNumber].Axis);
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Sector := ADR(SectorBuffer);
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Position := gPROCESS_POINT_LOCATIONS.BUFFER;
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Jerk := 0.0;
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.BufferMode := mcABORTING;
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Execute := TRUE;
			END_FOR
			
			Step := WAIT_START_MOVEMENT;
			
		WAIT_START_MOVEMENT:
			FOR CurrentShuttleNumber := 1 TO gTrakAsm.ShuttleCnt DO
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Execute := FALSE;
			END_FOR
			
			gThroughputTimer.IN := TRUE;
			gThroughputTimer.PT := gTHROUGHPUT_TIMER_LENGTH;
			
			Step := MOVING;
			
		MOVING:
			IF gTrakAsm.Command.StopMovement THEN
				gTrakAsm.Command.StopMovement := FALSE;
				Step := STOPPING;
			END_IF
			
		STOPPING:
			FOR CurrentShuttleNumber := 1 TO gMAX_SHUTTLE_CNT DO
				gShuttleList[CurrentShuttleNumber].RoutedMoveAbs.Execute := FALSE;
			END_FOR
			AsmStop.Execute := TRUE;
			
			IF AsmStop.Done THEN
				AsmStop.Execute := FALSE;
				Step := READY;
			END_IF
			
		WAIT_STOPPING:
			
		ERROR:
			
		RESET:
			
	END_CASE
	
	(* Read assembly status cyclically to assembly interface. *)
	gTrakAsm.Status.Disabled := AsmReadStatus.AssemblyDisabled;
	gTrakAsm.Status.Ready := AsmReadStatus.AssemblyReady;
	gTrakAsm.Status.Homing := AsmReadStatus.AssemblyHoming;
	gTrakAsm.Status.Stopping := AsmReadStatus.AssemblyStopping;
	gTrakAsm.Status.ErrorStop := AsmReadStatus.AssemblyErrorStop;
	
	(* Calling function blocks *)
	AsmPowerOn();
	AsmPowerOff();
	AsmGetShuttle();
	AsmStop();
	AsmReadStatus();
	FOR i := 1 TO gMAX_SHUTTLE_CNT DO
		IF gShuttleList[i].Axis.controlif <> 0 THEN
			gShuttleList[i].RoutedMoveAbs();
		END_IF
	END_FOR
	gThroughputTimer();
	
	gCurrentThroughput;
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	
END_PROGRAM