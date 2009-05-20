class Spork
  def self.prefork(&block)
    return if @already_preforked
    @already_preforked = true
    yield
  end
  
  def self.each_run(&block)
    return if @state == :preforking || (@state != :not_using_spork && @already_run)
    @already_run = true
    yield
  end
  
  def self.preforking!
    @state = :preforking
  end
  
  def self.running!
    @state = :running
  end
  
  def self.state
    @state ||= :not_using_spork
  end
end