//
//  HomeController.swift
//  Induk_SNS
//
//  Created by 승진김 on 18/12/2018.
//  Copyright © 2018 seungjin. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: "postCellID")
        
        return collectionView
    }()
    
    var post = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        setupCollectionView()
        setupNavigationItems()
        
        fetchPosts()
        
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupNavigationItems() {
        self.navigationItem.title = "Indukgram"
    }
    
    private func fetchPosts() {
        
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            userDictionary.forEach({ (key, value) in
                print("KKKKKKKK",key)
                guard let userDic = value as? [String: Any] else { return }
                
                let user = User(uid: key, dictionary: userDic)
                self.fetchPostsWithUser(user: user)
            })
        }) { (error) in
            print("******************************************************")
            print(" <User 정보 가져오기 실패:> \n\t", error)
            print("******************************************************")
        }

    }
//    private func fetchUser() {
//
//        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
//
//        Database.fetchUserWithUID(uid: uid) { (user) in
//            self.user = user
//            self.navigationItem.title = self.user?.username
//
//            self.collectionView.reloadData()
//
//            self.fetchOrderedPosts()
//        }
//    }
    private func fetchPostsWithUser(user: User) {
        let databaseRef = Database.database().reference().child("posts").child(user.uid)
        databaseRef.observeSingleEvent(of: DataEventType.value, with: { snapshot in

            guard let value = snapshot.value as? [String:Any] else { return }
            value.forEach({ (key, value) in
                
                guard let dictionary = value as? [String: Any] else { return }
                
                let post = Post(user: user, dictionary: dictionary)
                self.post.append(post)
                self.post.sort(by: { (post1, post2) -> Bool in
                    return post1.creationDate.compare(post2.creationDate) == .orderedDescending
                })
            })
            
            self.collectionView.reloadData()
        }) { (error) in
            print("******************************************************")
            print(" <Failed to fetch posts:> \n\t", error)
            print("******************************************************")
        }
    }

    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        post.removeAll()
        fetchPosts()
    }
}

extension HomeController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCellID", for: indexPath) as! HomePostCell
        
        cell.post = post[indexPath.item]
        
        return cell
    }
}

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // UserProfileImageView
        height += view.frame.width
        height += 50 // StackView
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }
}
