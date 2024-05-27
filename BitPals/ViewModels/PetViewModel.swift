import SwiftUI
import CloudKit
import AVFoundation

class PetViewModel: ObservableObject {
    var petView: PetView?
    
    // MARK: - Published Properties
    @Published var pet: Pet
    @Published var scale: CGFloat
    @Published var status: PetStatus = .idle
    @Published var direction: PetDirection = .right
    @Published var reminder: Reminder
    
    @Published var fetchTimer: Timer?
    @Published var reminderTimer: Timer?
    @Published var delayReminderTimer: Timer?
    
    @Published var stepCount: Int = 0
    @Published var standTime: Double = 0.0
    
    @Published var isCompanionAppOn: Bool
    
    @Published var audioPlayer: AVAudioPlayer?
    
    // MARK: - Initialization
    init(pet: Pet, scale: CGFloat, reminder: Reminder, isCompanionAppOn: Bool) {
        self.pet = pet
        self.scale = scale
        self.reminder = reminder
        self.isCompanionAppOn = isCompanionAppOn
    }
    
    // MARK: - Methods
    
    // MARK: Configuration
    func configureView() {
        guard let petView = petView else { return }
        petView.translatesAutoresizingMaskIntoConstraints = false
        petView.imageScaling = .scaleProportionallyUpOrDown
        petView.frame.size = NSSize(width: petView.frame.size.width * scale, height: petView.frame.size.height * scale)
    }
    
    // MARK: Image Manipulation
    func setGifImage() {
        let imageName = "\(pet.name.lowercased())_\(status.rawValue)_\(direction.rawValue)"
        guard let imagePath = Bundle.main.path(forResource: imageName, ofType: "gif"),
              let image = NSImage(contentsOfFile: imagePath) else {
            print("Error: Could not load image for \(imageName)")
            return
        }
        
        petView?.image = image
        
        if self.direction == .left {
            self.adjustImagePosition()
        }
    }
    
    func adjustImagePosition() {
        guard let superview = petView?.superview else { return }
        
        let petSize = petView?.intrinsicContentSize
        let windowSize = superview.frame.size
        
        let newOriginX = windowSize.width - petSize!.width
        
        let idlePetSize = self.petView?.intrinsicContentSize
        let widthDifference = petSize!.width - idlePetSize!.width
        let adjustedFrame = NSRect(x: newOriginX + widthDifference, y: 0, width: idlePetSize!.width, height: idlePetSize!.height)
        self.petView?.frame = adjustedFrame
    }
    
    // MARK: Timer Management
    func startFetchTimer() {
        fetchTimer = Timer.scheduledTimer(timeInterval: reminder.seconds, target: self, selector: #selector(fetchHealthDataFromCloudKit), userInfo: nil, repeats: true)
    }
    
    func stopFetchTimer() {
        fetchTimer?.invalidate()
        fetchTimer = nil
    }
    
    func startReminderTimer() {
        reminderTimer = Timer.scheduledTimer(timeInterval: reminder.seconds, target: self, selector: #selector(sendReminder), userInfo: nil, repeats: true)
    }
    
    func stopReminderTimer() {
        reminderTimer?.invalidate()
        reminderTimer = nil
    } 
    
    func stopDelayReminderTimer() {
        delayReminderTimer?.invalidate()
        delayReminderTimer = nil
    }
    
    // MARK: Sound
    func playCrySound() {
        let soundFileName = "\(pet.name.lowercased())_cry"
        guard let soundFilePath = Bundle.main.path(forResource: soundFileName, ofType: "mp3") else {
            print("Error: Could not find sound file for \(soundFileName)")
            return
        }
        
        let soundFileURL = URL(fileURLWithPath: soundFilePath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundFileURL)
            audioPlayer?.volume = 0.2
            audioPlayer?.play()
        } catch {
            print("Error: Could not play sound file \(soundFileName). Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Reminder Handling
    @objc func sendReminder() {
        DispatchQueue.main.async {
            self.stopReminderTimer()
            self.stopFetchTimer()
            
            if self.status == .move {
                self.delayReminderTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                    self.status = .remind
                    self.setGifImage()
                    self.playCrySound()
                }
            } else {
                self.status = .remind
                self.setGifImage()
                self.playCrySound()
            }
        }
    }
    
    // MARK: Data Operations
    @objc func fetchInitialHealthDataFromCloudKit() {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        let query = CKQuery(recordType: "HealthDatas", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        privateDatabase.fetch(withQuery: query, inZoneWith: nil) { result in
            switch result {
            case .failure(let error):
                print("Error fetching health data: \(error.localizedDescription)")
                
            case .success(let success):
                guard let firstRecordResult = success.matchResults.first?.1 else {
                    print("No health data found in CloudKit")
                    return
                }
                
                switch firstRecordResult {
                case .failure(let error):
                    print("Error accessing first record: \(error.localizedDescription)")
                case .success(let firstRecord):
                    self.stepCount = firstRecord["stepCount"] as! Int
                    self.standTime = firstRecord["standTime"] as! Double
                    
                    print("Initial step count: \(self.stepCount)")
                    print("Initial stand time: \(self.standTime)")
                }
            }
        }
    }
    
    @objc func fetchHealthDataFromCloudKit() {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        let query = CKQuery(recordType: "HealthDatas", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        privateDatabase.fetch(withQuery: query, inZoneWith: nil) { result in
            switch result {
            case .failure(let error):
                print("Error fetching health data: \(error.localizedDescription)")
                
            case .success(let success):
                guard let firstRecordResult = success.matchResults.first?.1 else {
                    print("No health data found in CloudKit")
                    return
                }
                
                switch firstRecordResult {
                case .failure(let error):
                    print("Error accessing first record: \(error.localizedDescription)")
                case .success(let firstRecord):
                    self.processHealthData(record: firstRecord)
                }
            }
        }
    }
    
    func processHealthData(record: CKRecord) {
        var differenceStepCount: Int = 0
        var differenceStandTime: Double = 0.0
        
        if let fetchedStepCount = record["stepCount"] as? Int {
            differenceStepCount = fetchedStepCount - self.stepCount
            self.stepCount = fetchedStepCount
        }
        
        if let fetchedStandTime = record["standTime"] as? Double {
            differenceStandTime = fetchedStandTime - self.standTime
            self.standTime = fetchedStandTime
        }
        
        if differenceStepCount > 5 || differenceStandTime > 1 {
            self.sendReminder()
        }
    }
    
    // MARK: Image Animation
    func moveImageRight() {
        guard let superview = petView?.superview else { return }
        
        status = .move
        setGifImage()
        
        let petSize = petView?.intrinsicContentSize
        let windowSize = superview.frame.size
        
        let newOriginX = windowSize.width - petSize!.width
        let newFrame = NSRect(x: newOriginX, y: 0, width: petSize!.width, height: petSize!.height)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 5.0
            context.timingFunction = CAMediaTimingFunction(name: .linear)
            petView?.animator().frame = newFrame
        }) {
            self.status = .idle
            self.direction = .left
            self.setGifImage()
            
            self.adjustImagePosition()
        }
    }
    
    func moveImageLeft() {
        status = .move
        setGifImage()
        
        let petSize = petView?.intrinsicContentSize
        
        let newOriginX: CGFloat = 0
        let newFrame = NSRect(x: newOriginX, y: 0, width: petSize!.width, height: petSize!.height)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 5.0
            context.timingFunction = CAMediaTimingFunction(name: .linear)
            petView?.animator().frame = newFrame
        }) {
            self.status = .idle
            self.direction = .right
            self.setGifImage()
        }
    }
}

