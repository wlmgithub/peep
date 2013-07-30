require 'rubygems'
require 'net/https'
require 'uri'
require 'json'

module CMHelper
class Campfire

  attr_accessor :room, :token, :subdomain, :url

  MRTALKYBOT_TOKEN = "<token>"
  ROOM_TEST = 347300

  PROXY_HOST = '<proxy_host>'
  PROXY_PORT = 3128
  PROXY_USER = '<proxy_user>'
  PROXY_PASS = '<proxy_pass>'

  def initialize(opts={})
    @token = opts[:token] || MRTALKYBOT_TOKEN
    @room = opts[:room] || ROOM_TEST
    @subdomain = opts[:subdomain] || "foobar"
    @url = "https://#{@subdomain}.campfirenow.com/room/#{@room}/speak.json"
  end

  def speak(message)
    # Paste some simple text into the campfire
    request(message)
  end

  def sound(sound)
    # Note: You don't need to preferece the sound with a slash
    # Example "trombone" instead of "/trombone"
    request(sound, { :message_type => "SoundMessage" })
  end

  def paste(paste)
    request(paste, { :message_type => "PasteMessage" })
  end

  def request(message, opts={})
    uri = URI(@url)

    message_type = opts[:message_type] || "Textmessage"

    data = { :message => { :body => message, :type => message_type } }

    encoded = JSON::dump(data)

    proxy = Net::HTTP::Proxy(PROXY_HOST, PROXY_PORT, PROXY_USER, PROXY_PASS)
    http_session = proxy.new(uri.host, 443)
    http_session.use_ssl = true
    http_session.verify_mode = OpenSSL::SSL::VERIFY_NONE

    http_session.start { |http|

      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth token, 'X'
      request.body = encoded
      request["Content-Type"] = "application/json"
      http.request(request)

    }

    # TODO: error handling here
  end

end
end

