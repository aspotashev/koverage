class VotingController < ApplicationController
  def index
  end

  def my
    @modules = I18nModule.order(:name).all
    @packages = I18nPackage.order(:name).all
    @files = I18nFile.order(:name).all

    # TBD: store current module/package/file indices in the tree in JS, not IDs
    @current_module = @modules.first
    @current_package = @current_module.i18n_packages.first
    @current_file = @current_package.i18n_files.first
  end

  def full_tree
    respond_to do |format|
      votes_tree = I18nModule.order(:name).map(&:to_votes_tree)
      my_votes = Hash[current_user.i18n_file_votes.map {|v| [v.i18n_file_id, v.choice] }]
      format.json do
        render json: {
          tree: votes_tree,
          my_votes: my_votes
        }
      end
    end
  end

  def set_vote
    id = params[:id]

    file_ids = case params[:type]
    when 'module'
      I18nModule.find(id).i18n_packages.map {|package| package.i18n_files.map(&:id) }.flatten
    when 'package'
      I18nPackage.find(id).i18n_files.map(&:id)
    when 'file'
      [id]
    end

    p file_ids

    # Parameters: {"type"=>"package", "id"=>"308", "choice"=>"green"}

    respond_to do |format|
      format.json do
        user_votes = current_user.i18n_file_votes
        file_ids.each do |id|
          # TBD: move this conversion to client side (JavaScript)
          names_to_codes = {
            'none'   => 0,
            'green'  => 1,
            'yellow' => 2,
            'pink'   => 3,
            'gray'   => 4,
          }
          choice = params[:choice]
          if names_to_codes.has_key?(choice)
            code = names_to_codes[choice]

            v = user_votes.where(:i18n_file_id => id).first
            if v.nil?
              I18nFileVote.create(:user_id => current_user.id, :i18n_file_id => id, :choice => code)
            else
              v.update_column(:choice, code)
            end
          else
            raise "Unknown vote choice"
          end
        end

        render json: :ok
      end
    end

  end

  def file_voters
    @file = I18nFile.find(params[:id])
    @votes = I18nFileVote.where(:i18n_file_id => params[:id]).where.not(:choice => 0)
    render :layout => false
  end
end
