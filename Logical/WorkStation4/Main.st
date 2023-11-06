PROGRAM _INIT
	TrgGetInfo.ProcessPoint := ADR(PPStation4);
	TrgEnable.ProcessPoint := ADR(PPStation4);
	TrgEnable.Enable := TRUE;
	
	TrgGetInfo();
	TrgEnable();
END_PROGRAM

PROGRAM _CYCLIC
	CASE Step OF
		WAIT:
			RoutedMoveAbs.Execute := FALSE;
			
			IF TrgEnable.EventCount > 0 THEN
				TrgGetInfo.Execute := TRUE;
				Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				Shuttle := TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT DO
					IF Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_STATION_4;
						ShuttleIndex := i;
					END_IF
				END_FOR
				
				TrgGetInfo.Execute := FALSE;
				Step := PROCESS;
			ELSE
				TrgGetInfo.Execute := FALSE;
				Step := WAIT;
			END_IF
			
		PROCESS:
			Timer.PT := gPROCESS_TIMER_LENGTH;
			Timer.IN := TRUE;
			
			IF Timer.Q THEN
				Timer.IN := FALSE;
				Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			RoutedMoveAbs.Axis := ADR(Shuttle);
			RoutedMoveAbs.Sector := ADR(SectorBuffer);
			RoutedMoveAbs.Position := gPROCESS_POINT_LOCATIONS.BUFFER;
			RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			RoutedMoveAbs.Jerk := 0.0;
			RoutedMoveAbs.BufferMode := mcABORTING;
			RoutedMoveAbs.Execute := TRUE;
			
			gShuttleList[ShuttleIndex].State := RTE_TO_BUFFER;
			
			gStation4ReadyForShuttle := TRUE;
			Step := WAIT;
		
	END_CASE
	
	RoutedMoveAbs();
	TrgEnable();
	TrgGetInfo();
	RoutedMoveAbs();
	Timer();
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	
END_PROGRAM