describe 'Homepage' do 
  before do
    unless @browser
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
  end
  
  after do
    @browser.close
    @headless.destroy
  end
    # ...
end