class ChangeController < ApplicationController
  require 'foobar'

  before_filter :fail_if_not_up_to_date, :except => [:send_data, :fetch, :get, :search, :search_by_title, :current_max_update_date, :index]
  before_filter :send_data, :except => [:fetch, :search, :search_by_title, :get, :check_last_updated, :fail_if_not_up_to_date, :current_max_update_date, :index]

  def index
    if(params[:id])
      @change = Change.find(params[:id])
    end
  rescue => e
    log_error(e)
    render :file => "#{RAILS_ROOT}/public/404.html",
           :status => '404 Not Found'#put up dem' 404s
  end

  def send_data
    if(Rails.env.production?)
      # aye... this be a dirty hack... figure out the syntax and readd the user to the update code in cm gem...
      if !params[:user].nil?
        user = params[:user]
      else
        user = 'someone'
      end
      Juggernaut.send_to_all('<strong>'+user+'</strong> has just edited this list, <em>click here to refresh!</em>')
    end
  end

  def talk(message)
    if message.empty?
      return
    end

    current_user.nil? ? user = 'someone': user = current_user
    # choose which room to speak to
    if Rails.env.production?
      # 159233 is 'launch'
      CMHelper::Campfire.new({:room => 159233}).speak("cm/#{user}: #{message}")
    else
      # 347300 is 'test'
      CMHelper::Campfire.new({:room => 347300}).speak("cm/#{user}: #{message}")
    end

 end

  def is_interlocked
    if (params[id] && Change.find(params[:id]).isInterlocked?)
      render :json => {:status => :error, :result => { :interlocked => true } }
    else
      render :json => {:status => 'success', :result => { :interlocked => false } }
    end
  end

  def create
    send_data
    params[:change][:disruptive] = params[:change][:disruptive] == 'true'

    if(!params[:change][:cc] || params[:change][:cc].empty?)
      params[:change][:cc] = params[:change][:requester]
    end

    if(params[:change][:change_type])
      type = Type.find_by_name(params[:change][:change_type])
      if(type)
        params[:change][:type_id] = type.id
        params[:change].delete('change_type')
      else
        render :json => {:status => 'error', :result =>{ :message => 'change type not found'} }
      end
    end

    change = Change.create(params[:change])

    if params[:change][:disruptive]
      tweet(change, 'created')
    end

    render :json => {:status => 'success', :result => { :change => change } }
  rescue => e
    log_error(e)
    render :json => { :status => :error, :error => { :type => e.class.to_s, :message => e.message } }.to_json
  end

  def search
    fields_to_search = %w(changes.desc change_type title requester)
    changes = Change.find(
      :all,
      :order => 'created_at desc',
      :limit => 50,
      :conditions => fields_to_search.map {|f|
        params[:search].split(' ').map {|p|
          "#{f} LIKE '%#{p}%'"}}.join(' OR ')
    )
    render :json => {:status => 'success', :result => { :changes => changes } }.to_json
  rescue => e
    log_error(e)
    render :json => { :status => :error, :error => { :type => e.class.to_s, :message => e.message } }.to_json
  end

  def tweet(change, action)
    foobar.configure do |config|
      config.consumer_key = '<key>'
      config.consumer_secret = '<sec>'
      config.oauth_token = '<token>'
      config.oauth_token_secret = '<token_sec>'
      unless RAILS_ENV == 'development'
        config.endpoint = "http://api.local.foobar.com:9000"
      end
    end

    client = foobar::Client.new
    client.update('Disruptive change "' + change.title.slice(0,50) + '" ' + action + ': https://cm.local.foobar.com/change/' + change.id.to_s())
  end

  def search_by_title
    changes = Change.find(
      :all,
      :limit => 10,
      :conditions => "title = '#{params[:search]}'"
    )
    render :json => {:status => 'success', :result => { :changes => changes } }.to_json
  rescue => e
    log_error(e)
    render :json => { :status => :error, :error => { :type => e.class.to_s, :message => e.message } }.to_json
  end

  def fetch
    if(params[:completed])
      # give completed changes on day X
      if(params[:date])
        date_input = params[:date]
        changes = Change.find(:all, :conditions => ['status = ? and DATE(completed_date) = ?', 'completed', date_input], :limit => 50, :offset => (params[:offset] || 0) )
      # give completed changes starting from now going backwards
      else
        changes = Change.find(:all, :conditions => ['status = ?', 'completed'], :order => 'completed_date desc', :limit => 50, :offset => (params[:offset] || 0) )
      end
    else
      changes = Change.find(:all, :conditions => ['status != ?', 'completed']).sort_by{|p| p.requested_start_date}
    end
    render :json => {:status => 'success', :result => { :changes => changes } }
  end

  def update
    locked = false
    message = ''
    change = Change.find(params[:change][:id])
    if params[:change][:status] != change.status
      # user is moving change from in_progress to completed
      if params[:change][:status] == 'completed'
        message = " has completed '#{change.type.name}' change '#{params[:change][:title]}' - http://cm.local.foobar.com/change/#{params[:change][:id]}"
        # set the completed_date field
        params[:change][:completed_date]  = Time.now.getutc
      # user is moving change from ready to in_progress
      elsif params[:change][:status] == 'in_progress'
        message = " is starting '#{change.type.name}' change '#{params[:change][:title]}' - http://cm.local.foobar.com/change/#{params[:change][:id]}"
        locked = change.isInterlocked?
        # set the start_date field
        params[:change][:start_date]  = Time.now.getutc
      # user is moving from in_progress to ready
      elsif params[:change][:status] == 'ready'
        message = " is stopping work on '#{change.type.name}' change '#{params[:change][:title]}' - http://cm.local.foobar.com/change/#{params[:change][:id]}"
      else
        messaage = "unkown change type: #{params[:change][:status]}..."
      end
    end

    if (!locked)
      talk(message) if ENV['RAILS_ENV'] != 'development'
      change = Change.update(params[:change][:id], params[:change])
      if params[:change][:disruptive] == 'true'
        tweet(change, params[:change][:status])
      end
      render :json => {:status => 'success', :result => {:locked => Change.find(params[:change][:id]).isInterlocked?, :changes => change } }
    else
      render :json => {:status => :error, :error => {:locked => Change.find(params[:change][:id]).isInterlocked?, :type => 'locked', :message => 'conflicting change in progress' } }.to_json
    end
  rescue => e
    log_error(e)
    render :json => {:status => :error, :error => { :type => e.class.to_s, :message => e.message } }.to_json
  end

  def destroy
    change = Change.destroy(params[:id])
    render :json => {:status => 'success', :result => { :change => change } }
  rescue => e
    log_error(e)
    render :json => { :status => :error, :error => { :type => e.class.to_s, :message => e.message } }.to_json
  end

  def sort
    change = Change.find(params[:id])
    change.insert_at(params[:pos])
    render :json => {:status => 'success', :result => { :change => change } }
  rescue => e
    log_error(e)
    render :json => { :status => :error, :error => { :type => e.class.to_s, :message => e.message } }.to_json
  end

  def get
    change = Change.find(params[:id])
    render :json => {:status => 'success', :result => { :change => change } }
  rescue => e
    log_error(e)
    render :json => { :status => :error, :error => { :type => e.class.to_s, :message => e.message } }.to_json
  end

  def check_last_updated
   render :json => {:status => 'success', :result => 'up to date' }
  end

  private

  def fail_if_not_up_to_date
    return true if !current_max_update_date || DateTime.parse(params[:lastUpdated]) >= current_max_update_date
    render :json => { :status => :error, :error => { :type => 'error', :message => 'The list in your browser is out of date. Would you like to refresh now?'} }.to_json
    false
  end

  def current_max_update_date
    if(params[:mode] == 'completed')
     change = Change.find(:first, :conditions => ['status = ?', 'completed'], :order => 'updated_at desc', :limit => 1)
    else
     change = Change.find(:first, :conditions => ['status != ?', 'completed'], :order => 'updated_at desc', :limit => 1)
    end
    if change
      change.updated_at
    else
      nil
    end
  end

  def log_error(e)
    RAILS_DEFAULT_LOGGER.warn "#{e.class}: #{e.message}"
    RAILS_DEFAULT_LOGGER.warn "\t#{e.backtrace.join("\n\t")}"
  end
end
