import UIKit

struct Joke: Decodable {
    let value: String
}

final class RemoteJokeLoader {
    
    private let session: URLSession
    private var dataTask: URLSessionDataTask!
    
    init(session: URLSession) {
        self.session = session
    }
    
    typealias LoadJokeCompletion = (Data?, URLResponse?, Error?) -> Void
    
    func loadJoke(completion: @escaping LoadJokeCompletion) {
        dataTask?.cancel()
        
        let url = URL(string: "https://api.chucknorris.io/jokes/random")!
        let request = URLRequest(url: url)
        
        dataTask = session.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
        
        dataTask.resume()
    }
    
    func cancelJokeLoad() {
        dataTask?.cancel()
    }
}

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
        jokeLoader.loadJoke(completion: handleResponse)
    }
}

private extension JokeViewController {
    
    func handleResponse(_ data: Data?,
                        _ response: URLResponse?,
                        _ error: Error?) {
        if let error {
            self.handleCompletion(error: error.localizedDescription, data: nil)
            return
        }
        
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else {
            self.handleCompletion(error: "Invalid response", data: data)
            return
        }
        
        guard let data else {
            self.handleCompletion(error: "Invalid data", data: nil)
            return
        }
        
        self.handleCompletion(error: nil, data: data)
    }
    
    func handleCompletion(error: String?, data: Data?) {
        if let error {
            print("Error: ", error)
            DispatchQueue.main.async {
                self.onJokeLoaded?()
            }
            return
        }
        
        if let data {
            do {
                let joke = try JSONDecoder().decode(Joke.self, from: data)
                print("Joke: ", joke)
                
                DispatchQueue.main.async {
                    self.jokeTextView.text = joke.value
                    self.onJokeLoaded?()
                }
            } catch {
                print("Error: ", error)
            }
        }
    }
}

extension JokeViewController: URLSessionDelegate {
    
}
