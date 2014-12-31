# -*- coding: utf-8 -*-
require 'webrick'
require 'uri'

srv = WEBrick::HTTPServer.new({ :DocumentRoot => './',
                                :BindAddress => '127.0.0.1',
                                :AccessLog => [
                                               [File.open('access.log', 'a+'),
                                                WEBrick::AccessLog::CLF]],
                                :Port => 20080})

# SIGINT を捕捉する。
Signal.trap('INT') do
  # 捕捉した場合、シャットダウンする。
  srv.shutdown
end

srv.mount_proc('/') do |req, _res|
  File.open('detail.log', 'a+') do |f|
    f.puts Time.now.strftime('%Y.%m.%d %H:%M:%S:') +
      "#{req.request_method}:" + req.path.to_s + ' ' + req.query_string.to_s
    f.puts '========== header =========>'
    req.header.each do |k, v|
      f.puts "\"#{k}\"=>#{v.inspect}"
    end
    f.puts '<========== header ========='

    f.puts '========== body[raw] =========>'
    f.puts req.body
    f.puts '<========== body[raw] ========='

    f.puts '========== body[decode] =========>'
    begin
      f.puts URI.decode_www_form(req.body).inspect
    rescue => e
      f.puts "error: #{e}\n  " + e.backtrace.join("\n  ")
    end
    f.puts '<========== body[decode] ========='
  end
end

srv.start
