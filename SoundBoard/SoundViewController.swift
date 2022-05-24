import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var durationRecord: UILabel!
    
    
    var recordAudio: AVAudioRecorder?
    var playAudio: AVAudioPlayer?
    var audioURL: URL?
    
    var timer: Timer = Timer()
    var count: Int = 0
    var timerCounting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingConfiguration()
        playButton.isEnabled = false
        addButton.isEnabled = false
    }
    
    func recordingConfiguration() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("******************************")
            print(audioURL!)
            print("******************************")
            
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            recordAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            recordAudio!.prepareToRecord()
        }
        catch let error as NSError{
            print(error)
        }
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        if recordAudio!.isRecording {
            recordAudio?.stop()
            recordButton.setTitle("Grabar", for: .normal)
            playButton.isEnabled = true
            addButton.isEnabled = true
            timerCounting = false
            timer.invalidate()
            durationRecord.textColor = UIColor.black
        }
        else {
            recordButton.setTitle("Detener", for: .normal)
            playButton.isEnabled = false
            recordAudio?.record()
            timerCounting = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            durationRecord.textColor = UIColor.systemBlue
        }
    }
    
    @objc func timerCounter() -> Void {
        count = count + 1
        let time = minutesAndSeconds(seconds: count)
        let timeString = makeTimeString(minutes: time.0, seconds: time.1)
        durationRecord.text = timeString
    }
    
    func minutesAndSeconds(seconds: Int) -> (Int, Int) {
        return (((seconds % 3600) / 60), (seconds % 3600) % 60)
    }
    
    func makeTimeString(minutes: Int, seconds: Int) -> String {
        var timerString = ""
        timerString += String(format: "%02d", minutes)
        timerString += ":"
        timerString += String(format: "%02d", seconds)
        return timerString
    }
    
    @IBAction func playTapped(_ sender: Any) {
        do {
            try playAudio = AVAudioPlayer(contentsOf: audioURL!)
            playAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    @IBAction func recordingVolume(_ sender: UISlider) {
        print(sender.value)
        playAudio?.volume = sender.value
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let recording = Recording(context: context)
        recording.name = nameTextField.text!
        recording.duration = durationRecord.text!
        recording.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
}
