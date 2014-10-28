module ModsHelper
  def mod_date(date)
    if date
      string = time_ago_in_words(date) + ' ago'
      content_tag :span, string, title: date.to_s(:rfc822)
    else
      ''
    end
  end
end
