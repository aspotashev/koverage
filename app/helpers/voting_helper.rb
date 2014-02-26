module VotingHelper
  def parent_i18n_object_type(type)
    case type
    when :file
      :package
    when :package
      :module
    end
  end
end
