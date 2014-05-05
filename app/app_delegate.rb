class AppDelegate
  WINDOW_WIDTH = 500
  WINDOW_HEIGHT = 180

  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleDisplayName']

    self.buildWindow

    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)
    @status_item.setTitle(@app_name)

    @status_menu.addItem createMenuItem("About #{@app_name}", 'orderFrontStandardAboutPanel:')
    @status_menu.addItem createMenuItem("Add Note", 'pressAddNote')
    @status_menu.addItem createMenuItem("Quit", 'terminate:')

    center = DDHotKeyCenter.sharedHotKeyCenter
    center.registerHotKeyWithKeyCode(KVK_ANSI_N, modifierFlags: NSControlKeyMask | NSAlternateKeyMask, target: self, action: 'toggleWindow:', object: nil)
  end

  def buildWindow
    @window = Motion::Popup::Panel.alloc.initPopup(WINDOW_WIDTH, WINDOW_HEIGHT)
    @window.arrow = false

    @rect = NSInsetRect(
      @window.contentView.frame,
      @window.background.line_thickness + 5,
      @window.background.arrow_height)

    @box = NSBox.alloc.initWithFrame(@rect)
    @box.setTitle("Enter note")
    @window.contentView.addSubview(@box)

    text_field_frame = NSInsetRect(@rect, 0, 12)
    text_field_frame.origin.y -= 28
    @text = NSTextField.alloc.initWithFrame(text_field_frame)
    @text.stringValue = ""
    @text.drawsBackground = false
    @text.setBezeled(false)
    @text.setBordered(false)
    @text.cell.setFocusRingType(NSFocusRingTypeNone)
    @text.setFont(NSFont.fontWithName("Arial", size: 30))
    @text.setDelegate(self)
    @box.addSubview(@text)
  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def pressAddNote
    @notes ||= 0
    @notes += 1
    @status_item.setTitle("Notes: #{@notes}")
  end

  def toggleWindow(event)
    @window.toggleWithFrame(CGRectMake(0, 0, 0, 0))
    @window.center
  end
end