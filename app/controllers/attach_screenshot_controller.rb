require 'RMagick'

class AttachScreenshotController < ApplicationController
  unloadable
  skip_before_filter :verify_authenticity_token
  before_filter :is_allowed_to_create_or_edit_issues?

  # maybe replace with config entry?
  if defined?(::RedmineTenantable) && RedmineTenantable.tenant.present?
    SCREENSHOTS_PATH = FileUtils.makedirs(File.join(Dir.tmpdir, "planio", RedmineTenantable.tenant, "redmine_attach_screenshot"), :mode => 0700)
  else
    SCREENSHOTS_PATH = FileUtils.makedirs(File.join(Dir.tmpdir, "planio", "redmine_attach_screenshot"), :mode => 0700)
  end

  def index
    if request.post?
      date = DateTime.now.strftime("%H%M%S")
      @fname = make_tmpname(date)
      file = File.new(File.join(SCREENSHOTS_PATH, @fname), "wb");
      file.write(params[:attachments].read);
      file.close();
      if (Object.const_defined?(:Magick))
        img = Magick::Image::read(file.path()).first
        thumb = img.resize_to_fit(150, 150)
        @fname = make_tmpname(date, "thumb.png")
        thumb.write(File.join(SCREENSHOTS_PATH, @fname))
      end
        render :inline => "<%= @fname %>"
    else
      @fname = params[:id];
      (render_404; return false) if @fname.empty?
      if @fname.match(/\A\d+_\w+\.\w+\z/)
        send_file(File.join(SCREENSHOTS_PATH, @fname),
                  :disposition => 'inline',
                  :type => 'image/png',
                  :filename => "screenshot.png");
      else
        render_403
      end
    end
  end

  private

  def is_allowed_to_create_or_edit_issues?
    [:add_issues, :edit_issues, :add_issue_notes].any? do |perm|
      User.current.allowed_to?(perm, nil, :global => true)
    end || (render_403; return false)
  end

  def find_current_user
    if request.post?
      User.active.find_by_rss_key(params[:key].to_s)
    else
      super
    end
  end

  def make_tmpname(date, name = "screenshot.png")
    sprintf('%d_%s%s', User.current.id, date, name)
  end
end
