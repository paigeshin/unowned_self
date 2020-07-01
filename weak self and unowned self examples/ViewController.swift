//
//  ViewController.swift
//  weak self and unowned self examples
//
//  Created by shin seunghyun on 2020/07/01.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var blog: Blog? = Blog(name: "SwfitLee", url: URL(string: "www.avanderlee.com")!)
        var blogger: Blogger? = Blogger(name: "Antoine van der Lee")
        blog!.owner = blogger
        blogger!.blog = blog
        
        blog!.publish(post: Post(title: "Explaining weak and unowned self"))
        blog = nil
        blogger = nil
        
    }


}

struct Post {
    let title: String
    var isPublished: Bool = false
    
    init(title: String) { self.title = title }
}

class Blog {
    
    let name: String
    let url: URL
    weak var owner: Blogger?
    
    var publishedPosts: [Post] = [Post]()
    
    var onPublish: ((_ post: Post) -> Void)?
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
        
        /* 재미난 syntax.. */
        onPublish = { [weak self] post in
            self!.publishedPosts.append(post)
            print("Published post count is now: \(self!.publishedPosts.count)")
        }
    }
    
    deinit {
        print("Blog \(name) is being deintialized")
    }
    
    func publish(post: Post) {
        //Faking a network request with this delay:
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.onPublish?(post)
        }
    }
    
}

class Blogger {
    let name: String
    var blog: Blog?
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("Blogger \(name) is being deinitialized")
    }
}
