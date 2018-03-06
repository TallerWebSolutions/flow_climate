namespace :seed do
  desc 'Seed the database'

  task create_stages: :environment do

    project_flow_climate = Project.find(58)
    Stage.create(projects: [project_flow_climate], integration_id: '2609574', name: 'Financial Demands', stage_type: :backlog, stage_stream: :downstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: [project_flow_climate], integration_id: '2457321', name: 'Backlog', stage_type: :backlog, stage_stream: :downstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: [project_flow_climate], integration_id: '2457324', name: 'Ready to Dev', stage_type: :development, stage_stream: :downstream, commitment_point: true, end_point: false, queue: true)
    Stage.create(projects: [project_flow_climate], integration_id: '2457325', name: 'Developing', compute_effort: true, percentage_effort: 1, stage_type: :development, stage_stream: :downstream, commitment_point: false, end_point: false, queue: false)
    Stage.create(projects: [project_flow_climate], integration_id: '2457337', name: 'Ready to HMG', stage_type: :homologation, stage_stream: :downstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: [project_flow_climate], integration_id: '2457379', name: 'Homologating', stage_type: :homologation, stage_stream: :downstream, commitment_point: false, end_point: false, queue: false)
    Stage.create(projects: [project_flow_climate], integration_id: '2457387', name: 'Ready to Deploy', stage_type: :ready_to_deploy, stage_stream: :downstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: [project_flow_climate], integration_id: '2457326', name: 'Live', stage_type: :delivered, stage_stream: :downstream, commitment_point: false, end_point: true, queue: true)
    Stage.create(projects: [project_flow_climate], integration_id: '2457327', name: 'Arquivado', stage_type: :delivered, stage_stream: :downstream, commitment_point: false, end_point: false, queue: true)

    # stages for Vingadores
    vingadores = Team.first
    Stage.create(projects: vingadores.projects, integration_id: '2761956', name: 'Backlog', stage_type: :design, stage_stream: :upstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480504', name: 'Ready to Research', stage_type: :design, stage_stream: :upstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480505', name: 'Researching', stage_type: :design, stage_stream: :upstream, commitment_point: false, end_point: false, queue: false, compute_effort: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480511', name: 'Ready to Design', stage_type: :design, stage_stream: :upstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480512', name: 'In Design', stage_type: :design, stage_stream: :upstream, commitment_point: false, end_point: false, queue: false, compute_effort: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480513', name: 'Ready to Acceptation', stage_type: :design, stage_stream: :upstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480514', name: 'Accepting', stage_type: :design, stage_stream: :upstream, commitment_point: false, end_point: false, queue: false)
    Stage.create(projects: vingadores.projects, integration_id: '2748244', name: 'Approved', stage_type: :design, stage_stream: :upstream, commitment_point: false, end_point: true, queue: false)
    Stage.create(projects: vingadores.projects, integration_id: '2486321', name: 'Gray Area', stage_type: :analysis, stage_stream: :upstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480515', name: 'Ready to Analysis', stage_type: :analysis, stage_stream: :upstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480516', name: 'In Analysis', stage_type: :analysis, stage_stream: :upstream, commitment_point: false, end_point: false, queue: false)
    Stage.create(projects: vingadores.projects, integration_id: '2480517', name: 'Options Invetory', stage_type: :analysis, stage_stream: :upstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480518', name: 'Ready to Dev', stage_type: :development, stage_stream: :downstream, commitment_point: true, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480519', name: 'Developing', stage_type: :development, stage_stream: :downstream, commitment_point: false, end_point: false, queue: false, compute_effort: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480520', name: 'Ready to HMG', stage_type: :homologation, stage_stream: :downstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480521', name: 'Homologating', stage_type: :homologation, stage_stream: :downstream, commitment_point: false, end_point: false, queue: false)
    Stage.create(projects: vingadores.projects, integration_id: '2480522', name: 'Ready to Deploy', stage_type: :ready_to_deploy, stage_stream: :downstream, commitment_point: false, end_point: false, queue: true)
    Stage.create(projects: vingadores.projects, integration_id: '2480524', name: 'Live', stage_type: :delivered, stage_stream: :downstream, commitment_point: false, end_point: true, queue: false)
    Stage.create(projects: vingadores.projects, integration_id: '2697997', name: 'Arquivado', stage_type: :delivered, stage_stream: :downstream, commitment_point: false, end_point: false, queue: false)
  end
end
