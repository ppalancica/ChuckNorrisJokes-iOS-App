@testable import ChuckNorrisJokes_iOS_App
import XCTest

final class ChuckNorrisJokes_iOS_App_Tests: XCTestCase {
    
    func test_init_doesNotCrash() {
        let _ = makeSUT()
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> JokeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let jokeVC = storyboard.instantiateInitialViewController() as! JokeViewController
        
        return jokeVC
    }
}
