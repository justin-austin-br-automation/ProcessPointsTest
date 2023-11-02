ACTION ActWorkStation4:
	
	CASE WorkStation4.Step OF
		WAIT:
			WorkStation4.RoutedMoveAbs.Execute := FALSE;
			
			IF WorkStation4.TrgEnable.EventCount > 0 THEN
				WorkStation4.TrgGetInfo.Execute := TRUE;
				WorkStation4.Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF WorkStation4.TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				WorkStation4.Shuttle := WorkStation4.TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT DO
					IF WorkStation4.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_STATION_4;
					END_IF
				END_FOR
				
				WorkStation4.TrgGetInfo.Execute := FALSE;
				WorkStation4.Step := PROCESS;
			ELSE
				WorkStation4.TrgGetInfo.Execute := FALSE;
				WorkStation4.Step := WAIT;
			END_IF
			
		PROCESS:
			WorkStation4.Timer.PT := T#2s;
			WorkStation4.Timer.IN := TRUE;
			
			IF WorkStation4.Timer.Q THEN
				WorkStation4.Timer.IN := FALSE;
				WorkStation4.Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			WorkStation4.RoutedMoveAbs.Axis := ADR(WorkStation4.Shuttle);
			WorkStation4.RoutedMoveAbs.Sector := ADR(Barrier);
			WorkStation4.RoutedMoveAbs.Position := 0.2;
			WorkStation4.RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			WorkStation4.RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			WorkStation4.RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			WorkStation4.RoutedMoveAbs.Jerk := 0.0;
			WorkStation4.RoutedMoveAbs.BufferMode := mcABORTING;
			WorkStation4.RoutedMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT DO
				IF WorkStation4.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_BUFFER;
				END_IF
			END_FOR
			
			WorkStation4.ReadyForShuttle := TRUE;
			WorkStation4.Step := WAIT;
		
	END_CASE
	
	WorkStation4.TrgEnable();
	WorkStation4.TrgGetInfo();
	WorkStation4.RoutedMoveAbs();
	WorkStation4.Timer();
END_ACTION