module ModalHelper
  def modal(id:, title:, fade: true, modal_dialog_class: '')
    %(
      <div id="#{id}" class="modal #{fade ? 'fade' : ''}" role="dialog" tabindex="-1">
        <div class="modal-dialog modal-lg #{modal_dialog_class}">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">#{title || 'Create'}</h5>
              <button type="button" class="close" data-dismiss="modal" aria-label="Close">&times;</button>
            </div>
            <div class="modal-body-footer">
              <div class="modal-body">
                <p><i class="fa fa-spinner fa-spin" style="font-size:24px"></i> Processing...</p>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-default pull-left" data-dismiss="modal">#{t('close')}</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    ).html_safe
  end
end
