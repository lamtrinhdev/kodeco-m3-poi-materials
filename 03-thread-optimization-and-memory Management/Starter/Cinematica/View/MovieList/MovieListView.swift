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
  @ObservedObject var movieListViewModel: MovieListViewModel

  var body: some View {
    NavigationView {
      ZStack {
        ScrollView {
          VStack(spacing: 20) {
            SectionView(movies: movieListViewModel.nowPlayingMovies, title: "Now Playing")
            SectionView(movies: movieListViewModel.upcomingMovies, title: "Upcoming")
            SectionView(movies: movieListViewModel.topRatedMovies, title: "Top Rated")
          }
          .padding()
        }

        if movieListViewModel.isLoading {
          ProgressView("Loading...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground).opacity(0.8))
        }

        if movieListViewModel.errorMessage != nil {
          VStack {
            Spacer()
            Button("Retry") {
              Task {
                await movieListViewModel.fetchNowPlayingMovies()
                await movieListViewModel.fetchUpcomingMovies()
                await movieListViewModel.fetchTopRatedMovies()
              }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            Spacer()
          }
          .padding()
        }
      }
      .alert(isPresented: Binding(
        get: { movieListViewModel.errorMessage != nil },
        set: { _ in movieListViewModel.errorMessage = nil }
      )) {
        Alert(
          title: Text("Error"),
          message: Text(movieListViewModel.errorMessage ?? "Unknown error occurred."),
          dismissButton: .default(Text("OK"))
        )
      }
      .onAppear {
        Task {
          await movieListViewModel.fetchNowPlayingMovies()
          await movieListViewModel.fetchUpcomingMovies()
          await movieListViewModel.fetchTopRatedMovies()
        }
      }
      .navigationTitle("Movies")
    }
  }
}

struct SectionView: View {
  let movies: [Movie]
  let title: String

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title)
        .font(.title)
        .padding(.top, 15)
        .padding(.leading, 15)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 10) {
          ForEach(movies, id: \.id) { movie in
            MovieCellView(movie: movie)
              .frame(width: 150, height: 200)
          }
        }
      }
    }
    .background(Color(.secondarySystemBackground))
  }
}

struct ErrorRetryView: View {
  let retryAction: () -> Void

  var body: some View {
    VStack {
      Spacer()
      Button("Retry") {
        retryAction()
      }
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(8)
      Spacer()
    }
  }
}

#Preview {
  MovieListView(movieListViewModel: MovieListViewModel())
}
