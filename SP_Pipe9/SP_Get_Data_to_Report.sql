﻿/****** Object: StoredProcedure [dbo].[USP_GetReportdata] Script Date: 6/5/2023 5:13:44 AM ******/

-- Set ANSI_NULLS and QUOTED_IDENTIFIER options
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Alter the stored procedure named USP_GetReportdata
ALTER PROCEDURE [dbo].[USP_GetReportdata]
(
  @PoeId VARCHAR(100) = '1'
)
AS
BEGIN
  -- Create a table variable named @POE
  DECLARE @POE TABLE
  (
    PoeID INT
  )
  
  -- Insert values into the @POE table variable by splitting the input @PoeId
  INSERT INTO @POE 
  SELECT [value] FROM string_split(@PoeId, ',')
  
  -- Retrieve data for the final report
  SELECT 
    -- Columns from tblRpt_DataDump_Main table
    M.[PoeName],
    M.[Rating],
    M.[Capabaility],
    M.[Frequency],
    M.[%MgrFrequency],
    M.[POEModuleId],
    M.[ModuleOrder],
    M.[ModuleName],
    M.[QuestionId],
    M.[Question],
    M.[ManagerExpertCount],
    M.[TeamExpertCount],
    M.[ManagerExpert],
    M.teammemberupdatedon,
    M.teammembercreatedon,
    M.[TeamExpert],
    M.[ManagerLearningMaterialCount],
    M.[TeamLearningMaterialCount],
    M.[ManagerResources],
    M.[TeamResources],
    M.[ManagerTaskCount],
    M.[TeamTaskCount],
    M.[ManagerTask],
    M.[TeamTask],
    M.[ManagerTaskComplete],
    M.[TeamTaskComplete],
    M.[ManagerMappingId],
    M.[TeamMappingId],
    M.[ManagerUserId],
    M.[TeamUserId],
    M.[ManagerFirstName],
    M.[ManagerLastName],
    M.[ManagerEmailId],
    M.[TeamFirstName],
    M.[TeamLastName],
    M.[TeamEmailId],
    M.[Country],
    M.[Area],
    M.[TenureGroup],
    
    -- Columns from tblRpt_SelfDatadump table
    T.FeedbackCompletion AS [SelfFeedbackCompletion],
    T.[Mentor],
    T.[ManagerPriority],
    T.[TeamsPriority],
    T.[SafeZone],
    T.[TeamLastLogin] AS [Team Login],
    T.[TeamLastLoginDate] AS [Team Login Date],
    M.[ManagerRegisteredDate],
    T.[UserRegisteredDate],
    M.Active,
    
    -- Calculated column for FeedbackCompletion using a LEFT JOIN
    COALESCE(FB.[FeedbackCompletion], 'Unknown') AS [FeedbackCompletion],
    
    -- Convert and calculate columns for ManagerCompletion using a LEFT JOIN
    COALESCE(CONVERT(INT, FB.[FeedbackCompletionMGRtoTM]), 0) AS [FeedbackCompletionMGRtoTM],
    COALESCE(CONVERT(INT, MC.[ManagerCompletion]), 0) AS [ManagerCompletion]
    
  FROM tblRpt_DataDump_Main M
  
  -- Joining tblRpt_DataDump_Main and tblRpt_SelfDatadump tables
  INNER JOIN tblRpt_SelfDatadump T ON M.PoeId = T.POEId
    AND M.TeamEmailId = T.TeamEmailId
    AND M.QuestionId = T.QuestionId
    AND M.POEModuleId = T.POEModuleId
    AND M.ModuleOrder = T.ModuleOrder
    
  -- Joining with @POE table variable
  INNER JOIN @POE P ON P.PoeID = M.PoeId
  
  -- Left join with subqueries to calculate FeedbackCompletion and ManagerCompletion
  LEFT JOIN (
    -- Subquery to calculate FeedbackCompletion based on TeamEmailId
    SELECT
      TeamEmailId,
      CASE
        WHEN MAX(Rating) = 0 OR MAX(Capabaility) = 0 OR MAX(Frequency) = 0 THEN '0'
        WHEN COUNT(*) = COUNT(CASE WHEN Rating >= 2 AND Capabaility >= 2 AND Frequency >= 2 THEN 1 END) THEN '2'
        WHEN COUNT(*) > COUNT(CASE WHEN Rating >= 2 AND Capabaility >= 2 AND Frequency >= 2 THEN 1 END) THEN '1'
        ELSE 'Unknown'
      END AS [FeedbackCompletion]
    FROM tblRpt_DataDump_Main
    GROUP BY TeamEmailId
  ) AS FB ON M.TeamEmailId = FB.TeamEmailId
  
  LEFT JOIN (
    -- Subquery to calculate ManagerCompletion based on ManagerEmailId
    SELECT
      ManagerEmailId,
      CASE
        WHEN MAX(Rating) = 0 OR MAX(Capabaility) = 0 OR MAX(Frequency) = 0 THEN '0'
        WHEN COUNT(*) = COUNT(CASE WHEN Rating >= 2 AND Capabaility >= 2 AND Frequency >= 2 THEN 1 END) THEN '2'
        WHEN COUNT(*) > COUNT(CASE WHEN Rating >= 2 AND Capabaility >= 2 AND Frequency >= 2 THEN 1 END) THEN '1'
        ELSE 'Unknown'
      END AS [ManagerCompletion]
    FROM tblRpt_DataDump_Main
    GROUP BY ManagerEmailId
  ) AS MC ON M.ManagerEmailId = MC.ManagerEmailId
  
  -- Filtering conditions
  WHERE M.ManagerEmailId NOT LIKE '%@pipe9%'
    AND M.ManagerEmailId != 'v-bilgr@microsoft.com'
    AND M.Active = 1;
  
END
