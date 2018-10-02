require 'one_note_sharer' # see lib/one_note_sharer.rb

class WelcomeController < ApplicationController
  @resourse_url

  def index
    onenote_client = OneNoteSharer.new
    @auth_url = onenote_client.auth_url
  end

  def submit
    @oneNoteWeb_url = nil
    @response_code = nil
    onenote_client = OneNoteSharer.new
    access_token = cookies['access_token']
    result = case params[:submit]
             when 'text'
               onenote_client.create_page_with_simple_text(access_token)
             when 'textimage'
               onenote_client.create_page_with_text_and_image(access_token)
             when 'url'
               onenote_client.create_page_with_screenshot_from_url(access_token)
             when 'html'
               onenote_client.create_page_with_screenshot_from_html(access_token)
             when 'file'
               onenote_client.create_page_with_file(access_token)
             end
    @oneNoteWeb_url = result['links']['oneNoteWebUrl']['href'] if result.present?

  rescue Exception => e
    @response = e.response
    @response_code = e.http_code
  end

  def callback
    onenote_client = OneNoteSharer.new
    token_set = onenote_client.handle_callback_request(params)
    return unless token.present?
    expire_in = token_set['expires_in'].to_i
    cookies['access_token'] = { :value => token_set['access_token'], :expires => expire_in.seconds.from_now }
    cookies['authentication_token'] = { :value => token_set['authentication_token'], :expires => expire_in.seconds.from_now }
    cookies['scope'] = { :value => token_set['scope'], :expires => expire_in.seconds.from_now }
    refresh_token = token_set['refresh_token']
    onenote_client.save_refresh_token(refresh_token) if refresh_token.present?
  end

end
