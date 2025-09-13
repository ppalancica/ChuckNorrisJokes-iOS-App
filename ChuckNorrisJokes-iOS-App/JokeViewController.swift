import UIKit

final class JokeViewController: UIViewController {
    
    private let jokeLoader: JokeLoader!
    
    var onJokeLoaded: (() -> Void)?
    
    @IBOutlet private weak var jokeTextView: UITextView!
    
    static func storyboardedJokeVC(jokeLoader: JokeLoader) -> JokeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let jokeVC = storyboard.instantiateViewController(identifier: "JokeViewController") { coder in
            JokeViewController(jokeLoader: jokeLoader,
                               coder: coder)
        }
        
        return jokeVC
    }
    
    init?(jokeLoader: JokeLoader, coder aDecoder: NSCoder) {
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
        jokeLoader.loadJoke { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                    case .success(let joke): self.jokeTextView.text = joke.value
                    case .failure(let error): print(error.localizedDescription)
                }
                self.onJokeLoaded?()
            }
        }
    }
}

extension JokeViewController: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?
        ) -> Void) {
        // NOOP
    }
}
