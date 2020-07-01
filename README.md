# unowned_self

[https://www.avanderlee.com/swift/weak-self/](https://www.avanderlee.com/swift/weak-self/)

- Weak self and unowned self in Swift for many of us are hard to understand. Although Automatic Reference Counting (ARC) solved a lot for us already, we still need to manage references when we’re not working with value types.
- ARC: Automatic Reference Counting

ℹ️  By default, when you don't apply `weak self` , it becomes `strong` reference type.

ℹ️  `weak type` only applies to `Object`

### When to use weak?

- weak references are always declared as optional variables as they can automatically be set to `nil` by ARC when its reference is deallocated.

```swift
class Blog {
    let name: String
    let url: URL
    var owner: Blooger?

    init(name: String, url: URL) {
        self.name = name 
        self.url = url 
    }    

    deinit {
        print("Blog \(name) is being deinitialized")
    }
}

class Blogger {
    let name: String 
    var blog: Blog?

    init(name: String) { self.name = name }

    deinit {
        print("Blogger \(name) is being deinitialized")
    }
}
```

- Retain Cycle

```swift
var blog: Blog? = Blog(name: SwiftLee", url: URL(string: "www.avanderlee.com")!)
var blogger: Blogger? = Blogger(name: "Antoine van der Lee")

blog!.owner = blogger
blogger!.blog = blog 

```

⇒  As soon as any of these classes is deallocated a message is printed out. In the following code example, we’re defining two instances as optionals following by setting them to `nil`. Although some of you might expect two print statements, this doesn’t actually happen:

This is the result of a retain cycle. The blog has a strong reference to its owner and is not willing to release. At the same time, the owner is not willing to free up its blog. The blog does not release its owner who is retaining its blog which is retaining himself which… well, you get the point, `it’s an infinite loop: a retain cycle.`

- refactored with `weak type`

```swift
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
        
        var blog: Blog? = Blog(name: "SwftLee", url: URL(string: "www.avanderlee.com")!)
        var blogger: Blogger? = Blogger(name: "Antoine van der Lee")
        blog!.owner = blogger
        blogger!.blog = blog
        
        blog = nil
        blogger = nil
        
    }

}

class Blog {
    
    let name: String
    let url: URL
    weak var owner: Blogger?
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
    
    deinit {
        print("Blog \(name) is being deintialized")
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
```

⇒ Now you can see `two statements of deinit`

❗️ Only can we nullify object when it's `weak` reference type. In other words, we can't deallocate `strong` reference type.

### How about `weak self`?

- For many of us, it's best practice to always use weak combined with self inside closures to avoid retain cycles.

```swift
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
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
    
    deinit {
        print("Blog \(name) is being deintialized")
    }
    
    func publish(post: Post) {
        //Faking a network request with this delay:
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.publishedPosts.append(post)
            print("Published post count is now: \(self.publishedPosts.count)")
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

// Blogger Antoine van der Lee is being deinitialized
// Published post count is now: 1
// Blog SwiftLee is being deinitialized
```

⇒ You can see that the request is completed before the blog has been released. The strong reference allowed us to finish publishing and to save the post to our published posts.

- added `[weak self]` in `publish()`

```swift
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
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
    
    deinit {
        print("Blog \(name) is being deintialized")
    }
    
    func publish(post: Post) {
        //Faking a network request with this delay:
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [weak self]
            self.publishedPosts.append(post)
            print("Published post count is now: \(self.publishedPosts.count)")
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

// Blogger Antoine van der Lee is being deinitialized
// Blog SwiftLee is being deinitialized
// Published post count is now: nil
```

⇒ As the blog has been released before the publishing request has been finished, we will never be able to update our local state of published posts.

**❗️Therefore, make sure to not use weak self if there’s work to be done with the referencing instance as soon as the closure gets executed.**

### Weak references and retain cycles

ℹ️  In swift, variable can have `closure` 

- A retain cycle occurs as soon as a closure is retaining self and self is retaining the closure. If we would have had a variable containing an onPublish closure instead, this could occur:

```swift
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
        onPublish = { post in
            self.publishedPosts.append(post)
            print("Published post count is now: \(self.publishedPosts.count)")
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

// Blogger Antoine van der Lee is being deinitialized
// Published post count is now: 1
```

- Although everything seems fine with the count of 1, we don’t see the blog and publisher being deinitialized. This is because of the retain cycle and results in memory not being freed up.

```swift
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
            self.publishedPosts.append(post)
            print("Published post count is now: \(self.publishedPosts.count)")
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

// Blogger Antoine van der Lee is being deinitialized
// Published post count is now: Optional(1)
// Blog SwiftLee is being deinitialized
```

⇒ Adding a weak reference to our blog instance inside the onPublish method solves our retain cycle:

### ⚡️ 나의 요약, `weak self` or `unowned self`

- retaining cycle을 방지하기 위해서 `[weak self]` 를 closure에서도 사용하고 변수 선언에도 사용한다.
- 어떤 일이 꼭 진행되야 한다면 `weak` 키워드를 남발하면 안된다.
- `strong type` 은 `deinit` 이 될 수 없고, 메모리 어딘가에 남아 있다.

### When to use unowned self?

- The only benefit of using unowned over weak is that you don’t have to deal with optionals. Therefore, using weak is always safer in those scenarios.

> Use a weak reference whenever it is valid for that reference to become nil at some point during its lifetime. Conversely, use an unowned reference when you know that the reference will never be nil once it has been set during initialization.

❗️ In general, be very careful when using unowned. It could be that you're accessing an instance which is no longer there, causing a crash.

ℹ️  In swift, we have value types and reference types. This already makes it a bit more clear, as with a reference type you actually have a reference to take care of. This means that you need to manage this relation as `strong` , `weak` or `unowned.`

ℹ️  Value types keep a unique copy of its data, a unique intance.

⇒ This means that there's no need to use a weak reference in multi-threaded environments as there's no reference, but a unique copy we're working with. 

### Are weak and unowned only used with self inside closures?

- No, definitely not. You can indicate any property or variable declaration weak or unowned as long as it's a reference type. Therefore, this could also work:

```swift
download(imageURL, completion: { [weak imageViewController] result in
    // ...
})
```

- And you could even reference multiple instances as it's basically an array:

```swift
download(imageURL, completion: { [weak imageViewController, weak imageFinalizer] result in
    // ...
})
```

- if you’re not sure, use weak over unowned.
- Furthermore, if there’s work to be done inside the closure, don’t use weak and make sure your code is getting executed.
# unowned_self
