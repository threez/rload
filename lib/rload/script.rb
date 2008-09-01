require "ostruct"

module Rload
  class Script
    def initialize(&instructions)
      @instructions = instructions
      @transactions = []
    end
    
    def execute
      @instructions.call(self)
    end
    
    def transaction(name, &instructions)
      t = Transaction.new(self, name, &instructions )
      @transactions << t
      t.execute
    end
    
    def each_transaction()
      @transactions.each { |t| yield(t) }
    end
  end
  
  class Transaction
    attr_accessor :name, :start_time, :end_time
    
    def initialize(script, name, &instructions)
      @script = script
      @name = name
      @instructions = instructions
      @measurements = []
    end
    
    def execute
      @start_time = Time.now
      @instructions.call(self)
      @end_time = Time.now
    end
    
    def measure(name, &instructions)
      m = Measurement.new(self, name, &instructions )
      @measurements << m
      m.execute
    end
    
    def each_measurement()
      @measurements.each { |m| yield(m) }
    end
    
    def duration
      end_time - start_time
    end
  end
  
  class Measurement < OpenStruct
    attr_accessor :name, :start_time, :end_time
    
    def initialize(transaction, name, &instructions)
      super name
      @transaction = transaction
      @name = name
      @instructions = instructions
    end
    
    def execute
      @start_time = Time.now
      error = false
      begin
        @instructions.call(self)
      rescue Errno::ECONNRESET => ex
        puts " !- RETRY after reset"
        error = true
      rescue => ex
        #puts " !! %s->s " % [@transaction.name, name]
        puts " !! %s" % ex.message
        #puts ex.backtrace
      end while error
      @end_time = Time.now
    end
    
    def duration
      end_time - start_time
    end
  end
end