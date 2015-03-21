class Service::ChatWork < Service
  string          :rooms, :restrict_to_branch
  password        :token
  boolean         :mute_push, :mute_pull_request, :mute_issues
  white_list      :rooms, :restrict_to_branch

  default_events  :push, :pull_request, :issues

  maintained_by github: 'chatwork'
  supported_by  github: 'chatwork'

  url       'http://www.chatwork.com/'
  logo_url  'http://www.chatwork.com/image/common/logo_hz.png'

  def receive_push
    required_config
    if config_boolean_true? 'mute_push'
      return
    end

    branch_restriction = data['restrict_to_branch'].to_s
    if branch_restriction.length > 0 && branch_restriction.index(branch) == nil
      return
    end

    message = <<-EOH
[info][title]#{pusher_name} has pushed #{commits.size} commit(s)[/title]#{commit_messages.join("\n")}
[hr]Branch: #{branch_name}
Repository: #{repo_name}
Compare: #{compare_url}[/info]
EOH
    send message
  end

  def receive_pull_request
    required_config
    if config_boolean_true? 'mute_pull_request'
      return
    end

    message = <<-EOH
[info][title]#{action} a pull request. #{pull.title}[/title]#{summary_message}
[hr]URL: #{summary_url}[/info]
EOH
    send message
  end

  def receive_issues
    required_config
    return if config_boolean_true? 'mute_issues'

    message = <<-EOH
[info][title]#{action} an issue. #{issue.title}[/title]#{summary_message}
[hr]URL: #{summary_url}[/info]
EOH
    send message
  end

  private

  def required_config
    raise_config_error 'Token is required' if data['token'].to_s.empty?
    raise_config_error 'rooms is required' if data['rooms'].to_s.empty?
  end

  def send(message)
    http.url_prefix = 'https://api.chatwork.com'
    http.headers['X-ChatWorkToken'] = data['token']
    http.headers['X-GitHub-Event']  = event.to_s
    http.headers['Content-Type']    = 'application/json'
    http.headers['Accept']          = 'application/json'

    rooms = data['rooms'].to_s.split(',')
    rooms.each do |room_id|
      response = http_post "/v1/rooms/#{room_id}/messages", :body => message
      case response.status
        when 200..299
        else raise_config_error "HTTP Error: #{response.status} #{response.body}"
      end
    end
  end

end
