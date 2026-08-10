# PORTFOLIO ON-PREM SQL SERVER
Example of an DWH setup limited to only on-prem Microsoft SQL Server using Transact-SQL

## Pipeline
```mermaid
---
config:
  securityLevel: 'loose'
---
flowchart TD
    subgraph Docker["<i class='fab fa-docker'></i> Docker"]
        subgraph Container_SQL_Server_AdventureWorks["<i class="fa-solid fa-server"></i> SQL Server - AdventureWorks"]
            sourcetables["<i class='fa-solid fa-table'></i> Source Tables"]
        end
        subgraph Container_SQL_Server_OnPrem["<i class="fa-solid fa-server"></i> SQL Server - DWH_OnPrem"]
            stagingtables["<i class='fa-solid fa-table'></i> Staging TABLES"]
            intviews["<i class='fa-regular fa-eye'></i> Intermediate VIEWS"]
            dimensions["<i class='fa-solid fa-table'></i> Slow-Changing Dimension TABLES"]
            facts["<i class='fa-solid fa-table'></i> Denormalised Fact TABLES"]
        end
    end

    %% Main flows per table
    sourcetables--SSIS--> stagingtables
    stagingtables--> intviews
    intviews--Stored Procedures--> dimensions
    intviews--Stored Procedures--> facts
    dimensions--Stored Procedures-->facts
