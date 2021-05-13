drop PROCEDURE _SBProcedure_Query;

DELIMITER $$
CREATE PROCEDURE _SBProcedure_Query
	(
		 InData_CompanySeq			INT				-- 법인내부코드
		,InData_ProcedureName		VARCHAR(200)	-- 프로시져명
		,InData_ProcedureRemark		VARCHAR(200)	-- 프로시져설명
		,InData_ProcedureType		INT				-- 프로시져타입
		,InData_Remark				VARCHAR(500)	-- 작업내용
		,Login_UserSeq				INT				-- 현재 로그인 중인 유저
    )
BEGIN    

	DECLARE Var_ProcedureType 	VARCHAR(100);

	IF (InData_ProcedureName 	IS NULL OR InData_ProcedureName 	LIKE ''	) THEN	SET InData_ProcedureName 	= '%'; END IF;
    IF (InData_ProcedureRemark 	IS NULL OR InData_ProcedureRemark 	LIKE ''	) THEN	SET InData_ProcedureRemark 	= '%'; END IF;
	IF (InData_ProcedureType 	IS NULL OR InData_ProcedureType 	= 	 0	) THEN	SET Var_ProcedureType 	    = '%'; END IF; -- InData_ProcedureType의 속성값은 Int이기에 Var_ProcedureType의 속성값 변수로 적용
    IF (InData_Remark 			IS NULL OR InData_Remark 			LIKE ''	) THEN	SET InData_Remark 			= '%'; END IF;
    
    -- ---------------------------------------------------------------------------------------------------
    -- Query --

    set session transaction isolation level read uncommitted;     
    -- 최종조회 --
    SELECT 
		 CompanySeq
		,ProcedureSeq
		,ProcedureName
		,ProcedureRemark
		,ProcedureType
		,IsCheckOut
		,Remark
		,CheckOutUserSeq
		,CheckOutStartDate
		,CheckOutEndDate
	FROM _TCBaseProcedure AS A
    WHERE A.CompanySeq    			=    InData_CompanySeq
      AND A.ProcedureName 			like InData_ProcedureName
      AND A.ProcedureRemark  		like InData_ProcedureRemark
	  AND A.ProcedureType 			like (CASE 
										      WHEN Var_ProcedureType <> '%' THEN InData_ProcedureType
											  ELSE Var_ProcedureType
										  END) 
	  AND A.Remark 					like InData_Remark;

	set session transaction isolation level repeatable read;
    
END $$
DELIMITER ;