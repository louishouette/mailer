module Mmailer
  class MailHelper
    attr_reader :template, :title

    def initialize(args)
      set_provider args.fetch(:provider, :mailchimp)
      @template=args[:template]
      @title=args[:title]
    end

    def set_provider(provider)
      providers = {google: Providers.gmail, mailchimp: Providers.mandrill}
      Mail.defaults(&providers[provider])
    end

    def send_email(user)

      mail = Mail.new do
        to user.email
        from 'Etsy Fu <info@shopi-fu.com>'
      end
      mail.subject = title

      text_part = Mail::Part.new
      text_part.body=ERB.new(File.read("#{Bundler.root}/lib/mailer/templates/#{template}.txt.erb")).result(binding)

      html_part = Mail::Part.new
      html_part.content_type='text/html; charset=UTF-8'
      html_part.body=ERB.new(File.read("#{Bundler.root}/lib/mailer/templates/#{template}.html.erb")).result(binding)

      mail.text_part = text_part
      mail.html_part = html_part
      #when Non US-ASCII detected and no charset defined. Defaulting to UTF-8, set your own if this is incorrect.
      mail.charset = 'UTF-8'
      #puts mail.to_s
      mail.deliver!

    end
  end
end