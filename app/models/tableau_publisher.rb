class TableauPublisher

  attr_accessor :current_user

  def initialize(user)
    @current_user = user
  end

  def publish_workbook(dataset, workspace, params)
    workbook = build_workbook(dataset, params[:tableau_workbook][:name],
                                   params[:tableau_workbook][:tableau_username],
                                   params[:tableau_workbook][:tableau_password])

    workfile = create_workfile(params, workspace)

    if (!workfile || workfile.validate_name_uniqueness) && workbook.save
      publication = create_publication(dataset, params)
      if workfile
        workfile.tableau_workbook_publication = publication
        workfile.save!
      end
      publication
    else
      handle_errors(workbook, workfile)
    end
  end

  private


  def handle_errors(workbook, workfile)
    messages = workbook.errors.full_messages
    messages = messages + workfile.errors.full_messages if workfile
    raise ModelNotCreated.new(messages.join(". "))
  end

  def create_publication(dataset, params)
    TableauWorkbookPublication.create!(
        :name => params[:tableau_workbook][:name],
        :dataset_id => dataset.id,
        :workspace_id => params[:workspace_id],
        :project_name => "Default"
    )
  end

  def create_workfile(params, workspace)
    if params[:tableau_workbook][:create_work_file] == "true"
      workfile = LinkedTableauWorkfile.new(file_name: "#{params[:tableau_workbook][:name]}.twb")
      workfile.owner = current_user
      workfile.workspace = workspace
    else
      workfile = nil
    end
    workfile
  end

  def build_workbook(dataset, workbook_name, username, password)
    login_params = {
        :name => workbook_name,
        :server => ChorusConfig.instance['tableau.url'],
        :port => ChorusConfig.instance['tableau.port'],
        :tableau_username => username,
        :tableau_password => password,
        :db_username => dataset.data_source.account_for_user!(current_user).db_username,
        :db_password => dataset.data_source.account_for_user!(current_user).db_password,
        :db_host => dataset.data_source.host,
        :db_port => dataset.data_source.port,
        :db_database => dataset.schema.database.name,
        :db_schema => dataset.schema.name}

    if dataset.is_a?(ChorusView)
      TableauWorkbook.new(login_params.merge!(:query => dataset.query))
    else
      TableauWorkbook.new(login_params.merge!(:db_relname => dataset.name))
    end
  end
end