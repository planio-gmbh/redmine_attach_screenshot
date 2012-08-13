module AttachScreenshot
  module Hooks

    class ViewHooks < Redmine::Hook::ViewListener
      render_on :view_attachments_form_before_content, :partial => 'attach_screenshot/attachments_form_before'
      render_on :view_attachments_form_after_content, :partial => 'attach_screenshot/attachments_form_after'
    end

  end
end

