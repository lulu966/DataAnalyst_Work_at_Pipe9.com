/****** Object: StoredProcedure [dbo].[USP_GetReportdata] Script Date: 6/5/2023 5:13:44 AM ******/

-- Set ANSI_NULLS ON to ensure NULL values are treated according to ANSI standard.
SET ANSI_NULLS ON
GO
-- Set QUOTED_IDENTIFIER ON to enable quoted identifiers for object names.
SET QUOTED_IDENTIFIER ON
GO

-- The procedure definition starts here. It takes a parameter @PoeId with a default value '1'.
ALTER PROCEDURE [dbo].[USP_GetReportdata]
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

-- The main SELECT query starts here, retrieving various columns from the database tables.

SELECT 
    M.[PoeName],
    -- ... (other selected columns)

    -- Perform mapping of Rating, Capability, and Frequency values to percentage strings.
    CASE WHEN M.[Rating] = 1 THEN '25%' 
         WHEN M.[Rating] = 2 THEN '50%' 
         WHEN M.[Rating] = 3 THEN '75%' 
         WHEN M.[Rating] = 4 THEN '100%' 
         ELSE '0%' 
    END AS [%MgrImportance],
    -- ... (other similar mapping columns)

    -- Apply logic to calculate ManagerImpact based on Rating, Capability, and Frequency values.
    -- Similar logic is applied to calculate SelfImpact based on SelfRating, SelfCapability, and SelfFrequency values.

    -- Join with other tables and left join with subqueries to get additional information.
    FROM tblRpt_DataDump_Main M 
    INNER JOIN tblRpt_SelfDatadump T 
        ON M.PoeId = T.POEId 
        AND M.TeamEmailId = T.TeamEmailId 
        AND M.QuestionId = T.QuestionId 
        AND M.POEModuleId = T.POEModuleId 
        AND M.ModuleOrder = T.ModuleOrder
    INNER JOIN @POE P  
        ON P.PoeID = M.PoeId

    -- Left join with subqueries to calculate FeedbackCompletion values.
    LEFT JOIN (
        -- Subquery to calculate FeedbackCompletionMGRtoTM based on certain conditions.
    ) AS FB ON M.TeamEmailId = FB.TeamEmailId

    LEFT JOIN (
        -- Subquery to calculate FeedbackCompletionMGR based on certain conditions.
    ) AS MC ON M.ManagerEmailId = MC.ManagerEmailId

    LEFT JOIN (
        -- Subquery to calculate FeedbackCompletionTMtoTM based on certain conditions.
    ) AS SB ON T.TeamEmailId = SB.TeamEmailId

    -- Apply filtering conditions to the data.
    WHERE (
        -- Filtering conditions on ManagerEmailId and TeamEmailId
    )
    AND M.Active = 1

-- The procedure definition ends here.
END
