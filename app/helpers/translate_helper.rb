module TranslateHelper
  def t_crud(action, model_class)
    if model_class.class == Hash
      t(action, item: t("neo4j.models.#{model_class[:item].name.downcase}.accusative"))
    else
      "#{t(action)} #{t("neo4j.models.#{model_class.name.downcase}.accusative")}"
    end
  end
end
