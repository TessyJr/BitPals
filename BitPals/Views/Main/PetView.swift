import Cocoa
import CloudKit
import AVFoundation

class PetView: NSImageView {
  var viewModel: PetViewModel
        
    init(frame frameRect: NSRect = .zero, viewModel: PetViewModel) {
        self.viewModel = viewModel
        super.init(frame: frameRect)
        
        viewModel.petView = self

        viewModel.configureView()
        viewModel.setGifImage()
        
        if viewModel.isCompanionAppOn {
            viewModel.fetchInitialHealthDataFromCloudKit()
            viewModel.startFetchTimer()
        } else {
            viewModel.startReminderTimer()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: NSSize {
        let size = super.intrinsicContentSize
        return NSSize(width: size.width * viewModel.scale, height: size.height * viewModel.scale)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        if viewModel.status == .remind {
            viewModel.status = .idle
            viewModel.setGifImage()
            
            if viewModel.isCompanionAppOn {
                viewModel.startFetchTimer()
            } else {
                viewModel.startReminderTimer()
            }
        } else if viewModel.status == .idle {
            viewModel.direction == .right ? viewModel.moveImageRight() : viewModel.moveImageLeft()
        } else {
            return
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if viewModel.status == .remind {
            viewModel.status = .idle
            viewModel.setGifImage()
            
            if viewModel.isCompanionAppOn {
                viewModel.startFetchTimer()
            } else {
                viewModel.startReminderTimer()
            }
        } else if viewModel.status == .idle {
            viewModel.direction == .right ? viewModel.moveImageRight() : viewModel.moveImageLeft()
        } else {
            return
        }
    }
}
