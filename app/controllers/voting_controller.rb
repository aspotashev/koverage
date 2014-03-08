class VotingController < ApplicationController
  def index
  end

  def my
    @modules = I18nModule.order(:name).all
    @packages = I18nPackage.order(:name).all
    @files = I18nFile.order(:name).all

    @current_module = @modules.first
    @current_package = @current_module.i18n_packages.first
    @current_file = @current_package.i18n_files.first
  end

  def full_tree
    respond_to do |format|
      votes_tree = I18nModule.order(:name).map(&:to_votes_tree)
      format.json { render :json => votes_tree }
    end
  end
end
