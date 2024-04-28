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

import SwiftUI

struct MovieListView: View {
  @State var movieListViewModel: MovieListViewModel
  @State private var showingErrorAlert = false

  var columns: [GridItem] = [
    GridItem(.flexible(), spacing: 0)
  ]

  var body: some View {
    NavigationStack {
      ZStack {
        ScrollView {
          LazyVGrid(columns: columns, spacing: 10) {
            ForEach(movieListViewModel.movies) { movie in
              MovieCellView(movie: movie)
                .frame(height: 100)
                .onAppear {
                  if movie.id == movieListViewModel.movies.last?.id {
                    fetchMovies()
                  }
                }
            }
            .padding(.horizontal)
          }
          .navigationTitle("Upcoming Movies")
        }
        if movieListViewModel.isLoading {
          ProgressView("Downloading upcoming movies...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground).opacity(0.8))
        }
        if movieListViewModel.errorManager.errorMessage != nil && movieListViewModel.movies.isEmpty {
          VStack {
            Spacer()
            Button {
              fetchMovies()
            } label: {
              Text("Retry")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            Spacer()
          }
          .padding()
        }
      }
      .task {
        if movieListViewModel.movies.isEmpty {
          await movieListViewModel.fetchMovies()
        }
      }
      .alert(item: $movieListViewModel.errorManager.errorMessage) { errorMessage in
        Alert(
          title: Text("Error"),
          message: Text(errorMessage),
          dismissButton: .default(Text("OK")) {
            movieListViewModel.errorManager.clearError()
          }
        )
      }
    }
//    .onReceive(movieListViewModel.$errorMessage) { errorMessage in
//      if errorMessage != nil {
//        showingErrorAlert = true
//      }
//    }
  }

  private func fetchMovies() {
    Task {
      await movieListViewModel.fetchMovies()
    }
  }
}

#Preview {
  MovieListView(movieListViewModel: MovieListViewModel())
}
