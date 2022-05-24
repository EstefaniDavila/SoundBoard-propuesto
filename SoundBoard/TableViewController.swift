import UIKit
import AVFoundation

class TableViewController: UITableViewController {
    
    var recordings: [Recording] = []
    var playAudio: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            recordings = try
                context.fetch(Recording.fetchRequest())
            tableView.reloadData()
        } catch {}
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recordings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell
        let recording = recordings[indexPath.row]
        cell.nameLabel.text = recording.name!
        cell.durationLabel.text = recording.duration!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recording = recordings[indexPath.row]
        do {
            playAudio = try AVAudioPlayer(data: recording.audio! as Data)
            playAudio?.play()
            print("Reproduciendo audio \(recording.name!)")
        } catch {}
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recording = recordings[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(recording)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                recordings = try
                    context.fetch(Recording.fetchRequest())
                tableView.reloadData()
            } catch {}
        }
    }

    

}
