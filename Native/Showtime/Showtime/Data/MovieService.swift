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
import JavaScriptCore // for webkit stuff too

/// Heyyy... I'm so global
let movieUrl = "https://itunes.apple.com/us/rss/topmovies/limit=50/json"

class MovieService {
    
    // lazy loaded JS Context - cool this is where they load the javascript file from the bundle
    lazy var context: JSContext? = {
        let context = JSContext()
        
        guard let commonJSPath = Bundle.main.path(forResource: "common", ofType: "js") else {
            print("Unable to read resource files.")
            return nil
        }
        
        // Turn it into a script and then evaluate it. magick!
        do {
            let common = try String(contentsOfFile: commonJSPath, encoding: String.Encoding.utf8)
            _ = context?.evaluateScript(common)
        } catch (let error) {
            print("Error while processing script file: \(error)")
        }
        return context
    }()
    
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
    
    /// Nice! works as a buddy with jscontext - all the javascript engineer code can be done for this massively routine json work
    ///  still unclear how easy it is to debug this stuff though. Could potentially be a total nightmare, since javascript debugging tools are the worst on the earth. although there are open source debuggers online.
    /// Doesn't look like it's difficult to add strict error handling for swift so far
    /// - Parameters:
    ///   - response:
    ///   - limit: <#limit description#>
    /// - Returns: <#return value description#>
    func parse(response: String, withLimit limit: Double) -> [Movie] {
        guard let context = context else {
            print("JSContext not found.")
            return []
        }
        
        // context provides the parseJsonmethod -this thing is wrapped in a JSValue obj
        let parseFunction = context.objectForKeyedSubscript("parseJson")
        // here's where you put in the arguments for the javascript parseJson function. nice!
        guard let parsed = parseFunction?.call(withArguments: [response]).toArray() else {
            print("Unable to parse JSON")
            return []
        }
        
        let filterFunction = context.objectForKeyedSubscript("filterByLimit")
        // Filtered is a jSValue... that lives in the JSContext. cool!
        let filtered = filterFunction?.call(withArguments: [parsed, limit]).toArray()
        
        return []
    }
}
