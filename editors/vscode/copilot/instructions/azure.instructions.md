---
applyTo: '**'
---
# Copilot Custom Instructions — Azure

> Scope: Disse reglene gjelder **kun når samtalen handler om Azure**. Ikke kall Azure-spesifikke verktøy ellers.

- @azure Rule – Use Azure Tools
  When handling requests related to **Azure**, always use your Azure tools.

- @azure Rule – Use Azure Code Gen Best Practices
  When generating code for Azure, running terminal commands for Azure, or performing operations related to Azure, invoke your `bestpractices` tool **if available**.
  Only call this tool when you are sure the user is discussing Azure; do not call it otherwise.

- @azure Rule – Use Azure Deployment Best Practices
  When deploying to Azure or preparing applications for deployment to Azure, invoke your `bestpractices` tool **if available**.
  Only call this tool when you are sure the user is discussing Azure; do not call it otherwise.

- @azure Rule – Use Azure Functions Code Gen Best Practices
  When generating code for **Azure Functions** or performing operations related to Azure Functions, invoke your `bestpractices` tool **if available**.
  Only call this tool when you are sure the user is discussing **Azure Functions**; do not call it otherwise.

- @azure Rule – Use Azure Functions Deployment Best Practices
  When deploying **Azure Functions** apps to Azure or preparing for the deployment, invoke your `bestpractices` tool **if available**.
  Only call this tool when you are sure the user is discussing **Azure Functions**; do not call it otherwise.

- @azure Rule – Use Azure SWA Best Practices
  When working with **Azure Static Web Apps (SWA)**, invoke your `bestpractices` tool **if available**.
  Only call this tool when you are sure the user is discussing **Azure SWA**; do not call it otherwise.

- @azure Rule – Plan before editing files for Azure web apps
  When generating code for Azure Functions and Azure Static Web App, **first create a plan and explain the plan to the user** before editing any file.
  Proceed with editing only **after** obtaining the user’s consent.

- @azure Rule – Summarize topic before taking action
  When the user asks for something about Azure, **summarize the topic first** and invoke the `azure_development-summarize_topic` tool **once** to discover potential recommended configurations.