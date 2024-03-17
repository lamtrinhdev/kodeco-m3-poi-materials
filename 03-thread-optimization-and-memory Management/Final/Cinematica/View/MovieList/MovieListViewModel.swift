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

class MovieListViewModel: ObservableObject {
  // MARK: - Properties
  @Published var allMovies: [MovieCategoryType: [Movie]] = [:]

  @Published var isLoading = true
  @Published var errorMessage: String?

  private let requestManager = RequestManager()
  private var currentPage = [MovieCategoryType: Int]()
  private var totalPages = [MovieCategoryType: Int]()
  private var isFetching = [MovieCategoryType: Bool]()

  func shouldShowError() -> Bool {
    return errorMessage != nil && allMovies.values.allSatisfy { $0.isEmpty }
  }

  // MARK: - Methods
  @MainActor
  func fetchInitialMovies() async {
    isLoading = true
    errorMessage = nil

    do {
      try await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask {
          try await self.fetchMoviesOfType(.nowPlaying)
        }
        group.addTask {
          try await self.fetchMoviesOfType(.upcoming)
        }
        group.addTask {
          try await self.fetchMoviesOfType(.topRated)
        }
        for try await _ in group {}
      }
    } catch {
      errorMessage = error.localizedDescription
    }

    isLoading = false
  }

  func fetchMoreMovies(for type: MovieCategoryType) async {
    guard let isFetching = isFetching[type],
      let currentPage = currentPage[type],
      let totalPages = totalPages[type],
      !isFetching && currentPage <= totalPages else {
      return
    }
    self.isFetching[type] = true

    do {
      try await fetchMoviesOfType(type)
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func fetchMoviesOfType(_ type: MovieCategoryType) async throws {
    let currentPageForType = currentPage[type] ?? 1
    guard currentPageForType <= totalPages[type] ?? 1 else { return }

    let movieRequest: MoviesRequests
    switch type {
    case .nowPlaying:
      movieRequest = .fetchNowPlaying(page: currentPageForType)
    case .upcoming:
      movieRequest = .fetchUpcoming(page: currentPageForType)
    case .topRated:
      movieRequest = .fetchTopRated(page: currentPageForType)
    }

    let moviePaginatedResponse: MoviePaginatedResponse = try await requestManager.perform(movieRequest)
    let newMovies = moviePaginatedResponse.results ?? []

    await MainActor.run { [weak self] in
      if var existingMovies = self?.allMovies[type] {
        existingMovies.append(contentsOf: newMovies)
        self?.allMovies[type] = existingMovies
      } else {
        self?.allMovies[type] = newMovies
      }

      self?.totalPages[type] = moviePaginatedResponse.totalPages ?? 1
      self?.currentPage[type] = currentPageForType + 1
      self?.isFetching[type] = false
    }
  }
}
