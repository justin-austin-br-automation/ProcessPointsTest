ACTION ActWorkZone:
	
	CASE WorkZone.Step OF
		WAIT:
			WorkZone.Command.Command := mcACPTRAK_BARRIER_CLOSE;
			WorkZone.Command.Execute := TRUE;
			
			IF WorkZone.TrgEnable.EventCount <> 0 AND WorkStation1.ReadyForShuttle THEN
				WorkZone.Command.Execute := FALSE;
				WorkZone.TrgGetInfo.Execute := TRUE;
				WorkZone.Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF WorkZone.TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				WorkZone.Shuttle := WorkZone.TrgGetInfo.TrgPointInfo.Axis;
				WorkZone.TrgGetInfo.Execute := FALSE;
				WorkZone.Step := PROCESS;
			ELSE
				WorkZone.TrgGetInfo.Execute := FALSE;
				WorkZone.Step := WAIT;
			END_IF
			
		PROCESS:
			IF WorkStation1.TrgEnable.EventCount = 0 THEN
				WorkZone.Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			WorkZone.RoutedMoveAbs.Axis := ADR(WorkZone.Shuttle);
			WorkZone.RoutedMoveAbs.Sector := ADR(ProcessPoints);
			WorkZone.RoutedMoveAbs.Position := 0.495;
			WorkZone.RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			WorkZone.RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			WorkZone.RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			WorkZone.RoutedMoveAbs.Jerk := 0.0;
			WorkZone.RoutedMoveAbs.BufferMode := mcABORTING;
			WorkZone.RoutedMoveAbs.Execute := TRUE;
			
			WorkZone.Command.Command := mcACPTRAK_BARRIER_ADD_TICKETS;
			WorkZone.Command.AdvancedParameters.TicketCount := 1;
			WorkZone.Command.Execute := TRUE;
			
			IF WorkZone.Command.Done THEN
				WorkStation1.ReadyForShuttle := FALSE;
				WorkZone.Command.Execute := FALSE;
				WorkZone.RoutedMoveAbs.Execute := FALSE;
				WorkZone.Step := WAIT;
			END_IF
		
	END_CASE
	
	WorkZone.Command();
	WorkZone.RoutedMoveAbs();
	WorkZone.TrgEnable();
	WorkZone.TrgGetInfo();
END_ACTION