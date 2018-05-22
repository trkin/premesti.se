module TranslateHelper
  # there are two ways of calling this helper:
  # t_crud 'are_you_sure_to_remove_item', item: @move
  # t_crud 'edit', User
  def t_crud(action, model_class)
    if model_class.class == Hash
      t(action, item: t("neo4j.models.#{model_class[:item].name.downcase}.accusative"))
    else
      t(action, item: t("neo4j.models.#{model_class.name.downcase}.accusative"))
    end
  end
end
