module SessionHelper
  def redirect_to_input(f)
    f.input :redirect_to,
      as: :hidden,
      input_html: {
        name: :redirect_to,
        value: params[:redirect_to] || request.headers['X-XHR-Referer'] || request.referer
      }
  end
end