import Foundation

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
