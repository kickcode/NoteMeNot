class AppDelegate
  WINDOW_WIDTH = 500
  WINDOW_HEIGHT = 180
  POPUP_WIDTH = 300
  POPUP_HEIGHT = 300

  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleDisplayName']

    self.buildWindow
    self.buildPopup

    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setTarget(@popup)
    @status_item.setAction('toggle')
    @status_item.setHighlightMode(true)
    @status_item.setTitle(@app_name)

    @status_menu.addItem createMenuItem("About #{@app_name}", 'orderFrontStandardAboutPanel:')
    @status_menu.addItem createMenuItem("Quit", 'terminate:')

    center = DDHotKeyCenter.sharedHotKeyCenter
    center.registerHotKeyWithKeyCode(KVK_ANSI_N, modifierFlags: NSControlKeyMask | NSAlternateKeyMask, target: self, action: 'toggleWindow:', object: nil)

    @notes = []

    @key_down_handler = Proc.new do |event|
      if event.keyCode == KVK_Return
        note = @text.stringValue
        @notes << note
        @text.stringValue = ""
        @status_item.setTitle("Notes: #{@notes.length}")
        @collection_view.setContent(@notes)

        @status_menu.addItem createMenuItem(note, 'pressNote:')
      else
        result = event
      end
      result
    end
    NSEvent.addLocalMonitorForEventsMatchingMask(NSKeyDownMask, handler: @key_down_handler)
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

  def buildPopup
    @popup = Motion::Popup::Panel.alloc.initPopup(POPUP_WIDTH, POPUP_HEIGHT)

    @scroll_rect = NSInsetRect(@popup.contentView.frame, @popup.background.line_thickness / 2.0, @popup.background.arrow_height)

    scroll_view = NSScrollView.alloc.initWithFrame(@scroll_rect)
    scroll_view.hasVerticalScroller = true
    @popup.contentView.addSubview(scroll_view)

    @collection_view = NSCollectionView.alloc.initWithFrame(scroll_view.frame)
    @collection_view.setItemPrototype(NotesPrototype.new)

    scroll_view.documentView = @collection_view

    @collection_view.setContent(@notes)
  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def toggleWindow(event)
    @window.toggleWithFrame(CGRectMake(0, 0, 0, 0))
    @window.center
  end

  def pressNote(item)
    @notes.delete(item.title)
    @status_menu.removeItem(item)
    @status_item.setTitle("Notes: #{@notes.length}")
  end
end

class NotesView < NSView
  NOTE_HEIGHT = 140

  attr_accessor :box, :message

  def initWithFrame(rect)
    super(NSMakeRect(rect.origin.x, rect.origin.y, AppDelegate::POPUP_WIDTH, NOTE_HEIGHT))

    @box = NSBox.alloc.initWithFrame(NSInsetRect(self.bounds, 5, 3))
    @box.setTitle ""
    self.addSubview(@box)

    @message = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, AppDelegate::POPUP_WIDTH, NOTE_HEIGHT - 30))
    @message.drawsBackground = false
    @message.setEditable false
    @message.setSelectable false
    @message.setBezeled false
    @message.setFont NSFont.fontWithName("Arial", size: 15)
    @box.addSubview(@message)

    self
  end

  def setViewObject(object)
    return if object.nil?
    self.message.stringValue = object
    @object = object
  end
end

class NotesPrototype < NSCollectionViewItem
  def loadView
    self.setView(NotesView.alloc.initWithFrame(NSZeroRect))
  end

  def setRepresentedObject(object)
    super(object)
    self.view.setViewObject(object)
  end
end