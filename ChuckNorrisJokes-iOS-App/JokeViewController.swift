import UIKit

struct Joke: Decodable {
    let value: String
}

final class RemoteJokeLoader {
    
    private let url: URL
    private let session: URLSession
    private var dataTask: URLSessionDataTask!
    
    init(url: URL = URL(string: "https://api.chucknorris.io/jokes/random")!,
         session: URLSession) {
        self.url = url
        self.session = session
    }
    
    typealias LoadJokeCompletion = (Data?, String?) -> Void
    
    func loadJoke(completion: @escaping LoadJokeCompletion) {
        dataTask?.cancel()
        
        let request = URLRequest(url: url)
        
        dataTask = session.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data,
                                response: response,
                                error: error,
                                completion: completion)
        }
        
        dataTask.resume()
    }
    
    func cancelJokeLoad() {
        dataTask?.cancel()
    }
    
    func handleResponse(data: Data?,
                        response: URLResponse?,
                        error: Error?,
                        completion: @escaping LoadJokeCompletion) {
        if let error {
            completion(nil, error.localizedDescription)
            return
        }
        
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else {
            completion(data, "Invalid response")
            return
        }
        
        guard let data else {
            completion(nil, "Invalid data")
            return
        }
        
        completion(data, nil)
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
        jokeLoader.loadJoke(completion: handleCompletion)
    }
}

private extension JokeViewController {
    
    func handleCompletion(data: Data?, error: String?) {
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
