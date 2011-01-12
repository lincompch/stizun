class PageController < ApplicationController
  def index
  end

  def tos
    path = Rails.root + 'custom/pages/tos.html.erb'
    if path.exist?
      render path.to_s
    end
  end
  
end
