//
//  FeedViewController.swift
//  Gustagram
//
//  Created by Gustavo Cornejo on 10/6/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    var numberOfPosts = Int()
    let myRefresControl:UIRefreshControl! = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPosts()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        myRefresControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.insertSubview(myRefresControl, at: 0)
    }
    
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    @objc func loadPosts() {
        numberOfPosts += 5
        
        let query = PFQuery(className: "Posts")
        
        query.includeKeys(["author"])
        query.limit = numberOfPosts
        query.findObjectsInBackground { posts, error in
            if posts != nil {
                self.posts.removeAll()
                self.posts = posts!
                self.posts.reverse()
                self.tableView.reloadData()
                self.myRefresControl.endRefreshing()
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = 20
        
        query.findObjectsInBackground { posts, error in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
