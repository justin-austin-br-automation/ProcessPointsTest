PROGRAM _INIT
	TrgGetInfo.ProcessPoint := ADR(PPStation0TrgPoint);
	TrgEnable.ProcessPoint := ADR(PPStation0TrgPoint);
	TrgEnable.Enable := TRUE;
	Command.ProcessPoint := ADR(PPStation0);
	Command.Command := mcACPTRAK_BARRIER_CLOSE;
	Command.Execute := TRUE;
	
	TrgGetInfo();
	TrgEnable();
	Command();
END_PROGRAM

PROGRAM _CYCLIC
	CASE Step OF
		WAIT:
			Command.Command := mcACPTRAK_BARRIER_CLOSE;
			Command.Execute := TRUE;
			
			IF TrgEnable.EventCount > 0 AND gStation1ReadyForShuttle THEN
				Command.Execute := FALSE;
				TrgGetInfo.Execute := TRUE;
				Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				Shuttle := TrgGetInfo.TrgPointInfo.Axis;
				TrgGetInfo.Execute := FALSE;
				Step := PROCESS;
			ELSE
				TrgGetInfo.Execute := FALSE;
				Step := WAIT;
			END_IF
			
		PROCESS:
			IF gStation1EventCount = 0 THEN
				Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			RoutedMoveAbs.Axis := ADR(Shuttle);
			RoutedMoveAbs.Sector := ADR(SectorWorkZone);
			RoutedMoveAbs.Position := gPROCESS_POINT_LOCATIONS.WORK_STATION1;
			RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			RoutedMoveAbs.Jerk := 0.0;
			RoutedMoveAbs.BufferMode := mcABORTING;
			RoutedMoveAbs.Execute := TRUE;
			
			Command.Command := mcACPTRAK_BARRIER_ADD_TICKETS;
			Command.AdvancedParameters.TicketCount := 1;
			Command.Execute := TRUE;
			
			IF Command.Done THEN
				gStation1ReadyForShuttle := FALSE;
				Command.Execute := FALSE;
				RoutedMoveAbs.Execute := FALSE;
				Step := WAIT;
			END_IF
		
	END_CASE
	
	Command();
	RoutedMoveAbs();
	TrgEnable();
	TrgGetInfo();
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	
END_PROGRAM