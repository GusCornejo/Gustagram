//
//  FeedViewController.swift
//  Gustagram
//
//  Created by Gustavo Cornejo on 10/6/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost:PFObject!
    
    var numberOfPosts = Int()
    var morePosts = true
    let myRefresControl:UIRefreshControl! = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment"
        commentBar.sendButton.title = "Post"
        
        loadPosts()
        
        commentBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        myRefresControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myRefresControl
        
    }
    
    @objc func loadPosts() {
        numberOfPosts = 20
        
        let query = PFQuery(className: "Posts")
        
        query.includeKeys(["author", "comments", "comments.author"])
        query.addDescendingOrder("createdAt")
        query.limit = numberOfPosts
        query.findObjectsInBackground { posts, error in
            if posts != nil {
                self.posts.removeAll()
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefresControl.endRefreshing()
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    //comments
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground { success, error in
            if success {
                print("comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        tableView.reloadData()
    
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func loadMorePosts() {
        
        numberOfPosts += 10
        
        if numberOfPosts > posts.count {
            morePosts = false
        }
        
        let query = PFQuery(className: "Posts")
        
        query.includeKeys(["author", "comments", "comments.author"])
        query.addDescendingOrder("createdAt")
        query.limit = numberOfPosts
        query.findObjectsInBackground { posts, error in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section + 1 == posts.count && morePosts == true {
            loadMorePosts()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.addDescendingOrder("createdAt")
        query.limit = numberOfPosts
        
        query.findObjectsInBackground { posts, error in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    @objc func keyboardWillBeHidden(note:Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        if indexPath.row == 0 {
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.usernameHeaderLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            let imageFile2 = user["profilePic"] as! PFFileObject
            let urlString2 = imageFile2.url!
            let url2 = URL(string: urlString2)!
            
            cell.photoView.af_setImage(withURL: url)
            cell.userPicView.af_setImage(withURL: url2)
            
            cell.userPicView.layer.borderWidth = 1
            cell.userPicView.layer.masksToBounds = false
            cell.userPicView.layer.borderColor = UIColor.black.cgColor
            cell.userPicView.layer.cornerRadius =  cell.userPicView.frame.height/2
            cell.userPicView.clipsToBounds = true
            
            return cell
            
        } else if indexPath.row <= comments.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            
            let imageFile = user["profilePic"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.commentPicView.af_setImage(withURL: url)
            
            cell.commentPicView.layer.borderWidth = 1
            cell.commentPicView.layer.masksToBounds = false
            cell.commentPicView.layer.borderColor = UIColor.black.cgColor
            cell.commentPicView.layer.cornerRadius =  cell.commentPicView.frame.height/2
            cell.commentPicView.clipsToBounds = true
            
            cell.nameLabel.text = user.username
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    //logout
    @IBAction func logout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    }
}
