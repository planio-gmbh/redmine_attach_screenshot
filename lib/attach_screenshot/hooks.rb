module AttachScreenshot
  module Hooks

    class ViewHooks < Redmine::Hook::ViewListener
      render_on :view_attachments_form_after_multi_file_upload, :partial => 'attach_screenshot/attachments_form_after_multi_file_upload'
    end

  end
end

