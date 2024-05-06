/// Copyright (c) 2024 Kodeco Inc.
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Observation

@Observable
class MovieListViewModel {
  // MARK: - Properties
  var upcomingMovies: [Movie] = []
  var topRatedMovies: [Movie] = []
  var popularMovies: [Movie] = []

  var isLoading = true
  var errorManager = ErrorManager()
  private let requestManager = RequestManager()
  private var currentPage = 1
  private var totalPages = 1
  private var isFetching = false

  // MARK: - Methods
  func fetchMovies(_ request: MoviesRequests, into movies: inout [Movie]) async {
    guard !isFetching && currentPage <= totalPages else { return }
    isFetching = true

    do {
      let moviePaginatedResponse: MoviePaginatedResponse = try await requestManager.perform(request)
      if let newMovies = moviePaginatedResponse.results {
        movies.append(contentsOf: newMovies)
      }
      await MainActor.run {
        self.totalPages = moviePaginatedResponse.totalPages ?? 1
        self.isLoading = false
        self.currentPage += 1
        self.isFetching = false
      }
    } catch {
      await MainActor.run {
        self.isLoading = false
        errorManager.handleError(error)
        self.isFetching = false
      }
    }
  }

  // Fetch movies
  func fetchUpcomingMovies() async {
    await fetchMovies(fetchUpcomingRequest(), into: &upcomingMovies)
  }

  func fetchTopRatedMovies() async {
    await fetchMovies(fetchTopRatedRequest(), into: &topRatedMovies)
  }

  func fetchPopularMovies() async {
    await fetchMovies(fetchPopularRequest(), into: &popularMovies)
  }

  // Fetch Requests
  private func fetchUpcomingRequest() -> MoviesRequests {
    return .fetchUpcoming(page: 1)
  }

  private func fetchTopRatedRequest() -> MoviesRequests {
    return .fetchTopRated(page: 1)
  }

  private func fetchPopularRequest() -> MoviesRequests {
    return .fetchPopular(page: 1)
  }
}
