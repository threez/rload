require File.dirname(__FILE__) + '/test_helper.rb'
require "net/http"

class TestRloadScript < Test::Unit::TestCase
  def setup
    
  end
  
  def test_truth
    script = Rload::Script.new do |script|
      #script.transaction "Yahoo" do |t|
      #  2.times do
      #    t.measure "index" do |m|
      #      resp = Net::HTTP.get_response "de.yahoo.com", "/"
      #      m.http_code = resp.code
      #      assert resp.body =~ /E-Mails lesen/
      #    end
      #  end
      #  
      #  t.measure "logo" do |m|
      #    resp = Net::HTTP.get_response "l.yimg.com", "/i/i/de/hp/yahoo1.png"
      #    m.http_code = resp.code
      #  end
      #end
      
      #script.transaction "Stiftung Warentest" do |t|
      #  t.measure "index" do |m|
      #    resp = Net::HTTP.get_response "www.test.de", "/"
      #    m.http_code = resp.code
      #    assert resp.body =~ /Der Akku ist zu klein/
      #  end
      #
      #  t.measure "logo" do |m|
      #    resp = Net::HTTP.get_response "www.test.de", "/img/logo.gif"
      #    m.http_code = resp.code
      #  end
      #end
      
      #script.transaction "Local gem server" do |t|
      #  t.measure "index" do |m|
      #    resp = Net::HTTP.get_response "localhost", "/", 8808
      #    m.http_code = resp.code
      #    assert resp.body =~ /Summary/
      #  end
      #
      #  t.measure "rake module" do |m|
      #    resp = Net::HTTP.get_response "localhost", "/doc_root/rake-0.8.1/rdoc/classes/Module.html", 8808
      #    m.http_code = resp.code
      #  end
      #end
      
      script.transaction "Local apache" do |t|
        t.measure "index" do |m|
          resp = Net::HTTP.get_response "localhost", "/"
          m.http_code = resp.code
          #assert resp.body =~ /Apache-Webserver/
        end
      
        t.measure "music txt" do |m|
          resp = Net::HTTP.get_response "localhost", "/~vincentlandgraf/Music.txt"
          m.http_code = resp.code
        end
      end
    end
    
    t = []
    st =Time.now
    sum = 0
    1000.times { 
      t << Thread.new do
        tst = Time.now
        script.execute
        tet = Time.now
        sum += tet-tst
      end    
    }
    t.each { |t| t.join }
    et = Time.now
    puts "%f/%f" % [et-st, sum]
    
    script.each_transaction do |t|
      puts "[T] %s (%f)" % [
        t.name, t.duration
      ]
      t.each_measurement do |m|
        puts "  [M] %s (%f) ==> %d" % [
          m.name, m.duration, m.http_code
        ]
      end
    end
  end
end
