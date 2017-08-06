/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

/// Heyyy... I'm so global
let movieUrl = "https://itunes.apple.com/us/rss/topmovies/limit=50/json"

class MovieService {
  
  func loadMoviesWith(limit: Double, onComplete complete: @escaping ([Movie]) -> ()) {
    guard let url = URL(string: movieUrl) else {
        print("Invalid url format: \(movieUrl)")
        return
    }
    
    URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
        guard let data = data,
            let jsonString = String(data: data, encoding: .utf8) else {
            print("Error while parsing the response data.")
            return
        }
        
        guard let movies = self?.parse(response: jsonString, withLimit: limit) else {
            return
        }
        complete(movies)
        return
    }.resume()
  }
  
  func parse(response: String, withLimit limit: Double) -> [Movie] {
    return []
  }
}
