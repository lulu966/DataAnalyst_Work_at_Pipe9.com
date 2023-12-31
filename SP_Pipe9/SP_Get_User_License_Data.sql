/****** Object: StoredProcedure [dbo].[reportsforlicense] Script Date: 6/6/2023 9:44:15 AM ******/

-- Set ANSI_NULLS ON to ensure NULL values are treated according to ANSI standard.
SET ANSI_NULLS ON
GO
-- Set QUOTED_IDENTIFIER ON to enable quoted identifiers for object names.
SET QUOTED_IDENTIFIER ON
GO

-- This section modifies the existing stored procedure named 'reportsforlicense'.
-- It retrieves specific data from the database and performs transformations.

ALTER procedure [dbo].[reportsforlicense] as
-- The procedure starts here, defining its behavior.

-- Select specific columns from the tables with aliases 'm' and 'POEMapping'.
select distinct
    m.ManagerEmailId, -- Manager's email ID
    m.TeamEmailId, -- Team's email ID
    m.poeid, -- ID of the POE (Presumably some sort of identifier)
    m.PoeName, -- Name of the POE
    m.ManagerFirstName, -- Manager's first name
    m.ManagerLastName, -- Manager's last name
    m.TeamFirstName, -- Team's first name
    m.TeamLastName, -- Team's last name
    CASE 
        WHEN M.[TenureGroup] BETWEEN 1 AND 12 THEN '1 - 12'
        WHEN M.[TenureGroup] BETWEEN 13 AND 24 THEN '13 - 24'
        WHEN M.[TenureGroup] > 25 THEN '25+'
    END AS [Tenure], -- Categorize TenureGroup into tenure ranges
    M.[Country], -- Country
    M.[Area], -- Area
    [POEMapping].[CreatedOn], -- Creation timestamp of POEMapping
    [POEMapping].[UpdatedOn], -- Last update timestamp of POEMapping
    m.ManagerUserId, -- Manager's user ID
    m.TeamUserId, -- Team's user ID
    M.[TenureGroup] -- Tenure group
from tblRpt_DataDump_Main m
inner join (
    -- Subquery to select maximum 'UpdatedOn' and 'CreatedOn' timestamps for each UserId in POEMapping
    select [UserId], max(UpdatedOn) as UpdatedOn, max(CreatedOn) as CreatedOn
    from POEMapping
    group by UserId
) POEMapping on POEMapping.UserId = m.TeamUserId
where (
    -- Filter conditions
    (M.ManagerEmailId NOT LIKE '%@pipe9%' AND M.ManagerEmailId != 'v-bilgr@microsoft.com'
    and M.ManagerEmailId not like '%@skillmenew.onmicrosoft.com%')
    AND (M.TeamEmailId != 'v-bilgr@microsoft.com'and M.TeamEmailId not like '%@skillmenew.onmicrosoft.com%')
)
