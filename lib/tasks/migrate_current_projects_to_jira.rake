# frozen_string_literal: true

namespace :project_migration do
  desc 'Notifications for the user'
  task migrate_current_projects_to_jira: :environment do
    #### Vingadores

    ### Projetos

    ## NSC
    Jira::ProjectJiraConfig.create(project: Project.find(59), team: Project.find(59).current_team, jira_account_domain: 'tallerflow', jira_project_key: '10001')

    ## NxCF
    Jira::ProjectJiraConfig.create(project: Project.find(60), team: Project.find(60).current_team, jira_account_domain: 'tallerflow', jira_project_key: '10002')

    ## ADF
    Jira::ProjectJiraConfig.create(project: Project.find(68), team: Project.find(68).current_team, jira_account_domain: 'tallerflow', jira_project_key: '')

    # UNICEF
    Jira::ProjectJiraConfig.create(project: Project.find(117), team: Project.find(68).current_team, jira_account_domain: 'tallerflow', jira_project_key: '10006')

    # COBNET
    Jira::ProjectJiraConfig.create(project: Project.find(36), team: Project.find(36).current_team, jira_account_domain: 'tallerflow', jira_project_key: '10004')

    ## Stages
    Stage.find(12).update(integration_id: '10012')
    Stage.find(14).update(integration_id: '10014')
    Stage.find(15).update(integration_id: '10015')
    Stage.find(17).update(integration_id: '10009')
    Stage.find(19).update(integration_id: '10008')
    Stage.find(20).update(integration_id: '10001')
    Stage.find(13).update(integration_id: '10013')
    Stage.find(18).update(integration_id: '10010')
    Stage.find(22).update(integration_id: '10005')
    Stage.find(23).update(integration_id: '10007')
    Stage.find(24).update(integration_id: '10006')
    Stage.find(25).update(integration_id: '10002')
    Stage.find(26).update(integration_id: '10017')
    Stage.find(27).update(integration_id: '10011')
    Stage.find(21).update(integration_id: '10003')
    Stage.find(40).update(integration_id: '10000')

    ## Flow Climate

    Jira::ProjectJiraConfig.create(project: Project.find(108), team: Project.find(108).current_team, jira_account_domain: 'tallerflow', jira_project_key: 'FC', fix_version_name: 'Fase 3')

    # Stages
    Stage.find(3).update(integration_id: '10012')
    Stage.find(8).update(integration_id: '10002')
    Stage.find(9).update(integration_id: '10017')
    Stage.find(5).update(integration_id: '10005')
    Stage.find(6).update(integration_id: '10007')
    Stage.find(7).update(integration_id: '10006')
    Stage.find(4).update(integration_id: '10003')
    Stage.find(1).update(integration_id: '10008')
  end
end
