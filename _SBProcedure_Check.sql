drop PROCEDURE _SBProcedure_Check;

DELIMITER $$
CREATE PROCEDURE _SBProcedure_Check
	(
		 InData_OperateFlag			CHAR(2)			-- 작업표시
		,InData_CompanySeq			INT				-- 법인내부코드
        ,InData_ProcedureName		VARCHAR(200)	-- (기존)프로시져명
		,InData_ChgProcedureName	VARCHAR(200)    -- (변경)프로시져명
		,InData_ProcedureRemark		VARCHAR(200)	-- 프로시져설명
		,InData_ProcedureType		INT				-- 프로시져타입
		,InData_Remark				VARCHAR(500)	-- 작업내용
		,Login_UserSeq				INT				-- 현재 로그인 중인 유저
        ,OUT RETURN_OUT INT							-- IsCheck 결과 내보내기
    )
Error_Out:BEGIN -- Error_Out : 오류가 발생했을 경우 프로시져 종료

	-- 오류 관리 변수---------------------------------------
	DECLARE CompanySeq 			INT;
	DECLARE IsCheck 			INT;
    DECLARE Result  			VARCHAR(500);
	-- -------------------------------------------------
    
    -- 변수선언 --    
    DECLARE Var_ProcedureSeq 	INT;    
    
	-- 변수설정 --
	SET Var_ProcedureSeq = (SELECT A.ProcedureSeq FROM _TCBaseProcedure AS A WHERE A.CompanySeq = InData_CompanySeq AND ProcedureName = InData_ProcedureName);
	
    
	-- 오류 관리 테이블---------------------------------------
	CREATE TEMPORARY TABLE IsCheck_TEMP
    (CompanySeq INT, IsCheck INT, Result VARCHAR(500));
	INSERT INTO IsCheck_TEMP VALUES(InData_CompanySeq, 1111, '');    
	-- -------------------------------------------------	
	
    -- OperateFlag의 값이 'S', 'U', 'D' 외의 값이 들어갈 경우 에러발생------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
				FROM _TCBaseProcedure 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON InData_OperateFlag <> 'S'
                RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_2  ON InData_OperateFlag <> 'U'
                RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_3  ON InData_OperateFlag <> 'D'
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '[ (S) : 저장 , (U) : 업데이트 , (D) : 삭제 ] 외의 명령을 입력할 수 없습니다.';
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  



 	-- InData_CompanySeq, InData_ProcedureName, InData_ProcedureRemark, InData_ProcedureType 를 필수로 입력하지 않을 경우 에러발생 ------------------------------------------------
     IF ((SELECT IFNULL(A.ERR, 1111)          AS ProcedureSeq 
				FROM (SELECT 9999 AS ERR) 	  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON (
																	   (InData_CompanySeq		   = 0) 
																	OR (InData_ProcedureType       = 0)
                                                                    OR (InData_ProcedureName 	   = '')
																    OR (InData_ProcedureRemark 	   = '')
																 )   
															  AND (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U')
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE    
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '법인내부코드, 프로시저명, 프로시저설명, 프로시저타입 은 필수값 입니다.'
	   WHERE (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);      
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF; -- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;   



    -- InData_CompanySeq의 값이 _TSBaseCompany.CompanySeq의 데이터에 존재하는 값이 없을 경우 에러발생 ------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.CompanySeq, 1111)  	AS CompanySeq 
				FROM _TSBaseCompany 		  	AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON  (InData_CompanySeq  <>    	A.CompanySeq ) 
															  AND (InData_OperateFlag LIKE      'S'			 )
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '등록된 법인 정보가 아닙니다. 법인등록을 해주세요.'
	   WHERE (InData_OperateFlag LIKE 'S');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  
    
    

	-- 저장 시 신규 프로시져의 명이 기존 프로시져 명과 이름이 동일한 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
				FROM _TCBaseProcedure 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.ProcedureName    LIKE InData_ProcedureName
															 AND InData_OperateFlag LIKE 'S' 
		limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '동일한 프로시저 명이 존재합니다.'
	   WHERE (InData_OperateFlag LIKE 'S');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;
      


	-- Update할 경우 InData_ChgProcedureName 데이터가 같은 _TCBaseProcedure.ProcedureSeq 기준으로  _TCBaseProcedure.ProcedureName과 중복되거나 빈값일 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT A.ProcedureSeq FROM _TCBaseProcedure AS A WHERE A.CompanySeq = InData_CompanySeq AND A.ProcedureName = InData_ChgProcedureName) = (SELECT Var_ProcedureSeq)) -- 기존 ProcedureName이 업데이트되면 정상처리
    THEN    
 	   SET CompanySeq = InData_CompanySeq;   
    ELSE 
		IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
					FROM _TCBaseProcedure 		  AS A 
					RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
																 AND (
																			A.ProcedureName    		=    InData_ChgProcedureName
																		OR  InData_ChgProcedureName LIKE ''
																	 )
                                                                 AND A.MajorSeq			= 	 Var_MajorSeq
																 AND (InData_OperateFlag LIKE 'U') 
			limit 1
		     ) = (SELECT 1111)) 
		THEN
		   -- TRUE
		   SET CompanySeq = InData_CompanySeq;
		    
		ELSE
		   -- FALES
		   UPDATE IsCheck_TEMP AS A
		   SET  A.IsCheck = 9999
			   ,A.Result  = 'Update 경우 ChgProcedureName은 빈값 또는 이미 존재하는 ProcedureName값을 입력할 수 없습니다.'
		   WHERE (InData_OperateFlag LIKE 'U') ;
		   -- 체크종료 구문--------------------------------------------------------------------------
		   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
		   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
		   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
		   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
		   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
		   LEAVE Error_Out; -- 프로시져 종료
		   -- ------------------------------------------------------------------------------------
		END IF;
    END IF;
    
    
      
    -- 업데이트와 삭제 시 데이터가 없을 경우 에러발생 ------------------------------------------------------------------------------------------------  
    IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
				FROM _TCBaseProcedure 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq     =    InData_CompanySeq
															 AND A.ProcedureName  =    InData_ProcedureName
															 AND (InData_OperateFlag LIKE 'U' OR InData_OperateFlag LIKE 'D')
		 limit 1
         ) = (SELECT Var_ProcedureSeq))  -- 데이터가 존재하다면 수정하려는 Seq가 같은지 여부 확인
	THEN

	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
       
	ELSEIF InData_OperateFlag = 'S' -- Save일 경우 해당 체크가 영향 안받도록 추가
	THEN
		-- TRUE
	   SET CompanySeq = InData_CompanySeq;	
       
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '데이터가 존재하지 않습니다.'
	   WHERE (InData_OperateFlag LIKE 'U' OR InData_OperateFlag LIKE 'D');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;    
      
          
     
          
	-- Update 및 Delete할 경우 CheckOutUser와 수정하는 Login_UserSeq와 다르면 에러발생 (체크인 되어있을 경우 에러발생) ------------------------------------------------
     IF ((SELECT IFNULL(A.CheckOutUserSeq, 1111)  AS CheckOutUserSeq 
				FROM _TCBaseProcedure 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq        =     InData_CompanySeq
															 AND A.ProcedureName     =     InData_ProcedureName
                                                             AND A.CheckOutUserSeq   =     Login_UserSeq
                                                             AND A.IsCheckOut		 =     1 
															 AND (InData_OperateFlag LIKE 'U' OR InData_OperateFlag LIKE 'D')
		 limit 1
         ) = (SELECT Login_UserSeq)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '체크인 되어있는 프로시져입니다. 수정할 수 없습니다.'
	   WHERE (InData_OperateFlag LIKE 'U' OR InData_OperateFlag LIKE 'D');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF; -- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;   
    

    
	DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
END $$
DELIMITER ;