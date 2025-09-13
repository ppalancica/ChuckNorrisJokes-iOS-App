import UIKit

final class JokeViewController: UIViewController {

    @IBOutlet private weak var jokeTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load from: https://api.chucknorris.io/jokes/random
    }
    
    @IBAction private func loadJokeTapped() {
        print("Load Joke")
    }
}
