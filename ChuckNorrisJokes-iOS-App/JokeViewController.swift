import UIKit

struct Joke: Decodable {
    let value: String
}

final class JokeViewController: UIViewController {
    
    private var session: URLSession!
    private var dataTask: URLSessionDataTask!
    
    var onJokeLoaded: (() -> Void)?
    
    @IBOutlet private weak var jokeTextView: UITextView!
    
    static func storyboardedJokeVC(session: URLSession) -> JokeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let jokeVC = storyboard.instantiateViewController(identifier: "JokeViewController") { coder in
            JokeViewController(session: session, coder: coder)
        }
        
        return jokeVC
    }
    
    init?(session: URLSession, coder aDecoder: NSCoder) {
        self.session = session
        super.init(coder: aDecoder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load from: https://api.chucknorris.io/jokes/random
    }
    
    @IBAction private func loadJokeTapped() {
        dataTask?.cancel()
        
        if session == nil {
            session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate: self,
                                 delegateQueue: nil)
        }
        
        let url = URL(string: "https://api.chucknorris.io/jokes/random")!
        let request = URLRequest(url: url)
        
        dataTask = session.dataTask(with: request) { data, response, error in
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
        
        dataTask.resume()
    }
    
    func cancelJokeLoad() {
        dataTask?.cancel()
    }
}

private extension JokeViewController {
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
