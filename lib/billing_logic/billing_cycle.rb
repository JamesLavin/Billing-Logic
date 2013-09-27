module BillingLogic
  class BillingCycle
    include Comparable
    attr_accessor :period, :frequency, :anniversary
    TIME_UNITS = { :day => 1, :week => 7, :month => 365/12.0, :semimonth=> 365/24, :year => 365 }

    # Creates a new BillingCycle instance
    #
    # @param opts [Hash] holds :period, :frequency, and :anniversary
    # @return [BillingCycle] a billing cycle with .period, .frequency and .anniversary
    def initialize(opts = {})
      self.period = opts[:period]
      self.frequency = opts[:frequency] || 1
      self.anniversary = opts[:anniversary]
    end

    # Compares self against another BillingCycle instance by #periodicity
    #
    # @param other [BillingCycle] another BillingCycle instance
    # @return [-1, 0, 1] integer determined by which BillingCycle is longer
    def <=>(other)
      self.periodicity <=> other.periodicity
    end

    def periodicity
      time_unit_measure * frequency
    end

    def days_in_billing_cycle_including(date)
      (closest_anniversary_date_including(date) - anniversary).abs
    end

    # Date on which the next payment is due and scheduled to be paid
    # anniversary will always equal date
    def next_payment_date
      increment_date_by_period(anniversary)
    end
    
    # Used for prorationing in the single payment strategy
    # Not currently in use
    def closest_anniversary_date_including(date) 
      if date < anniversary
        decrement_date_by_period(anniversary)
      else
        increment_date_by_period(anniversary)
      end
    end

    def increment_date_by_period(date)
      shift_date_by_period(date)
    end

    def decrement_date_by_period(date)
      shift_date_by_period(date, true)
    end

    def shift_date_by_period(date, backwards = false)
      operators =   {:month => backwards ? :<< : :>>, 
                     :day   => backwards ? :-  : :+ }
      case self.period
      when :year
        date.send(operators[:month], (self.frequency * 12))
      when :month
        date.send(operators[:month], self.frequency)
      when :week
        date.send(operators[:month], (self.frequency * 7))
      when :day
        date.send(operators[:month], self.frequency)
      end
    end

    private
    def time_unit_measure
      TIME_UNITS[self.period]
    end

  end
end
