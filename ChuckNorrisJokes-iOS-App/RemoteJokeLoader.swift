import Foundation

struct Joke: Decodable {
    let value: String
}

protocol JokeLoader {
    typealias LoadJokeCompletion = (String?) -> Void
    
    func loadJoke(completion: @escaping LoadJokeCompletion)
}

final class RemoteJokeLoader: JokeLoader {
    
    private let url: URL
    private let session: URLSession
    private var dataTask: URLSessionDataTask!
    
    init(url: URL = URL(string: "https://api.chucknorris.io/jokes/random")!,
         session: URLSession) {
        self.url = url
        self.session = session
    }
    
    func loadJoke(completion: @escaping LoadJokeCompletion) {
        dataTask?.cancel()
        
        let request = URLRequest(url: url)
        
        dataTask = session.dataTask(with: request) { data, response, error in
            self.handleResponse(data, response, error,
                                completion: completion)
        }
        
        dataTask.resume()
    }
    
    func cancelJokeLoad() {
        dataTask?.cancel()
    }
    
    func handleResponse(_ data: Data?,
                        _ response: URLResponse?,
                        _ error: Error?,
                        completion: @escaping LoadJokeCompletion) {
        if let error {
            handleCompletion(nil, error.localizedDescription, completion: completion)
            return
        }
        
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else {
            handleCompletion(data, "Invalid response", completion: completion)
            return
        }
        
        guard let data else {
            handleCompletion(nil, "Invalid data", completion: completion)
            return
        }
        
        handleCompletion(data, nil, completion: completion)
    }
    
    private func handleCompletion(_ data: Data?,
                                  _ error: String?,
                                  completion: @escaping LoadJokeCompletion) {
        if let error {
            print("Error: ", error)
            completion(nil)
            return
        }
        
        if let data {
            do {
                let joke = try JSONDecoder().decode(Joke.self, from: data)
                print("Joke: ", joke)
                completion(joke.value)
            } catch {
                print("Error: ", error)
                completion(nil)
            }
        }
    }
}
