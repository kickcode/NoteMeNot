class AppDelegate
  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleDisplayName']

    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)
    @status_item.setTitle(@app_name)

    @status_menu.addItem createMenuItem("About #{@app_name}", 'orderFrontStandardAboutPanel:')
    @status_menu.addItem createMenuItem("Add Note", 'pressAddNote')
    @status_menu.addItem createMenuItem("Quit", 'terminate:')
  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def pressAddNote
    @notes ||= 0
    @notes += 1
    @status_item.setTitle("Notes: #{@notes}")
  end
end