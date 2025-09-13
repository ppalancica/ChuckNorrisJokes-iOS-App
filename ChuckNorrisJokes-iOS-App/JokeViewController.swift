import UIKit

final class JokeViewController: UIViewController {
    
    private let jokeLoader: RemoteJokeLoader!
    
    var onJokeLoaded: (() -> Void)?
    
    @IBOutlet private weak var jokeTextView: UITextView!
    
    static func storyboardedJokeVC(jokeLoader: RemoteJokeLoader,
                                   session: URLSession) -> JokeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let jokeVC = storyboard.instantiateViewController(identifier: "JokeViewController") { coder in
            JokeViewController(jokeLoader: jokeLoader,
                               session: session,
                               coder: coder)
        }
        
        return jokeVC
    }
    
    init?(jokeLoader: RemoteJokeLoader, session: URLSession, coder aDecoder: NSCoder) {
        self.jokeLoader = jokeLoader
        super.init(coder: aDecoder)
    }
    
    required init?(coder: NSCoder) {
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate: nil,
                                 delegateQueue: nil)
        jokeLoader = RemoteJokeLoader(session: session)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load from: https://api.chucknorris.io/jokes/random
    }
    
    @IBAction private func loadJokeTapped() {
        jokeLoader.loadJoke { [weak self] joke in
            guard let self else { return }
            DispatchQueue.main.async {
                if let joke {
                    self.jokeTextView.text = joke
                }
                self.onJokeLoaded?()
            }
        }
    }
}

extension JokeViewController: URLSessionDelegate {
    
}
