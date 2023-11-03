PROGRAM _INIT
	TrgGetInfo.ProcessPoint := ADR(PPThroughput);
	TrgEnable.ProcessPoint := ADR(PPThroughput);
	TrgEnable.Enable := TRUE;
	
	TrgGetInfo();
	TrgEnable();
END_PROGRAM

PROGRAM _CYCLIC
	IF gThroughputTimer.Q THEN
		gThroughputTimer.IN := FALSE;
		gCurrentThroughput := ThroughputCounter;
		ThroughputCounter := 0;
	ELSIF NOT gThroughputTimer.IN THEN
		gThroughputTimer.IN := TRUE;
	END_IF
	
	CASE Step OF
		WAIT:
			RoutedMoveAbs.Execute := FALSE;
			Timer.PT := MAINTENANCE_TIMER_LENGTH;
			Timer.IN := TRUE;
			
			IF Timer.Q AND TrgEnable.EventCount > 0 THEN
				Timer.IN := FALSE;
				TrgGetInfo.Execute := TRUE;
				Step := DIRECTION_CHECK;
			ELSIF NOT Timer.Q AND TrgEnable.EventCount > 0 THEN
				TrgGetInfo.Execute := TRUE;
				Step := DO_NOTHING;
			END_IF
			
		DO_NOTHING:
			IF TrgGetInfo.Done THEN
				TrgGetInfo.Execute := FALSE;
				ThroughputCounter := ThroughputCounter + 1;
				Step := WAIT;
			END_IF
			
		DIRECTION_CHECK:
			Shuttle := TrgGetInfo.TrgPointInfo.Axis;
			TrgGetInfo.Execute := FALSE;
			ThroughputCounter := ThroughputCounter + 1;
			Step := SEND_SHUTTLE;
			
		SEND_SHUTTLE:
			RoutedMoveAbs.Axis := ADR(Shuttle);
			RoutedMoveAbs.Sector := ADR(SectorMaintenancePoint);
			RoutedMoveAbs.Position := 0.34;
			RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			RoutedMoveAbs.Jerk := 0.0;
			RoutedMoveAbs.BufferMode := mcABORTING;
			RoutedMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT DO
				IF Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_MAINT;
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