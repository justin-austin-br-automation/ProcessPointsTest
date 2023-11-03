PROGRAM _INIT
	TrgGetInfo.ProcessPoint := ADR(PPMaintenancePoint);
	TrgEnable.ProcessPoint := ADR(PPMaintenancePoint);
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
						gShuttleList[i].State := AT_MAINT;
					END_IF
				END_FOR
				
				TrgGetInfo.Execute := FALSE;
				Step := PROCESS;
			ELSE
				TrgGetInfo.Execute := FALSE;
				Step := WAIT;
			END_IF
			
		PROCESS:
			Timer.PT := T#5s;
			Timer.IN := TRUE;
			
			IF Timer.Q THEN
				Timer.IN := FALSE;
				Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			RoutedMoveAbs.Axis := ADR(Shuttle);
			RoutedMoveAbs.Sector := ADR(SectorBuffer);
			RoutedMoveAbs.Position := 0.2;
			RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			RoutedMoveAbs.Jerk := 0.0;
			RoutedMoveAbs.BufferMode := mcABORTING;
			RoutedMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT DO
				IF Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_BUFFER;
				END_IF
			END_FOR
			
			Step := WAIT;
		
	END_CASE
	
	RoutedMoveAbs();
	TrgEnable();
	TrgGetInfo();
	Timer();
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	
END_PROGRAM