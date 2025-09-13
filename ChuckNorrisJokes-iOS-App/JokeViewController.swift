import UIKit

final class JokeViewController: UIViewController {
    
    private var session: URLSession!
    private var dataTask: URLSessionDataTask!

    @IBOutlet private weak var jokeTextView: UITextView!
    
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
            
            let jsonAsString = String(data: data, encoding: .utf8)
            
            print(jsonAsString ?? "Empty")
        }
        
        dataTask.resume()
    }
    
    private func handleCompletion(error: String?, data: Data?) {
        
    }
}

extension JokeViewController: URLSessionDelegate {
    
}
