![Microsoft SQL Server](https://img.shields.io/badge/Microsoft%20SQL%20Server-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![SSIS](https://img.shields.io/badge/SSIS-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Docker 4.84](https://img.shields.io/badge/Docker-v4.84-2496ED?style=for-the-badge&logo=docker&logoColor=white)

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
            slowdimensions["<i class='fa-solid fa-table'></i> Slow-Changing Dimension SCD Type2 TABLES"]
            normdimensions["<i class='fa-solid fa-table'></i> Slow-Changing Dimension SCD Type 1 TABLES"]
            facts["<i class='fa-solid fa-table'></i> Denormalised Fact TABLES"]
        end
    end

    %% Main flows per table
    sourcetables--SSIS--> stagingtables
    stagingtables--> intviews
    intviews--Stored Procedures--> slowdimensions
    intviews--Stored Procedures--> normdimensions
    intviews--Stored Procedures--> facts
    slowdimensions--Stored Procedures-->facts
    normdimensions--Stored Procedures-->facts
