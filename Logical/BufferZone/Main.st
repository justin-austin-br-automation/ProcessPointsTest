PROGRAM _INIT
	TrgGetInfo.ProcessPoint := ADR(PPBuffer);
	TrgEnable.ProcessPoint := ADR(PPBuffer);
	TrgEnable.Enable := TRUE;
	
	TrgEnable();
	TrgGetInfo();
END_PROGRAM

PROGRAM _CYCLIC
	CASE Step OF
		WAIT:
			RoutedMoveAbs.Execute := FALSE;
			
			ShuttlesToStation1 := 0;
			FOR i := 1 TO gMAX_SHUTTLE_CNT DO
				IF gShuttleList[i].State = RTE_TO_STATION_1 THEN
					ShuttlesToStation1 := ShuttlesToStation1 + 1;
				END_IF
			END_FOR
			
			IF TrgEnable.EventCount > 0 AND ShuttlesToStation1 < gMAX_SHUTTLES_TO_STATION_1 THEN
				 TrgGetInfo.Execute := TRUE;
				 Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				Shuttle :=  TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT DO
					IF  Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_BUFFER;
					END_IF
				END_FOR
				
				TrgGetInfo.Execute := FALSE;
				Step := SEND_SHUTTLE;
			ELSE
				TrgGetInfo.Execute := FALSE;
				Step := WAIT;
			END_IF
			
		SEND_SHUTTLE:
			RoutedMoveAbs.Axis := ADR( Shuttle);
			RoutedMoveAbs.Sector := ADR(SectorWorkZone);
			RoutedMoveAbs.Position := 0.0;
			RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			RoutedMoveAbs.Jerk := 0.0;
			RoutedMoveAbs.BufferMode := mcABORTING;
			RoutedMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT DO
				IF  Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_STATION_1;
				END_IF
			END_FOR
			
			Step := WAIT;
		
	END_CASE
	
	RoutedMoveAbs();
	TrgEnable();
	TrgGetInfo();
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	
END_PROGRAM