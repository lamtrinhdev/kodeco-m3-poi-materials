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

struct MovieCellView: View {
  // MARK: - Properties
  @ObservedObject var movieListViewModel: MovieListViewModel
  let index: Int

  // MARK: - body
  var body: some View {
    HStack(alignment: .top) {
      let movie = movieListViewModel.movies[index]
      AsyncImage(url: movie.imageUrl) { image in
        image
          .resizable()
          .aspectRatio(0.67, contentMode: .fit)
          .frame(height: 100)
      } placeholder: {
        ZStack {
          GeometryReader { geometry in
            Image(.imagePlaceholder)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: geometry.size.width, height: geometry.size.width * 0.67)
          }
          ProgressView()
        }
      }
      .padding(.trailing, 5)
      VStack(alignment: .leading) {
        Label(
          title: { Text(movie.originalTitle ?? "") },
          icon: { EmptyView() }
        )
          .font(.title)
        Label(
          title: { Text(movie.overview ?? "") },
          icon: { EmptyView() }
        )
      }
      Spacer()
    }
    .frame(height: 100)
    .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
  }
}

#Preview {
  MovieCellView(movieListViewModel: MovieListViewModel(), index: 0)
}
