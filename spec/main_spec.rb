describe "Application 'NoteMeNot'" do
  before do
    @app = NSApplication.sharedApplication
  end

  it "has a status menu" do
    @app.delegate.status_menu.nil?.should == false
  end

  it "has two menu items" do
    @app.delegate.status_menu.itemArray.length.should == 2
  end
end
