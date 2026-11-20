# 🏭 Quality Inspection Management System (SAP BTP ABAP Cloud & RAP)

![SAP BTP](https://img.shields.io/badge/SAP_BTP-ABAP_Cloud-008FD3?style=for-the-badge&logo=sap)
![RAP](https://img.shields.io/badge/Architecture-Managed_RAP-2B6CB0?style=for-the-badge)
![OData V4](https://img.shields.io/badge/Protocol-OData_V4-38A169?style=for-the-badge)
![Fiori Elements](https://img.shields.io/badge/UI-Fiori_Elements-D69E2E?style=for-the-badge)
![Clean Core](https://img.shields.io/badge/Standard-Clean_Core_Compliant-4A5568?style=for-the-badge)

An end-to-end, enterprise-grade **Quality Inspection Management** application built on **SAP BTP ABAP Environment (ABAP Cloud)** using the **ABAP RESTful Application Programming Model (RAP)** and **SAP Fiori Elements (OData V4)**. 

This project demonstrates modern Clean Core development principles, stateful draft handling, instance-level security, automated business determinations, and isolated ABAP Unit testing.

---

## 🎯 Business Scenario & Core Capabilities

Manufacturing plants require a standardized digital workflow to inspect production batches, log defect severities, calculate real-time risk scores, and enforce strict approval/rejection governance.

* **Composite Data Model (Header – Item):** Parent-child relationship managing inspection orders (`ZR_INSP_HEADER_06`) and individual defect items (`ZR_INSP_ITEMS_06`) with full **Draft** support.
* **Automated Risk Calculation (`Determination`):** Dynamically aggregates item defect severities (`1–5` scale) into a normalized `TotalRiskScore` (`0–100`) on header creation and item modification.
* **Parameterized Actions with Popups:** Custom `ApproveBatch` and `RejectBatch` actions utilizing an **Abstract Entity** parameter popup to capture mandatory rejection reasons.
* **Dynamic UI Control (`get_instance_features`):** Automatically disables edit, delete, and approval buttons once a batch reaches a final state (`Approved` or `Rejected`).
* **Data Integrity (`Validations`):** Enforces business rules at save time—blocking invalid plant codes, out-of-range severities, and critical defects (`Severity = 5`) lacking detailed comments.
* **Instance-Level Authorization (`get_instance_authorizations`):** Secures update, delete, and status-change operations using a custom Authorization Object (`ZAO_INSP06`) checked against the user's `Plant` (`ZAF_PLANT`) and `ACTVT` permissions.
* **Fiori Elements UX & Side Effects:** Real-time UI updates via BDEF `side effects`, color-coded criticality badges (`StatusCriticality`), header KPI datapoints, and progress bar visualization.

---

## 🏗️ Technical Architecture

```text
+-------------------------------------------------------------------+
|                     SAP Fiori Elements (OData V4)                 |
|             List Report & Object Page (ZUI_INSP_O4_06)            |
+---------------------------------+---------------------------------+
                                  |
+---------------------------------v---------------------------------+
|                  Service Definition & Projection                  |
|      ZUI_INSP_INSP_O4_06  --->  ZC_INSP_HEADER_06 / ZC_INSP_ITEMS |
|      Metadata Extensions  --->  ZME_INSP_HEADER_06 / ZME_INSP_ITEM|
+---------------------------------+---------------------------------+
                                  |
+---------------------------------v---------------------------------+
|                   Managed RAP Business Object                     |
|   Behavior Definition: ZR_INSP_HEADER_06 (Draft Enabled)          |
|   Behavior Pool:       ZBP_R_INSP_HEADER_06                       |
|   ├── Determinations:  setInitialStatus, calculateTotalRisk       |
|   ├── Validations:     validatePlant, validateSeverityComment     |
|   ├── Actions:         ApproveBatch, RejectBatch (Abstract Param) |
|   ├── Feature Control: get_instance_features                      |
|   └── Authorization:   get_instance_authorizations (ZAO_INSP06)   |
+---------------------------------+---------------------------------+
                                  |
+---------------------------------v---------------------------------+
|                  Persistence & Draft Database                     |
|   Active Tables: zinsp_header_06, zinsp_items_06                  |
|   Draft Tables:  zinsp_header_d,  zinsp_items_06_d                |
+-------------------------------------------------------------------+
