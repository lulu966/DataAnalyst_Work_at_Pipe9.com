/****** Object: StoredProcedure [dbo].[Perspective_date] Script Date: 6/6/2023 9:36:46 AM ******/

-- Set ANSI_NULLS ON to ensure NULL values are treated according to ANSI standard.
SET ANSI_NULLS ON
GO
-- Set QUOTED_IDENTIFIER ON to enable quoted identifiers for object names.
SET QUOTED_IDENTIFIER ON
GO

-- The procedure definition starts here. It takes a parameter @PoeId with a default value '1'.
ALTER PROCEDURE [dbo].[Perspective_date]  
(
    @PoeId VARCHAR(100) = '1'
)
AS
BEGIN

-- Create a temporary table @POE to store PoeID values.
DECLARE @POE TABLE
(
    PoeID INT
)

-- Split the input @PoeId string and insert values into the @POE table.
INSERT INTO @POE 
SELECT [value] FROM string_split(@PoeId, ',')

-- The main SELECT query starts here, retrieving specific columns from multiple tables.

SELECT DISTINCT 
    T.ManagerFirstName, T.ManagerLastName, T.ManagerEmailId, T.TeamFirstName, T.TeamLastName, T.TeamEmailId,
    UH.UserId,
    UH.PoeId,
    UH.[Rating] as [Importance],
    UH.QuestionId,
    UH.[created_on] as [Importance_CreatedOn],
    PRH.[Answer] as [frequency],
    PRH.[CreatedOn] as [Frequency_CreatedOn],
    PRH.UpdatedOn as [Frequency_UpdatedOn],
    PCH.Answer as [Proficiency],
    PCH.CreatedOn as [Proficiency_CreatedOn],
    PCH.UpdatedOn as [Proficiency_UpdatedOn]

-- Joins between multiple tables to retrieve data.
FROM
    [ReportUsers]	RU
    JOIN UserRating_History UH ON UH.Userid = RU.Id
    JOIN POEResults_History PRH ON UH.QuestionId = PRH.QuestionId AND UH.FeedbackId = PRH.FeedbackId
    JOIN POECapabilityResults_History PCH ON PRH.QuestionId = PCH.QuestionId AND UH.FeedbackId = PCH.POEFeedbackId
    LEFT JOIN tblRpt_DataDump_Main T ON T.TeamUserId = RU.Id AND PRH.QuestionId = T.QuestionId

-- Filtering conditions for the data to be retrieved.
WHERE 
    RU.[Active] = 1 
    AND UH.PoeId IN (SELECT PoeId FROM @poe) 
    AND T.TeamUserId IS NOT NULL
    AND (RU.EmailId NOT LIKE '%@pipe9%' 
         AND RU.EmailId != 'v-bilgr@microsoft.com' 
         AND RU.EmailId NOT LIKE '%@skillmenew.onmicrosoft.com%') 

-- The procedure definition ends here.
END
