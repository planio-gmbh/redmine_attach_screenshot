require 'RMagick'

class AttachScreenshotController < ApplicationController
  unloadable
  skip_before_filter :require_login
  skip_before_filter :verify_authenticity_token
  accept_rss_auth :index

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
      file = File.new(File.join(SCREENSHOTS_PATH, make_tmpname(date)), "wb");
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

  def make_tmpname(date, name = "screenshot.png")
    sprintf('%d_%s%s', User.current.id, date, name)
  end
end
