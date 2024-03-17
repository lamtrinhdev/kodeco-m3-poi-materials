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
  @StateObject var movieListViewModel: MovieListViewModel
  @State private var showingErrorAlert = false

  var body: some View {
    NavigationView {
      ZStack {
        ScrollView {
          VStack(spacing: 20) {
            ForEach(movieListViewModel.allMovies.keys.sorted(), id: \.self) { movieType in
              SectionView(movieListViewModel: movieListViewModel, movieType: movieType)
            }
          }
          .navigationTitle("Movies")
        }

        if movieListViewModel.isLoading {
          ProgressView("Loading...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground).opacity(0.8))
        }

        if movieListViewModel.shouldShowError() {
          VStack {
            Spacer()
            Button("Retry") {
              Task {
                await movieListViewModel.fetchInitialMovies()
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
      .alert(isPresented: $showingErrorAlert) {
        Alert(
          title: Text("Error"),
          message: Text(movieListViewModel.errorMessage ?? "Unknown error occurred."),
          dismissButton: .default(Text("OK"))
        )
      }
      .onReceive(movieListViewModel.$errorMessage) { errorMessage in
        if errorMessage != nil {
          showingErrorAlert = true
        }
      }
      .onAppear {
        Task {
          await movieListViewModel.fetchInitialMovies()
        }
      }
    }
  }
}

struct SectionView: View {
  @ObservedObject var movieListViewModel: MovieListViewModel
  let movieType: MovieCategoryType
  @State private var isPaginationLoading = false

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(movieType.rawValue)
        .font(.title)
        .padding(.top, 15)
        .padding(.leading, 15)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 10) {
          ForEach(movieListViewModel.allMovies[movieType] ?? [], id: \.self) { movie in
            MovieCellView(movie: movie)
              .frame(width: 150, height: 200)
              .onAppear {
                if movie == movieListViewModel.allMovies[movieType]?.last && !isPaginationLoading {
                  isPaginationLoading = true
                  Task {
                    await movieListViewModel.fetchMoreMovies(for: movieType)
                    isPaginationLoading = false
                  }
                }
              }
          }
        }
      }
    }
    .background(Color(.secondarySystemBackground))
  }
}

#Preview {
  MovieListView(movieListViewModel: MovieListViewModel())
}
