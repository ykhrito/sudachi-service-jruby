require 'socket'
require './sudachi-0.3.0.jar'
import 'com.worksap.nlp.sudachi.Dictionary'
import 'com.worksap.nlp.sudachi.DictionaryFactory'
import 'com.worksap.nlp.sudachi.Morpheme'
import 'com.worksap.nlp.sudachi.Tokenizer'

CONF_FILE = 'sudachi_fulldict.json'.freeze
LOG_FILE = 'sudachi-service.log'.freeze
PORT = 14343

begin
  require 'win32/daemon'
  include Win32

  class SudachiService < Daemon
    def service_init
      File.open(LOG_FILE, 'a') { |f| f.puts "Initializing service #{Time.now}" }
      factory = DictionaryFactory.new
      dic = factory.create(nil, File.open(CONF_FILE, 'r:utf-8').read, false)
      @tokenizer = dic.create
      @server = TCPServer.new(PORT)
      File.open(LOG_FILE, 'a') { |f| f.puts "Listening on port #{PORT}... #{Time.now}" }
      sleep 1
    end

    def service_main
      File.open(LOG_FILE, 'a') { |f| f.puts "Service is running #{Time.now}" }
      while running?
        Thread.start(@server.accept) do |socket|
          socket.set_encoding 'UTF-8'
          while line = socket.gets
            @tokenizer.tokenize(Tokenizer::SplitMode::C, line.chomp).each do |m|
              socket.print m.readingForm
            end
            socket.puts
          end
          socket.close
        end
      end
    end

    def service_stop
      File.open(LOG_FILE, 'a') { |f| f.puts "Stopping server thread #{Time.now}" }
      @server.close
      File.open(LOG_FILE, 'a') { |f| f.puts "Service stopped #{Time.now}" }
    end
  end

  SudachiService.mainloop

rescue Exception => e
  File.open(LOG_FILE, 'a+') do |f|
     f.puts "***Daemon failure #{Time.now} exception=#{e.inspect}"
     f.puts "#{e.backtrace.join($INPUT_RECORD_SEPARATOR)}"
  end
  raise
end

