import Foundation

struct Joke: Decodable {
    let value: String
}

enum JokeLoaderError: Swift.Error {
    case genericError(String)
    case decodingError(String)
    case unknownError(String)
}

protocol JokeLoader {
    typealias LoadJokeCompletion = (Result<Joke, JokeLoaderError>) -> Void
    
    func loadJoke(completion: @escaping LoadJokeCompletion)
    
    func cancelJokeLoad()
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
            completion(.failure(.genericError(error)))
        } else if let data {
            do {
                let joke = try JSONDecoder().decode(Joke.self, from: data)
                print("Joke: ", joke)
                completion(.success(joke))
            } catch {
                print("Error: ", error)
                completion(.failure(.decodingError("Could not convert Data to Joke")))
            }
        } else { // No data and no error, and we have to call completion anyway
            completion(.failure(.unknownError("Could not load joke")))
        }
    }
}
