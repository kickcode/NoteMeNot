class AppDelegate
  WINDOW_WIDTH = 500
  WINDOW_HEIGHT = 180
  POPUP_WIDTH = 300
  POPUP_HEIGHT = 300

  Note = Struct.new(:id, :text)

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
        self.addNote(@text.stringValue)
        @text.stringValue = ""
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

  def addNote(text)
    @notes << Note.new((@notes.map(&:id).sort.last || 0) + 1, text)
    self.updateNotes
  end

  def removeNote(button)
    @notes.delete(@notes.detect { |note| note.id == button.tag })
    self.updateNotes
  end

  def updateNotes
    @status_item.setTitle("Notes: #{@notes.length}")
    @collection_view.setContent(@notes)
  end
end

class NotesView < NSView
  NOTE_HEIGHT = 140

  attr_accessor :box, :message

  def initWithFrame(rect)
    super(NSMakeRect(rect.origin.x, rect.origin.y, AppDelegate::POPUP_WIDTH, NOTE_HEIGHT))

    remove_image = NSImage.imageNamed("remove.png")
    @remove = NSButton.alloc.initWithFrame(NSMakeRect(AppDelegate::POPUP_WIDTH - remove_image.size.width - 5, (NOTE_HEIGHT / 2.0) - (remove_image.size.height / 2.0), remove_image.size.width, remove_image.size.height))
    @remove.setImage(remove_image)
    @remove.setImagePosition(NSImageOnly)
    @remove.setBordered false
    @remove.setFont NSFont.fontWithName("Arial", size: 30)
    @remove.setTarget(NSApplication.sharedApplication.delegate)
    @remove.setAction('removeNote:')
    @remove.setToolTip("Remove this note")
    self.addSubview(@remove)

    box_frame = NSInsetRect(self.bounds, 5, 3)
    box_frame.size.width = @remove.frame.origin.x - 5
    @box = NSBox.alloc.initWithFrame(box_frame)
    @box.setTitle ""
    self.addSubview(@box)

    @message = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, @box.frame.size.width, NOTE_HEIGHT - 30))
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
    @remove.tag = object.id
    self.message.stringValue = object.text
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