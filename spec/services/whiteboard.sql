SELECT comp.name, prod_proj.project_id AS project_id, prod.id AS product_id, prod.name AS product_name, proj_jira.jira_project_key, proj_jira.fix_version_name
FROM products_projects prod_proj, project_jira_configs proj_jira, products prod, customers cust, companies comp
WHERE prod_proj.project_id = proj_jira.project_id
AND prod_proj.product_id = prod.id
AND prod.customer_id = cust.id
AND cust.company_id = comp.id
ORDER BY comp.name, proj_jira.jira_project_key
