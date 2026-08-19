![Microsoft SQL Server](https://img.shields.io/badge/Microsoft%20SQL%20Server-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![SSIS](https://img.shields.io/badge/SSIS-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Docker 4.84](https://img.shields.io/badge/Docker-v4.84-2496ED?style=for-the-badge&logo=docker&logoColor=white)

# PORTFOLIO ON-PREM SQL SERVER
Example of an DWH setup limited to only on-prem Microsoft SQL Server using Transact-SQL

## 📝Notes and Limitations
- MERGE statements purposefully avoided for known SQL bugs that still exist in SQL Server 2025 with merge operations. Instead applied seperate update and insert statements.


## 📚Layered Modelling
- **'STG'** (Staging tables): raw, untransformed, source data, loaded via SSIS
- **'INT'** (Intermediate views): conform staged data to business terminology, applies logic, compute hashes, only reads from STG
- **'MRT'** (Mart Tables): business-ready Dimension ('DIM_') and Fact ('Fact_') tables, ready for consumption downstream by systems such as Power BI / Looker / DBT / etc.

## 📘Dimensions
Modelled using the appropriate level of tracking required, e.g. **type1, type2, and mixed/hybrid**, based on the judged meaningfullness at the time of writing.

## 🔄️Change detection
Managed via hashing (**SHA2-256*") within the Intermediate ('INT') views. Includes locale-stable (UK) conversions of data types.

## 🗝️Key design
- Source-system IDs and keys aliased to 'NK' and retained
- Surrogate keys referenced as 'SK' and used to identify specific versions of an entity
- Dimension joins utilise 'SK' for time-sensitive joins to ensure appropriate dimension attributes are returned for the correct point-in-time for each fact
- Dimensions contain a **'fallback entity'** (SK of -1) to facilitate outer-join safety and inner-join simplicity

## ⚡Loading and stored procedures: 
Wrapped in try/catch with transaction rollback. Divided into multiple stages where necessary:
- Mark and close out out-of-date records
- Insert new/updated record versions
- Update pre-existing records
- Use of merge avoided due to known issues in SQL Server 2025
- Above multi-stage methodology used to simplify debugging

## #️⃣Indexing
- Dimensions contain nonclustered indexes to support time-based and time-agnostic joins
- Fact tables contain nonclustered indexes on surrogate keys to support downstream joins by engineers/analysts
- Fact tables contain nonclustered columnstore indexes not strictly required for small tables, but to show knowledge



# Pipeline
```mermaid
---
config:
  securityLevel: 'loose'
---
flowchart TD
    subgraph Docker["🐋Docker"]
        subgraph Container_SQL_Server_AdventureWorks["🗄️SQL Server - AdventureWorks"]
            sourcetables["<i class='fa-solid fa-table'></i> Source Tables"]
        end
        subgraph Container_SQL_Server_OnPrem["🗄️SQL Server - DWH_OnPrem"]
            stagingtables["📦Staging TABLES"]
            intviews["👁️Intermediate VIEWS"]
            slowdimensions["📦🕑Slow-Changing Dimension SCD Type2 TABLES"]
            normdimensions["📦Slow-Changing Dimension SCD Type 1 TABLES"]
            facts["📦📊Denormalised Fact TABLES"]
        end
    end

    %% Main flows per table
    sourcetables--SSIS--> stagingtables
    stagingtables--> intviews
    intviews--⚡Stored Procedures--> slowdimensions
    intviews--⚡Stored Procedures--> normdimensions
    intviews--⚡Stored Procedures--> facts
    slowdimensions--⚡Stored Procedures-->facts
    normdimensions--⚡Stored Procedures-->facts
