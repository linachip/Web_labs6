# frozen_string_literal: true

require 'active_record'

Dir.glob('./db/*.rb').each { |file| require_relative file }
Dir.glob('./models/*.rb').each { |file| require_relative file }
Dir.glob('./controllers/*.rb').each { |file| require_relative file }

Sqlite3Db.setup

class App
  def call(env)
    controller, action = handler_for(env['REQUEST_PATH'], env['REQUEST_METHOD'])

    if controller && action
      instance = controller.new(env)
      instance.send(action)
      return instance.to_rack
    end

    filename = env['REQUEST_PATH']
    base_path = File.expand_path(__dir__)

    if File.exist?(File.join(base_path, filename))
      content_type = content_type_from(filename)
      file = File.read(File.join(base_path, filename))

      [200, { 'Content-Type' => content_type }, [file]]
    else
      [404, { 'Content-Type' => 'text/plain' }, ['Not found']]
    end
  end

  private

  def content_type_from(filename)
    {
      'html' => 'text/html',
      'css' => 'text/css',
      'js' => 'application/javascript',
      'jpg' => 'image/jpg',
      'png' => 'image/png',
      'ttf' => 'text/font',
      'woff' => 'application/font-woff',
      'woff2' => 'application/font-woff2',
      'tff' => 'application/font-ttf'
    }[filename.split('.').last].to_s
  end

  def handler_for(path, method)
    {
      ['GET', '/'] => [HomeController, :index],
      ['GET', '/sign_in'] => [SessionController, :new],
      ['POST', '/sign_in'] => [SessionController, :create],
      ['DELETE', '/sign_out'] => [SessionController, :delete],
      ['GET', '/sign_up'] => [RegistrationsController, :new],
      ['POST', '/sign_up'] => [RegistrationsController, :create],
      ['POST', '/sync'] => [TodosController, :sync],
    }[[method, path]]
  end
end
