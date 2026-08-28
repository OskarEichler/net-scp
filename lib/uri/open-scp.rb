require 'open-uri'
require 'uri/scp'
require 'net/scp'

OpenURI::Options[:ssh] = nil

module URI

  class SCP
    def buffer_open(buf, proxy, open_options)
      options = open_options.dup
      options[:ssh] = (options[:ssh] || {}).merge(:port => port)
      options[:ssh][:password] = password if password
      progress = options.delete(:progress_proc)
      content_length = options.delete(:content_length_proc)
      buf << Net::SCP.download!(host, user, path, nil, options) do |_channel, _name, received, total|
        content_length.call(total) if content_length && received == 0
        progress.call(received) if progress
      end
      buf.io.rewind
    end

    include OpenURI::OpenRead
  end

end
