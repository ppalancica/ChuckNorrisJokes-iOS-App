@testable import ChuckNorrisJokes_iOS_App
import XCTest

final class ChuckNorrisJokes_iOS_App_Tests: XCTestCase {
    
    func test_init_doesNotCrash() {
        let (_, _) = makeSUT()
    }
    
    func test_viewDidLoad_startsWithEmptyTextView() throws {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(try sut.textView().text, "")
    }
    
    func test_loadJokeTapped_loadsJokeToTextView() throws {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for Joke loading to complete")
        sut.onJokeLoaded = { exp.fulfill() }
        XCTAssertEqual(try sut.textView().text, "")
        
        try sut.loadJokeButton().sendActions(for: .touchUpInside)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertFalse(try sut.textView().text.isEmpty)
    }
    
    func test_loadJokeTapped_onCancel_doesNotChangeTextViewText() throws {
        let (sut, jokeLoader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for Joke loading to complete")
        sut.onJokeLoaded = { exp.fulfill() }
        XCTAssertEqual(try sut.textView().text, "")
        
        try sut.loadJokeButton().sendActions(for: .touchUpInside)
        jokeLoader.cancelJokeLoad()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertTrue(try sut.textView().text.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (JokeViewController, RemoteJokeLoader) {
        let session = URLSession(configuration: .ephemeral)
        let jokeLoader = RemoteJokeLoader(session: session)
        
        let jokeVC = JokeViewController.storyboardedJokeVC(jokeLoader: jokeLoader)
        
        return (jokeVC, jokeLoader)
    }
}

private extension JokeViewController {
    
    func textView() throws -> UITextView {
        let firstSubview = view.subviews.first(
            where: { $0 is UITextView }
        )
        
        return try XCTUnwrap(firstSubview as? UITextView)
    }
    
    func loadJokeButton() throws -> UIButton {
        let firstSubview = view.subviews.first(
            where: { $0 is UIButton }
        )
        
        return try XCTUnwrap(firstSubview as? UIButton)
    }
}
