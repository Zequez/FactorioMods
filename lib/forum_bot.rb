require 'http'

# Steps:
# - Go to login form, we need the temporal SID assigned by PHP
# - Submit the form
# - Go the PM edit form, we need the form_token
# - Load the user ID from the user name
# - Submit form with the user ID
# So we need to load 5 freaking pages just to send a single PM
# Luckily, the first 3 are only done once

class ForumBot
  def initialize
    @base_url = 'http://www.factorioforums.com/forum'
    @cookies = HTTP::CookieJar.new
    @authenticated = false
  end

  def authenticated?
    @authenticated
  end

  # Login form
  # ./ucp.php?mode=login
  # username
  # password
  # autologin
  # viewonline
  # sid
  # redirect ./ucp.php?mode=login
  # login
  def authenticate(forum_name, forum_password)
    req :post, '/ucp.php?mode=login', {
        username: forum_name,
        password: forum_password,
        autologin: 'on',
        viewonline: 'on', # This means no
        redirect: 'index.php',
        sid: get_login_form_sid,
        login: 'Login'
      }

    sid = @cookies.detect{|c| c.name == 'phpbb3_cobst_sid' }
    @sid = sid && sid.value
    cookie = @cookies.detect{|c| c.name == 'phpbb3_cobst_u' }
    @authenticated = !!(cookie && cookie.value != '1')
  end

  # Submit form
  # ../ucp.php?i=pm&mode=compose&action=post&sid=ae6184cabe88ec10dd036092de29d2f3
  # username_list
  # icon=0
  # subject:Test
  # addbbcode20:100
  # message:Testtest
  # lastclick:1438734772
  # status_switch:0
  # post:Submit
  # attach_sig:on
  # creation_time:1438734772
  # form_token:0a846587ad71540c62824d729fb5af1dcd7ec3d7
  def send_pm(user_id, subject, message)
    raise 'user_id must be a number' unless user_id.to_i != 0

    if authenticated?
      params = get_pm_form_params
      if params['form_token'].present?
        params = get_pm_form_params.merge({
          username_list: '',
          "address_list[u][#{user_id}]" => 'to',
          subject: subject,
          message: message
        })

        req :post, "/ucp.php?i=pm&mode=compose&action=post&sid=#{@sid}", params
        true # We wish for the best
      else
        false # No form_token, that means we are not logged in
      end
    else
      false # We haven't called authenticate yet
    end
  end

  def get_user_id(user_name)
    params = {
      username: user_name,
      icq: '',
      aim: '',
      yahoo: '',
      msn: '',
      joined_select: 'lt',
      joined: '',
      count_select: 'eq',
      count: '',
      search_group_id: '0',
      sk: 'c',
      sd: 'a',
      submit: 'Search'
    }

    res = req(:post, '/memberlist.php?form=postform&field=username_list&select_single=&mode=searchuser', params).to_s
    id = res.match(/u=([0-9]+)">/)
    id && id[1].to_i
  end

  private

  # ./ucp.php?i=pm&mode=compose
  def get_pm_form_params
    doc = Nokogiri::HTML(req(:get, '/ucp.php?i=pm&mode=compose').to_s)
    inputs = %w{icon lastclick status_switch post creation_time form_token}
    params = {}
    inputs.each do |i|
      params[i] = doc.at("[name=\"#{i}\"]")['value']
    end
    params
  end

  def get_login_form_sid
    if match = req(:get, '/ucp.php?mode=login').to_s.match(/name="sid" value="([a-z0-9]+)"/)
      match[1].to_i
    end
  end

  def req(verb, path, params = {})
    options = {}
    options[:params] = verb == :get ? params : {}
    options[:form] = verb == :post ? params : {}

    res = HTTP.cookies(@cookies).request(verb, @base_url + path, options)
    res.cookies.each do |cookie|
      @cookies.add cookie
    end
    res
  end
end
