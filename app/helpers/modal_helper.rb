# rubocop:disable Metrics/MethodLength
module ModalHelper
  def modal(id:, title:, fade: true)
    %(
      <div id="#{id}" class="modal #{fade ? 'fade' : ''}" role="dialog" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal">&times;</button>
              <h4 class="modal-title">#{title || 'Create'}</h4>
            </div>
            <div class="modal-body">
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-default pull-left" data-dismiss="modal">#{t('close')}</button>
            </div>
          </div>
        </div>
      </div>
    ).html_safe
  end

  def render_modal_partial(partial_name, title:)
    %(
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title">#{title || 'Create'}</h4>
      </div>
      #{render partial_name}
    ).html_safe
  end
end
