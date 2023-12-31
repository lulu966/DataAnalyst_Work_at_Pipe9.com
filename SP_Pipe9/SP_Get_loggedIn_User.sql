/****** Object: StoredProcedure [dbo].[pipe9insights] Script Date: 6/6/2023 9:37:29 AM ******/

-- Set ANSI_NULLS ON to ensure NULL values are treated according to ANSI standard.
SET ANSI_NULLS ON
GO
-- Set QUOTED_IDENTIFIER ON to enable quoted identifiers for object names.
SET QUOTED_IDENTIFIER ON
GO

-- This section modifies the existing stored procedure named 'pipe9insights'.
ALTER procedure [dbo].[pipe9insights] as 

-- The procedure starts here, defining its behavior.

-- Select specific columns from the 'LoggedInUsersTracking' table and join them with 'ReportUsers' table.
select 
    l.*, -- All columns from LoggedInUsersTracking table
    r.FirstName, -- First name from ReportUsers table
    r.LastName, -- Last name from ReportUsers table
    r.EmailID, -- Email ID from ReportUsers table
    r.CompanyName, -- Company name from ReportUsers table
    -- Categorize 'Tenure' column into different tenure ranges.
    CASE 
        WHEN l.[Tenure] BETWEEN 0 AND 12 THEN '0 - 12' 
        WHEN l.[Tenure] BETWEEN 13 AND 24 THEN '13 - 24' 
        WHEN l.[Tenure] > 25 THEN '25+' 
    END AS [Tenure Group] 
-- Perform a left outer join between 'LoggedInUsersTracking' and 'ReportUsers' using UserId and Id columns.
from LoggedInUsersTracking l 
left outer join ReportUsers r
on l.UserId = r.Id
-- Filter conditions for the data to be retrieved.
where  PoeName <> 'CSAM - Old' 
and r.EmailID like '%@microsoft.com%'

-- The procedure definition ends here.
